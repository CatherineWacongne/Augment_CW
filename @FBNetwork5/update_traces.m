function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces

% Contains the indices of normal units in input layer presyn
n_i_pre = 1: (obj.bias_input + obj.n_inputs);
% Contains the indices of on cells units in input layer
n_d_pre =  (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);
% Contains the indices of modulated units in input layer
n_k_pre = (obj.bias_input + obj.n_inputs*2)+1: (obj.bias_input + obj.n_inputs*3);

% Contains the indices of normal units in hidden layer
n_j_pre = 1: (obj.bias_hidden + obj.ny_normal);
% Contains the indices of memo units in hidden layer
n_m_pre = (obj.bias_hidden + obj.ny_normal)+1:(obj.bias_hidden + obj.ny_normal)+obj.ny_memory;

% Contains the indices of normal and memory units in hidden layer postyn
n_j_post = 1:obj.ny_normal;
n_m_post = obj.ny_normal+1:obj.ny_normal+obj.ny_memory;

% For  hiddens
obj.wxy_traces([n_i_pre n_k_pre],1:obj.ny_normal) = obj.wxy_traces([n_i_pre n_k_pre],1:obj.ny_normal)* obj.gamma * obj.lambda;
obj.wxy_traces(n_d_pre, n_m_post) = obj.wxy_traces(n_d_pre, n_m_post) .* obj.lambda_mem_arr;

% For output traces:
obj.wyz_traces = obj.wyz_traces * obj.gamma * obj.lambda;

obj.wyzs_traces = obj.wyzs_traces * obj.gamma * obj.lambda;
obj.wzzs_traces = obj.wzzs_traces * obj.gamma * obj.lambda;
%% Now, update the traces:
% If set (default: off) limit eligibility traces.
if (obj.limit_traces)
    
    wxy_idces = find(abs(obj.wxy_traces) > 1);
    wyz_idces = find(abs(obj.wyz_traces) > 1);   
    wyzs_idces = find(abs(obj.wyzs_traces) > 1);  
    wzzs_idces = find(abs(obj.wzzs_traces) > 1);
    if ~isempty([wxy_idces; wyz_idces; wyzs_idces; wzzs_idces])
%         keyboard;
    end
    
    obj.wxy_traces( wxy_idces ) = sign(obj.wxy_traces( wxy_idces ) ) *1;
    obj.wyz_traces( wyz_idces ) = sign(obj.wyz_traces( wyz_idces ) ) *1; 
    obj.wyzs_traces( wyzs_idces ) = sign(obj.wyzs_traces( wyzs_idces ) ) *1; 
    obj.wzzs_traces( wzzs_idces ) = sign(obj.wzzs_traces( wzzs_idces ) ) *1;
end

% basic variables
y_j = obj.Y(1:obj.ny_normal);
y_m = obj.Y(obj.ny_normal+1:obj.ny_normal+obj.ny_memory);
x_i = obj.X(1:obj.n_inputs);
% x_d = obj.X(obj.n_inputs+1:obj.n_inputs*2);
x_k = obj.X(obj.n_inputs*2+1:obj.n_inputs*3);
y_s = obj.qas(1:obj.nzs);

obj.sum_t_xd = obj.sum_t_xd+obj.mem_input;
sum_t_xd = obj.sum_t_xd; 

if obj.prev_action<=obj.nzs
    w_ja = obj.weights_yzs(n_j_pre(2:end),obj.prev_action);
    w_ma = obj.weights_yzs(n_m_pre,obj.prev_action);
    
else
%      w_ja = obj.weights_yz(n_j_pre(2:end),obj.prev_action-obj.nzs);
     w_ja = obj.weights_yzs(n_j_pre(2:end),obj.prev_action-obj.nzs);
     w_sa = obj.weights_zzs(1:end,obj.prev_action-obj.nzs);
     w_ma = obj.weights_yzs(n_m_pre,obj.prev_action-obj.nzs);
     w_jam = obj.weights_yz(n_j_pre(2:end),obj.prev_action-obj.nzs);
     w_mam = obj.weights_yz(n_m_pre,obj.prev_action-obj.nzs);
end
% w_sa = obj.weights_zzs(2:end,obj.prev_action);


% Compute all the activ derivatives :
dsig_j = obj.hd_transform_normal_deriv(y_j);
dsig_s = obj.hd_transform_normal_deriv(y_s);
dsig_m = obj.hd_transform_normal_deriv(y_m);


if obj.prev_action<=obj.nzs % internal action 
    obj.wyzs_traces([n_j_pre n_m_pre], obj.prev_action) =  obj.wyzs_traces([n_j_pre n_m_pre], obj.prev_action) + [obj.bias_hidden y_j y_m]';
    
    dPdwkj =  x_k' * (dsig_j .*  w_ja');
    obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_ja');
    obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
    obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);
    
    dPdwdm = sum_t_xd' * (dsig_m .*  w_ma');  
    obj.wxy_traces_now(n_d_pre, n_m_post) = obj.wxy_traces_now(n_d_pre, n_m_post) + dPdwdm;
    
%     obj.wxy_traces_now(obj.bias_input+obj.n_inputs*2-1:obj.bias_input+obj.n_inputs*2,obj.ny_normal+1:obj.ny_normal+obj.ny_memory)=0;
else
    %tags from the internal unit action 
    obj.wyzs_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) =  obj.wyzs_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) + [obj.bias_hidden y_j y_m]';
    
    dPdwkj =  x_k' * (dsig_j .*  w_ja');
    obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_ja');
    obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
    obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);
    
    
    dPdwdm = sum_t_xd' * (dsig_m .*  w_ma');  
    obj.wxy_traces_now(n_d_pre, n_m_post) = obj.wxy_traces_now(n_d_pre, n_m_post) + dPdwdm;
    
    %FB from the motor unit 
        % going directly from motor
    obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) =  obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) + [obj.bias_hidden y_j y_m]';
    
    if 1
    dPdwkj =  x_k' * (dsig_j .*  w_jam');
    obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_jam');
    obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
    obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);
    
    
    dPdwdm = sum_t_xd' * (dsig_m .*  w_mam');  
    obj.wxy_traces_now(n_d_pre, n_m_post) = obj.wxy_traces_now(n_d_pre, n_m_post) + dPdwdm;
    end    
        
    
        % going through internal 
    mult = [zeros(1,obj.nz)];
    mult(obj.prev_action-obj.nzs) = 1;
    dzzs = mult.*[y_s];
    % for output traces
    obj.wzzs_traces(:, obj.prev_action-obj.nzs) = obj.wzzs_traces(:, obj.prev_action-obj.nzs) + dzzs';
%     obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) =  obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) + [obj.bias_hidden y_j y_m]';
    if 0
    dsig_s = mult;%dsig_s .*0.5+.5*sign(y_s) .*
    dPdwjs = [1;y_j'] * (dsig_s .* w_sa');
    obj.wyzs_traces(n_j_pre,:) = obj.wyzs_traces(n_j_pre,:)+dPdwjs;
          % for xy trace
    dPdwij1 = (dsig_s .* w_sa');
    dPdwij1 = (dPdwij1* obj.weights_yzs(n_j_pre(2:end),:)').*dsig_j;
    dPdwij1 = [1; x_i'; x_k']* dPdwij1;
%     dPdwij2 = [1; x_i'; x_k']* (dsig_j .* w_ja');
% 
    obj.wxy_traces_now([n_i_pre n_k_pre], n_j_post) = obj.wxy_traces_now([n_i_pre n_k_pre], n_j_post) + dPdwij1;%+dPdwij2;
    
    dPdwdm =(dsig_s .* w_sa');
    dPdwdm = (dPdwdm* obj.weights_yzs(n_m_pre,:)').*dsig_m;
    dPdwdm = sum_t_xd' * dPdwdm;  
    obj.wxy_traces_now(n_d_pre, n_m_post) = obj.wxy_traces_now(n_d_pre, n_m_post) + dPdwdm;


%     obj.wxy_traces_now([n_i_pre n_k_pre], n_j_post) = obj.wxy_traces([n_i_pre n_k_pre], n_j_post);
    
    end
%     obj.wxy_traces_now(obj.bias_input+obj.n_inputs*2-1:obj.bias_input+obj.n_inputs*2,obj.ny_normal+1:obj.ny_normal+obj.ny_memory)=0;
end
end





