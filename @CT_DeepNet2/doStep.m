function [action] = doStep(obj, input, reward, reset_traces )

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

if obj.check_derivatives % if trace checking; keep a copy of the network at begining of time-step;
    obj2 = obj.copy();
end

% Compute X

obj.calc_Input();% sets input 

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
try
for f = 1:obj.n_hidden_features
    
    % Input to hidden:
    obj.v1{f} = obj.v1{f} + obj.beta * obj.fdelta * obj.v1_traces{f}.*obj.v1_mask; % Weights from input to hidden layer1
    obj.t1{f} = obj.t1{f} + obj.beta * obj.fdelta * obj.t1_traces{f}.*obj.t1_mask; % Weights from modul input to hidden layer 1
    obj.u1{f} = obj.u1{f} + obj.beta * obj.fdelta * obj.u1_traces{f}.*obj.u1_mask; % Weights from hidden layer 1 to modul input
    obj.u1mod{f} = obj.u1mod{f} + obj.beta * obj.fdelta * obj.u1mod_traces{f}.*obj.u1_mask;% Weights from modul hidden 1 to modul input
    for f2 = 1:obj.n_hidden_features
        obj.v2{f}{f2} = obj.v2{f}{f2} + obj.beta * obj.fdelta * obj.v2_traces{f}{f2}.*obj.v2_mask; % Weights from hidden layer 1 to hidden layer 2
        obj.t2{f}{f2} = obj.t2{f}{f2} + obj.beta * obj.fdelta * obj.t2_traces{f}{f2}.*obj.t2_mask; % Weights from modul hidden1 to hidden layer 2
        obj.u2{f}{f2} = obj.u2{f}{f2} + obj.beta * obj.fdelta * obj.u2_traces{f}{f2}.*obj.u2_mask;% Weights from hidden layer 2 to modul hidden layer 1
    end
    obj.w{f} = obj.w{f} + obj.beta * obj.fdelta * obj.w_traces{f}.*obj.w_mask;
    
end
catch; keyboard; end

% Update eligibility traces
if (reset_traces) % Note that the correct place to reset traces is essential!
    obj.resetTraces();
else % No point in updating traces if there is a reset afterwards
   obj.update_traces();
   if obj.check_derivatives
       obj2.check_traces(obj.new_traces, exp_value, obj.prev_action)
   end
end

obj.prev_input = obj.current_input;%obj.X;

% Store critic estimate:
% Calculate critic estimate:
obj.previous_qa = exp_value; % estimate of value with old params
obj.previous_critic_val = obj.qas(obj.prev_action);
obj.udelta = reward + (obj.gamma * obj.qas(obj.prev_action)) - obj.previous_qa;

% Set the chosen action, for the environment to evaluate:
action = obj.Z;

