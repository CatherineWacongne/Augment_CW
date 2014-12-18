function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces

% Contains the indices of normal units in input layer presyn
n_i_pre = 1: (obj.bias_input + obj.n_inputs);
% Contains the indices of modulated units in input layer
n_k_pre = (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);

% Contains the indices of normal units in hidden layer
n_j_pre = 1: (obj.bias_hidden + obj.ny_normal);
% Contains the indices of memory units in hidden layer
n_m_pre =  (obj.bias_hidden + obj.ny_normal + 1): ...
    obj.ny + obj.bias_hidden;


% Contains the indices of normal units in input layer postyn
n_k_post =  obj.n_inputs+1: obj.n_inputs*2;
n_j_post = 1:obj.ny_normal;
n_m_post = obj.ny_normal + 1: obj.ny ;

% For  hiddens
obj.wxy_traces = obj.wxy_traces * obj.gamma * obj.lambda;

% For output traces:
obj.wyz_traces = obj.wyz_traces * obj.gamma * obj.lambda;


%% Now, update the traces:
% If set (default: off) limit eligibility traces.
if (obj.limit_traces)
    
    wxy_idces = find(abs(obj.wxy_traces) > 2);
    wyz_idces = find(abs(obj.wyz_traces) > 2);   
    
    obj.wxy_traces( wxy_idces ) = sign(obj.wxy_traces( wxy_idces ) ) *2;
    obj.wyz_traces( wyz_idces ) = sign(obj.wyz_traces( wyz_idces ) ) *2; 
end

% basic variables
y_j = obj.Y(1:obj.ny_normal);
y_m = obj.Y(obj.ny_normal+1:obj.ny);
x_i = obj.X(1:obj.n_inputs);
x_k = obj.X(obj.n_inputs+1:obj.n_inputs*2);

w_ja = obj.weights_yz(n_j_pre(2:end),obj.prev_action);
w_ij = obj.weights_xy(n_i_pre(2:end),n_j_post);


% Compute all the activ derivatives :
dsig_j = obj.hd_transform_normal_deriv(y_j);
dsig_k = obj.hd_transform_normal_deriv(x_k);
dsig_m = obj.hd_transform_normal_deriv(y_m);

% for output traces
obj.wyz_traces(n_j_pre, obj.prev_action) =  obj.wyz_traces(n_j_pre, obj.prev_action) + [obj.bias_hidden y_j]';


% for xy trace
dPdwkj =  x_k' * (dsig_j .*  w_ja');
obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;

dPdwij = [1; x_i'] * (dsig_j .*  w_ja');
obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);


end





