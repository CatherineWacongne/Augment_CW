obj = n;
n_i_pre = 1: (obj.bias_input + obj.n_inputs);
    % Contains the indices of modulated units in input layer
    n_k_pre = (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);
        % Contains the indices of differentiating units in input layer
    n_d_pre = (obj.bias_input + obj.n_inputs*2 + 1):(obj.nx + obj.bias_input);
    
    % Contains the indices of normal units in hidden layer
    n_j_pre = 1: (obj.bias_hidden + obj.ny_normal);
    % Contains the indices of memory units in hidden layer
    n_m_pre = (((obj.bias_hidden + obj.ny_normal) + 1): ...
        obj.ny + obj.bias_hidden);
    
    
    % Contains the indices of normal units in input layer postyn
    n_i_post = 1: obj.n_inputs;
    n_k_post =  obj.n_inputs+1: obj.n_inputs*2;        
    n_d_post = obj.n_inputs*2 + 1:obj.nx ;    
    n_j_post = 1:obj.ny_normal;    
    n_m_post = obj.ny_normal + 1: obj.ny ;

y_j = obj.Y(1:obj.ny_normal);
y_m = obj.Y(obj.ny_normal+1:obj.ny);
x_i = obj.X(1:obj.n_inputs);
x_k = obj.X(obj.n_inputs+1:obj.n_inputs*2);

obj.sum_t_xd = obj.sum_t_xd+obj.mem_input;
sum_t_xd = obj.sum_t_xd;
w_ja = obj.weights_yz(n_j_pre(2:end),obj.prev_action);
w_ma = obj.weights_yz(n_m_pre(2:end),obj.prev_action);


% Compute all the activ derivatives :
dsig_j = obj.hd_transform_normal_deriv(y_j);
dsig_k = obj.hd_transform_normal_deriv(x_k);
dsig_m = obj.hd_transform_normal_deriv(y_m);


A = repmat(sum_t_xd,n_m_pre* obj.weights_yx(n_m_pre, n_k_post))




%%
m_input =  repmat(sum_t_xd',1,  obj.ny_memory);

% Derivatives for memory hiddens:
d_hm = obj.hd_transform_memory_deriv(obj.Y(obj.ny_normal+1:end));

delta_hm = d_hm .* ...
    obj.weights_yz(n_m_pre, obj.prev_action)';

delta_hm_block = repmat(delta_hm,length(n_d_pre),1);

% Set the e-traces used in the update rule to the computed values:
A =  m_input.* delta_hm_block;
B = sum_t_xd' * delta_hm;



