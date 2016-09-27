function [action] = doStep(obj, input, reward, reset_traces )
isinternal = 0;
%DOSTEP Simulate one epoch of the network

% Set network input:
if (obj.n_inputs == length(input))
  obj.current_input = input;
else % Number of inputs is not correct:
  % Create exception
  ex=MException('Network:doStep:InputError','Number of inputs does not match number of input neurons');
  throw(ex)
end

% Store noiseless input
obj.noiseless_input = input;

% % Add 0-mean Gaussian noise to the inputs?
% if (obj.input_noise)
%   obj.current_input = obj.current_input + ...
%     obj.noise_sigma * randn(size(obj.current_input));
% end

% Compute X
% Note that X *includes* the on and off cells
% (or sustained cells is 'old' method is used) 
% if (strcmp(obj.input_method, 'modulcells'))
%   d_pos = [obj.current_input - obj.prev_input];
%   d_pos( d_pos < 0) = 0;
%   d_neg = [obj.current_input - obj.prev_input];
%   d_neg( d_neg > 0) = 0;
%   obj.X = [obj.current_input d_pos abs(d_neg)];
% % elseif (strcmp(obj.input_method, 'old'))
% %   obj.X = [obj.current_input (obj.current_input .* ~(obj.current_input == obj.prev_input))];
% end



% Calculate hidden layer activations (sets Y)
% obj.Y = 0*obj.Y;
% obj.calc_Input();% sets input but not xk

% obj.calc_Hiddens(); % sets ym

obj.calc_Input();% sets input incl xk

obj.calc_Hiddens();% sets yj

% Calculate output layer activations (sets Z) 
obj.calc_Output();

% Set predicted Q-value
exp_value = obj.qas(obj.prev_action);

% Naive Q-learning network hack:
if (obj.naiveQ)
  v = max(obj.qas);

  % Change expectation to MAX(actions, current_state)
  if (v ~= obj.qas(obj.prev_action))
    exp_value = v;
  end
end

if (isnan(obj.previous_qa))
  obj.previous_qa = exp_value;
  disp('Initial Update!?')
  keyboard;
end
if (reset_traces)
    exp_value = 0;
end

% Calculate TD-error:
obj.delta = reward + (obj.gamma * exp_value) - obj.previous_qa;
% if reward >0.5; keyboard;end
% Limit delta if option is set (default off)
if (obj.limit_delta && (abs(obj.delta) > obj.delta_limit))
    disp('TD error limit crossed!')
    if (abs(obj.delta) > obj.delta_limit*20)
%          keyboard
    end
    obj.delta
    obj.delta = sign(obj.delta) * obj.delta_limit;
end


obj.fdelta = obj.delta;

% Update weights:


obj.weights_xiyj    = obj.weights_xiyj      + obj.beta * obj.fdelta * obj.wxiyj_traces; % Weights from input to hidden layer
obj.weights_xkyj    = obj.weights_xkyj      + obj.beta * obj.fdelta * obj.wxkyj_traces;
obj.weights_xonym   = obj.weights_xonym     + obj.beta * obj.fdelta * obj.wxonym_traces;
obj.weights_xoffym  = obj.weights_xoffym    + obj.beta * obj.fdelta * obj.wxoffym_traces;
obj.weights_xkonym  = obj.weights_xkonym    + obj.beta * obj.fdelta * obj.wxkonym_traces;
obj.weights_xkoffym = obj.weights_xkoffym   + obj.beta * obj.fdelta * obj.wxkoffym_traces;


obj.weights_ymxk    = obj.weights_ymxk      + obj.beta * obj.fdelta * obj.wymxk_traces;% Weights from input to hidden layer

obj.weights_yjz     = obj.weights_yjz       + obj.beta * obj.fdelta * obj.wyjz_traces; % Weights from hidden to output layer
obj.weights_ymz     = obj.weights_ymz       + obj.beta * obj.fdelta * obj.wymz_traces; % Weights from hidden to output layer

% Update eligibility traces

if (reset_traces) % Note that the correct place to reset traces is essential!
    obj.resetTraces();
else % No point in updating traces if there is a reset afterwards
   obj.update_traces();
end

obj.prev_input = obj.current_input;%obj.X;

% Store critic estimate:
% Calculate critic estimate:
obj.previous_qa = exp_value; % estimate of value with old params
obj.previous_critic_val = obj.qas(obj.prev_action);
obj.udelta = reward + (obj.gamma * obj.qas(obj.prev_action)) - obj.previous_qa;

% Set the chosen action, for the environment to evaluate:
% if isinternal
%     if obj.prev_action<=obj.nzs
%         action = obj.prev_motor_output;
%     else
%         action = obj.Z;
%         obj.prev_motor_output = obj.Z;
%         
%     end
% else
    action = obj.Z;
% end
