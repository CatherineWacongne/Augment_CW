function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces

%% Decay the traces

% Contains the indices of normal units in input layer
n_xyr = 1: (obj.bias_input + obj.n_inputs);
% Contains the indices of differentiating units and modulated units in input layer
if (strcmp(obj.input_method, 'modulposneg'))
    m_xyr = (obj.bias_input + obj.n_inputs*2 + 1):(obj.nx + obj.bias_input);
    mod_xyr = (obj.bias_input + obj.n_inputs + 1):(obj.bias_input + obj.n_inputs*2);
else
    m_xyr = (obj.bias_input + obj.n_inputs + 1):(obj.nx + obj.bias_input);
    mod_xyr = [];
end

% Contains the indices of normal units in hidden layer
n_yzr = 1: (obj.bias_hidden + obj.ny_normal);
% Contains the indices of memory units in hidden layer
m_yzr = (((obj.bias_hidden + obj.ny_normal) + 1): ...
  obj.ny + obj.bias_hidden);

% For normal hiddens
obj.wxy_traces([n_xyr mod_xyr],1:obj.ny_normal) = ...
    obj.wxy_traces([n_xyr mod_xyr],1:obj.ny_normal) * ...
    obj.gamma * obj.lambda;

% For memory hiddens
obj.wxy_traces(m_xyr, (obj.ny_normal + 1): end) = ...
    obj.wxy_traces(m_xyr, (obj.ny_normal + 1): end) .* ...
    obj.lambda_mem_arr;
    
% For output traces:
obj.wyz_traces = obj.wyz_traces * obj.gamma * obj.lambda;

% For modulatory traces
obj.wyx_traces = obj.wyx_traces * obj.gamma * obj.lambda;

%% Now, update the traces:

% Hidden to Output traces: 
% Update traces of synapses connected to winning neuron

% For output traces:

obj.wyz_traces(:, obj.prev_action) =  obj.wyz_traces(:, obj.prev_action) +...
    [obj.bias_hidden obj.Y]';

% If set (default: off) limit eligibility traces.
if (obj.limit_traces)
  
 wxy_idces = find(abs(obj.wxy_traces) > 2);
 wyz_idces = find(abs(obj.wyz_traces) > 2);
 wyx_idces = find(abs(obj.wyx_traces) > 2);
 
 obj.wxy_traces( wxy_idces ) = sign(obj.wxy_traces( wxy_idces ) ) *2;
 obj.wyz_traces( wyz_idces ) = sign(obj.wyz_traces( wyz_idces ) ) *2;
 obj.wyx_traces( wyx_idces ) = sign(obj.wyx_traces( wyx_idces ) ) *2;
  
end

% Update hidden units: first normal units, then memory units
% Note that these depend on the sigmoid activation functions.
 
% Input to Hidden_normal traces
if (strcmp(obj.input_method, 'modulposneg'))
    input = repmat([obj.bias_input obj.X(1:obj.n_inputs*2)]',1,  obj.ny_normal);
else
    input = repmat([obj.bias_input obj.X(1:obj.n_inputs)]',1,  obj.ny_normal);
end
% Derivatives for normal hiddens:
d_hn = obj.hd_transform_normal_deriv(obj.Y(1:obj.ny_normal));

delta_hn = [obj.bias_hidden d_hn] .* ...
  obj.weights_yz(n_yzr, obj.prev_action)';

if (strcmp(obj.input_method, 'modulposneg'))
    delta_hn_block = repmat(delta_hn(1+obj.bias_hidden:end), ...
                        obj.n_inputs*2 + obj.bias_input,1); 
else
    delta_hn_block = repmat(delta_hn(1+obj.bias_hidden:end), ...
                        obj.n_inputs + obj.bias_input,1); 
end
                      
obj.wxy_traces([n_xyr mod_xyr], 1:obj.ny_normal) =  ...
    obj.wxy_traces([n_xyr mod_xyr], 1:obj.ny_normal) + input .* delta_hn_block;

% Set the e-traces used in the update rule to the computed values:
obj.wxy_traces_now([n_xyr mod_xyr], 1:obj.ny_normal) = obj.wxy_traces([n_xyr mod_xyr], 1:obj.ny_normal);  

  
% Input to Hidden_memory traces 
% [NOTE that mem_input already discards bias unit input]
m_input =  repmat([obj.mem_input]',1,  obj.ny_memory);

% Derivatives for memory hiddens:
d_hm = obj.hd_transform_memory_deriv(obj.Y(obj.ny_normal+1:end));

delta_hm = d_hm .* ...
  obj.weights_yz(m_yzr, obj.prev_action)';

obj.wxy_traces(m_xyr, obj.ny_normal + 1:end) = ...
    obj.wxy_traces(m_xyr,obj.ny_normal + 1:end) + m_input;

delta_hm_block = repmat(delta_hm,size(m_xyr,2),1); 

% Set the e-traces used in the update rule to the computed values:
obj.wxy_traces_now(m_xyr, obj.ny_normal + 1:end) =  ...
    obj.wxy_traces(m_xyr, obj.ny_normal + 1:end) .* delta_hm_block;

% Feedback traces

mod_input = repmat([ obj.Y(obj.ny_normal + 1:end)]',1,  obj.n_inputs); %ym :size = n_ymemo * n_modul %obj.bias_hidden

d_mod = obj.hd_transform_normal_deriv(obj.X(obj.n_inputs+1:obj.n_inputs*2)); %xf
d_mod_block = repmat(d_mod,obj.ny_memory ,1);
delta_hn_block = repmat(delta_hn(1+obj.bias_hidden:end), obj.n_inputs ,1); 
sum_j = sum(delta_hn_block.*obj.weights_xy([obj.n_inputs+ obj.bias_input+1:obj.n_inputs*2+ obj.bias_input], 1:obj.ny_normal),2);
sumj_block = repmat(sum_j',obj.ny_memory ,1);
% delta_d_mod_block = repmat(d_mod, obj.ny_memory,1	);
% n_input_from_mod = repmat(obj.X(obj.n_inputs+1:obj.n_inputs*2), obj.ny_memory,1	);%xf :n_ymemo * n_modul %+obj.bias_hidden
% j_contrib = sum(delta_hn(1+obj.bias_hidden:end)); 

% f_contrib = n_input_from_mod .* j_contrib;

obj.wyx_traces( [ obj.bias_hidden+obj.ny_normal+1:end],obj.n_inputs+1:obj.n_inputs*2) =  ...
    obj.wyx_traces([ obj.bias_hidden+obj.ny_normal+1:end],obj.n_inputs+1:obj.n_inputs*2) + mod_input .* d_mod_block .* sumj_block;
  
end