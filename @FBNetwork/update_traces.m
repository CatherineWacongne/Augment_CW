function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces
if ~(strcmp(obj.input_method, 'modulposneg'))
    %% Decay the traces
    
    % Contains the indices of normal units in input layer
    n_xyr = 1: (obj.bias_input + obj.n_inputs);
    
    
    % Contains the indices of differentiating units in input layer
    m_xyr = (obj.bias_input + obj.n_inputs + 1):(obj.nx + obj.bias_input);
    
    % Contains the indices of normal units in hidden layer
    n_yzr = 1: (obj.bias_hidden + obj.ny_normal);
    % Contains the indices of memory units in hidden layer
    m_yzr = (((obj.bias_hidden + obj.ny_normal) + 1): ...
        obj.ny + obj.bias_hidden);
    
    % For normal hiddens
    obj.wxy_traces(n_xyr,1:obj.ny_normal) = ...
        obj.wxy_traces(n_xyr,1:obj.ny_normal) * ...
        obj.gamma * obj.lambda;
    
    % For memory hiddens
    obj.wxy_traces(m_xyr, (obj.ny_normal + 1): end) = ...
        obj.wxy_traces(m_xyr, (obj.ny_normal + 1): end) .* ...
        obj.lambda_mem_arr;
    
    % For output traces:
    obj.wyz_traces = obj.wyz_traces * obj.gamma * obj.lambda;
    
    
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
        
        obj.wxy_traces( wxy_idces ) = sign(obj.wxy_traces( wxy_idces ) ) *2;
        obj.wyz_traces( wyz_idces ) = sign(obj.wyz_traces( wyz_idces ) ) *2;
        
    end
    
    % Update hidden units: first normal units, then memory units
    % Note that these depend on the sigmoid activation functions.
    
    % Input to Hidden_normal traces
    input = repmat([obj.bias_input obj.X(1:obj.n_inputs)]',1,  obj.ny_normal);
    
    % Derivatives for normal hiddens:
    d_hn = obj.hd_transform_normal_deriv(obj.Y(1:obj.ny_normal));
    
    delta_hn = [obj.bias_hidden d_hn] .* ...
        obj.weights_yz(n_yzr, obj.prev_action)';
    
    delta_hn_block = repmat(delta_hn(1+obj.bias_hidden:end), ...
        obj.n_inputs + obj.bias_input,1);
    
    obj.wxy_traces(n_xyr, 1:obj.ny_normal) =  ...
        obj.wxy_traces(n_xyr, 1:obj.ny_normal) + input .* delta_hn_block;
    
    % Set the e-traces used in the update rule to the computed values:
    obj.wxy_traces_now(n_xyr, 1:obj.ny_normal) = obj.wxy_traces(n_xyr, 1:obj.ny_normal);
    
    
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
    
else
    %% Decay the traces
    
    % Contains the indices of normal units in input layer presyn
    n_i_pre = 1: (obj.bias_input + obj.n_inputs);
    % Contains the indices of modulated units in input layer
    n_k_pre = (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);
        % Contains the indices of differentiating units in input layer
    n_d_pre = (obj.bias_input + obj.n_inputs*2 + 1):(obj.nx + obj.bias_input);
    
    % Contains the indices of normal units in hidden layer
    n_j_pre = 1: (obj.bias_hidden + obj.ny_normal);
    % Contains the indices of memory units in hidden layer
    n_m_pre = [1 (((obj.bias_hidden + obj.ny_normal) + 1): ...
        obj.ny + obj.bias_hidden)];
    
    
    % Contains the indices of normal units in input layer postyn
    n_i_post = 1: obj.n_inputs;
    n_k_post =  obj.n_inputs+1: obj.n_inputs*2;        
    n_d_post = obj.n_inputs*2 + 1:obj.nx ;    
    n_j_post = 1:obj.ny_normal;    
    n_m_post = obj.ny_normal + 1: obj.ny ;
    
    % For normal hiddens
    obj.wxy_traces(n_i_pre,n_j_post) = ...
        obj.wxy_traces(n_i_pre,n_j_post) * ...
        obj.gamma * obj.lambda;
    
    % For memory hiddens
    obj.wxy_traces_now(n_d_pre, (obj.ny_normal + 1): end) = ...
        obj.wxy_traces(n_d_pre, (obj.ny_normal + 1): end) .* ...
        obj.lambda_mem_arr;
    
    % For output traces:
    obj.wyz_traces = obj.wyz_traces * obj.gamma * obj.lambda;
    
    % For modul traces:
    obj.wyx_traces = obj.wyx_traces * obj.gamma * obj.lambda;
    
    %% Now, update the traces:
    % If set (default: off) limit eligibility traces.
    if (obj.limit_traces)
        
        wxy_idces = find(abs(obj.wxy_traces) > 2);
        wyz_idces = find(abs(obj.wyz_traces) > 2);
        wyx_idces = find(abs(obj.wyx_traces) > 2);
        
        obj.wxy_traces( wxy_idces ) = sign(obj.wxy_traces( wxy_idces ) ) *2;
        obj.wyz_traces( wyz_idces ) = sign(obj.wyz_traces( wyz_idces ) ) *2;
        obj.wyx_traces( wyx_idces ) = sign(obj.wyx_traces( wyx_idces ) ) *2;
        
    end
        
    % basic variables
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
    
    % for output traces
    obj.wyz_traces(:, obj.prev_action) =  obj.wyz_traces(:, obj.prev_action) + [obj.bias_hidden obj.Y]';
    
    % for yx trace
    interm1 = obj.weights_xy(n_k_pre, n_j_post)* ([dsig_j]'.* w_ja) ; %k x 1;
    dPdwmk = [y_m'] * (interm1'.*dsig_k);%1; 
    obj.wyx_traces(n_m_pre(2:end), n_k_post) = obj.wyx_traces(n_m_pre(2:end), n_k_post) + 1*dPdwmk;
    
    % for xy trace
    dPdwkj =  x_k' * (dsig_j .*  w_ja'); 
    obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_ja'); 
    obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
    obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);
    
    Aint1 = (obj.weights_xy(n_k_pre, n_j_post)* ([dsig_j]'.* w_ja)).* dsig_k';% k x 1
    Aint2 = obj.weights_yx(n_m_pre(2:end), n_k_post) * Aint1; %m x 1
    A = sum_t_xd' * (Aint2'.* dsig_m);
    B = sum_t_xd' * (dsig_m .*  w_ma'); 
    dPdwdm = A+B;
    obj.wxy_traces_now(n_d_pre, n_m_post) = obj.wxy_traces_now(n_d_pre, n_m_post) + dPdwdm;
end

end

