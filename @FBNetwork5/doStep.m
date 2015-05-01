function [action] = doStep(obj, input, reward, reset_traces )
isinternal = 1;
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

% Add 0-mean Gaussian noise to the inputs?
if (obj.input_noise)
  obj.current_input = obj.current_input + ...
    obj.noise_sigma * randn(size(obj.current_input));
end

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
obj.calc_Hiddens(); % sets ym

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
end
if (reset_traces)
    exp_value = 0;
end

% Calculate TD-error:
obj.delta = reward + (obj.gamma * exp_value) - obj.previous_qa;
% if reward >0; keyboard;end
% Limit delta if option is set (default off)
if (obj.limit_delta && (abs(obj.delta) > obj.delta_limit))
    disp('TD error limit crossed!')
%     keyboard
    obj.delta
    obj.delta = sign(obj.delta) * obj.delta_limit;
end

% Calculate F(Delta) transform:
% This is not used in AuGMEnT
%obj.fdelta = obj.calc_fdelta();

obj.fdelta = obj.delta;

% Update weights:

% Input to hidden:
obj.weights_xy = obj.weights_xy + obj.beta * obj.fdelta * obj.wxy_traces_now;
% if max(obj.weights_xy(51,:))>5
%     keyboard;
% end
% if reward>0; keyboard;end
% Hidden to output:
obj.weights_yz = obj.weights_yz + obj.beta * obj.fdelta * obj.wyz_traces;
obj.weights_yzs = obj.weights_yzs + obj.beta * obj.fdelta * obj.wyzs_traces;
% obj.weights_zzs = obj.weights_zzs + obj.beta * obj.fdelta * obj.wzzs_traces;
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
if isinternal
if obj.prev_action<=obj.nzs
    action = obj.prev_motor_output;
else
    action = obj.Z;
    obj.prev_motor_output = obj.Z;

end
else 
    action = obj.ZS;
end
