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



%% Now, update the traces:
% If set (default: off) limit eligibility traces.
if (obj.limit_traces)
    
    wxy_idces = find(abs(obj.wxy_traces) > 1);
    wyz_idces = find(abs(obj.wyz_traces) > 1);   
    wyx_idces = find(abs(obj.wyx_traces) > 1);
    if ~isempty([wxy_idces; wyz_idces; wyx_idces])
%         keyboard;
    end
    
    obj.wxy_traces( wxy_idces ) = sign(obj.wxy_traces( wxy_idces ) ) *1;
    obj.wyz_traces( wyz_idces ) = sign(obj.wyz_traces( wyz_idces ) ) *1; 
    obj.wyx_traces( wyx_idces ) = sign(obj.wyx_traces( wyx_idces ) ) *1; 
   
end

% basic variables
y_j = obj.Y(1:obj.ny_normal);
y_m = obj.Y(obj.ny_normal+1:obj.ny_normal+obj.ny_memory);
x_i = obj.X(1:obj.n_inputs);
% x_d = obj.X(obj.n_inputs+1:obj.n_inputs*2);
x_k = obj.X(obj.n_inputs*2+1:obj.n_inputs*3);


obj.sum_t_xd = obj.sum_t_xd+obj.mem_input;
sum_t_xd = obj.sum_t_xd; 





w_jam = obj.weights_yz(n_j_pre(2:end),obj.prev_action);
w_mam = obj.weights_yz(n_m_pre,obj.prev_action);
w_kj =  obj.weights_xy(n_k_pre,n_j_post);
% w_sa = obj.weights_zzs(2:end,obj.prev_action);


% Compute all the activ derivatives :
dsig_j = obj.hd_transform_normal_deriv(y_j);
dsig_m = obj.hd_transform_normal_deriv(y_m);
dsig_k = obj.hd_transform_normal_deriv(x_k);




%FB from the motor unit
% going directly from motor
obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action) =  obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action) + [obj.bias_hidden y_j y_m]';

if 1
    dPdwkj =  x_k' * (dsig_j .*  w_jam');
    obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_jam');
    obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
    obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);
    
    
    dPdwdm = sum_t_xd' * (dsig_m .*  w_mam');
    obj.wxy_traces_now(n_d_pre, n_m_post) = obj.wxy_traces_now(n_d_pre, n_m_post) + dPdwdm;
end
dPdwmk = (w_kj*(dsig_j' .*  w_jam)).*dsig_k'.*x_i';
dPdwmk =[1; y_m']*dPdwmk';
obj.wyx_traces([1 n_m_pre], n_k_pre-1) = obj.wyx_traces([1 n_m_pre], n_k_pre-1) + dPdwmk;
   
    
%     obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) =  obj.wyz_traces([n_j_pre n_m_pre], obj.prev_action-obj.nzs) + [obj.bias_hidden y_j y_m]';
    
%     obj.wxy_traces_now(obj.bias_input+obj.n_inputs*2-1:obj.bias_input+obj.n_inputs*2,obj.ny_normal+1:obj.ny_normal+obj.ny_memory)=0;

end





