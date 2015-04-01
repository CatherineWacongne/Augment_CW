function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces

% Contains the indices of normal units in input layer presyn
n_i_pre = 1: (obj.bias_input + obj.n_inputs);
% Contains the indices of modulated units in input layer
n_k_pre = (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);

% Contains the indices of normal units in hidden layer
n_j_pre = 1: (obj.bias_hidden + obj.ny_normal);


% Contains the indices of normal units in input layer postyn
n_j_post = 1:obj.ny_normal;


% For  hiddens
obj.wxy_traces = obj.wxy_traces * obj.gamma * obj.lambda;

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
    
    obj.wxy_traces( wxy_idces ) = sign(obj.wxy_traces( wxy_idces ) ) *1;
    obj.wyz_traces( wyz_idces ) = sign(obj.wyz_traces( wyz_idces ) ) *1; 
    obj.wyzs_traces( wyzs_idces ) = sign(obj.wyzs_traces( wyzs_idces ) ) *1; 
    obj.wzzs_traces( wzzs_idces ) = sign(obj.wzzs_traces( wzzs_idces ) ) *1;
end

% basic variables
y_j = obj.Y(1:obj.ny_normal);
x_i = obj.X(1:obj.n_inputs);
x_k = obj.X(obj.n_inputs+1:obj.n_inputs*2);
y_s = obj.qas(1:obj.nzs);


if obj.prev_action<=obj.nzs
    w_ja = obj.weights_yzs(n_j_pre(2:end),obj.prev_action);
else
%      w_ja = obj.weights_yz(n_j_pre(2:end),obj.prev_action-obj.nzs);
     w_ja = obj.weights_yzs(n_j_pre(2:end),obj.prev_action-obj.nzs);
     w_sa = obj.weights_zzs(2:end,obj.prev_action-obj.nzs);
end
% w_sa = obj.weights_zzs(2:end,obj.prev_action);


% Compute all the activ derivatives :
dsig_j = obj.hd_transform_normal_deriv(y_j);
dsig_s = obj.hd_transform_normal_deriv(y_s);



if obj.prev_action<=obj.nzs % internal action 
    obj.wyzs_traces(n_j_pre, obj.prev_action) =  obj.wyzs_traces(n_j_pre, obj.prev_action) + [obj.bias_hidden y_j]';
    
    dPdwkj =  x_k' * (dsig_j .*  w_ja');
    obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_ja');
    obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
    obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);
else
    
    obj.wyzs_traces(n_j_pre, obj.prev_action-obj.nzs) =  obj.wyzs_traces(n_j_pre, obj.prev_action-obj.nzs) + [obj.bias_hidden y_j]';
    
    dPdwkj =  x_k' * (dsig_j .*  w_ja');
    obj.wxy_traces(n_k_pre, n_j_post) = obj.wxy_traces(n_k_pre, n_j_post) + dPdwkj;
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_ja');
    obj.wxy_traces(n_i_pre, n_j_post) = obj.wxy_traces(n_i_pre, n_j_post) + dPdwij;
    obj.wxy_traces_now([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces([n_k_pre n_i_pre], n_j_post);
    
    
    
    
    
    mult = [1 zeros(1,obj.nz)];
    mult(obj.prev_action-obj.nzs+1) = 1;
    dzzs = mult.*[1 y_s];
    % for output traces
    obj.wzzs_traces(:, obj.prev_action-obj.nzs) = obj.wzzs_traces(:, obj.prev_action-obj.nzs) + dzzs';
    obj.wyz_traces(n_j_pre, obj.prev_action-obj.nzs) =  obj.wyz_traces(n_j_pre, obj.prev_action-obj.nzs) + [obj.bias_hidden y_j]';
    dsig_s = mult(2:end);%dsig_s .*0.5+.5*sign(y_s) .*
    dPdwjs = [1;y_j'] * (dsig_s .* w_sa');
    obj.wyzs_traces(n_j_pre,:) = obj.wyzs_traces(n_j_pre,:)+dPdwjs;
    
    
% for xy trace
    dPdwij1 = (dsig_s .* w_sa');
    dPdwij1 = (dPdwij1* obj.weights_yzs(n_j_pre(2:end),:)').*dsig_j;
    dPdwij1 = [1; x_i'; x_k']* dPdwij1;
%     dPdwij2 = [1; x_i'; x_k']* (dsig_j .* w_ja');

    obj.wxy_traces([n_i_pre n_k_pre], n_j_post) = obj.wxy_traces([n_i_pre n_k_pre], n_j_post) + dPdwij1;%+dPdwij2;


    obj.wxy_traces_now([n_i_pre n_k_pre], n_j_post) = obj.wxy_traces([n_i_pre n_k_pre], n_j_post);

end
end





