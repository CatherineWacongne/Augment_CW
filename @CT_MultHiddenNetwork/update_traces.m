function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces

% Contains the indices of normal units in input layer presyn
n_i_pre = 1: (obj.bias_input + obj.n_inputs);
% % Contains the indices of on cells units in input layer
% n_d_pre =  (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);
% Contains the indices of modulated units in input layer
n_k_pre = (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);

% Contains the indices of normal units in hidden layer
n_j_pre = 1: (obj.bias_hidden + obj.ny_normal);
% Contains the indices of memo units in hidden layer
% n_m_pre = (obj.bias_hidden + obj.ny_normal)+1:(obj.bias_hidden + obj.ny_normal)+obj.ny_memory;

% Contains the indices of normal and memory units in hidden layer postyn
n_j_post = 1:obj.ny_normal;
n_k_post = obj.n_inputs+1:obj.n_inputs*2;
% n_m_post = obj.ny_normal+1:obj.ny_normal+obj.ny_memory;

for f = 1:obj.n_hidden_features
    % For  hiddens
    obj.wxy_traces{f}([n_i_pre n_k_pre],1:obj.ny_normal) = obj.wxy_traces{f}([n_i_pre n_k_pre],1:obj.ny_normal)* obj.gamma * obj.lambda;
    obj.wyx_traces{f} = obj.wyx_traces{f}* obj.gamma * obj.lambda;
    % obj.wxy_traces(n_d_pre, n_m_post) = obj.wxy_traces(n_d_pre, n_m_post) .* obj.lambda_mem_arr;
    
    % For output traces:
    obj.wyz_traces{f} = obj.wyz_traces{f} * obj.gamma * obj.lambda;
    
    % obj.wyzs_traces = obj.wyzs_traces * obj.gamma * obj.lambda;
    % obj.wzzs_traces = obj.wzzs_traces * obj.gamma * obj.lambda;
end
%% Now, update the traces:
% If set (default: off) limit eligibility traces.
for f = 1:obj.n_hidden_features
    if (obj.limit_traces)
        
        wxy_idces = find(abs(obj.wxy_traces{f}) > 1);
        wyz_idces = find(abs(obj.wyz_traces{f}) > 1);
        wyx_idces = find(abs(obj.wyx_traces{f}) > 1);
        %     wyzs_idces = find(abs(obj.wyzs_traces) > 1);
        %     wzzs_idces = find(abs(obj.wzzs_traces) > 1);
        if ~isempty([wxy_idces; wyz_idces; wyx_idces]) %; wyzs_idces; wzzs_idces
            %         keyboard;
        end
        
        obj.wxy_traces{f}( wxy_idces ) = sign(obj.wxy_traces{f}( wxy_idces ) ) *1;
        obj.wyz_traces{f}( wyz_idces ) = sign(obj.wyz_traces{f}( wyz_idces ) ) *1;
        obj.wyx_traces{f}( wyx_idces ) = sign(obj.wyx_traces{f}( wyx_idces ) ) *1;
        %     obj.wyzs_traces( wyzs_idces ) = sign(obj.wyzs_traces( wyzs_idces ) ) *1;
        %     obj.wzzs_traces( wzzs_idces ) = sign(obj.wzzs_traces( wzzs_idces ) ) *1;
    end
    
    
    % basic variables
    y_j = obj.Y{f}(1:obj.ny_normal);
    % y_m = obj.Y(obj.ny_normal+1:obj.ny_normal+obj.ny_memory);
    x_i = obj.X(1:obj.n_inputs);
    % x_d = obj.X(obj.n_inputs+1:obj.n_inputs*2);
    x_k = obj.X(obj.n_inputs+1:obj.n_inputs*2);
    % y_s = obj.qas(1:obj.nzs);
    
    % obj.sum_t_xd = obj.sum_t_xd+obj.mem_input;
    % sum_t_xd = obj.sum_t_xd;
    
    
    w_ja = obj.weights_yz{f}(n_j_pre(2:end),obj.prev_action);
    w_kj = obj.weights_xy{f}(n_k_pre ,:);
    w_jk = obj.weights_yx{f}(:,n_k_post);
    
    % Compute all the activ derivatives :
    dsig_j = obj.hd_transform_normal_deriv(y_j);
    dsig_k = obj.hd_transform_normal_deriv(x_k);
%     dsig_j_prev = obj.hd_transform_normal_deriv(obj.prev_y{f}(1:obj.ny_normal));
    
    % if obj.prev_action<=obj.nzs % internal action
    obj.wyz_traces{f}([n_j_pre], obj.prev_action) =  obj.wyz_traces{f}([n_j_pre], obj.prev_action) + [obj.bias_hidden y_j ]';
    %     obj.wyz_traces(obj.weights_yz==0)=0;
    if obj.check_derivatives
        obj.new_traces{1}{f} =  obj.wyz_traces{f}*0;
        obj.new_traces{1}{f}([n_j_pre], obj.prev_action) =  [obj.bias_hidden y_j ]';
    end
    
    if obj.use_class_connections
        a = diag(ones(1,obj.grid_size^2));
        b = 0*obj.wyz_traces{f};
        b(3:end,2:end) = a;
        obj.wyz_traces{f}(b==1) = mean(obj.wyz_traces{f}(b==1));
        obj.wyz_traces{f}(1,2:end) = mean(obj.wyz_traces{f}(1,2:end));
    end
% %     if obj.use_class_connections
% %         for conn_type = 1:13;
%             obj.wyz_traces{f}(obj.wyz_class==conn_type) = mean(obj.wyz_traces{f}(obj.wyz_class==conn_type));
%         end
%     end
    obj.wyz_traces{f}(obj.weights_yz{f}==0)=0;  
    
    
    
    dPdwkj =  x_k' * (dsig_j .*  w_ja');
    dPdwkj2 = 0*dPdwkj;
    for f2 = 1:obj.n_hidden_features
        dsig_j_prev = obj.hd_transform_normal_deriv(obj.prev_y{f2}(1:obj.ny_normal));
        Int = dsig_j_prev' .*(w_jk *(x_i' .*dsig_k' .* (w_kj *(dsig_j' .*  w_ja))));
        dPdwkj2= dPdwkj2 + x_k' * (Int');
    end
    obj.wxy_traces{f}(n_k_pre, n_j_post) = obj.wxy_traces{f}(n_k_pre, n_j_post) + dPdwkj+dPdwkj2;
    
    
    dPdwij = [1; x_i'] * (dsig_j .*  w_ja');
    dPdwij2= [1; x_i'] * (Int');
    
    obj.wxy_traces{f}(n_i_pre, n_j_post) = obj.wxy_traces{f}(n_i_pre, n_j_post) + dPdwij + dPdwij2;
    obj.wxy_traces{f}(obj.weights_xy{f}==0)=0;
    
    
    if obj.check_derivatives
        obj.new_traces{2}{f} =  obj.wxy_traces{f}*0;
        obj.new_traces{2}{f}(n_k_pre, n_j_post) = dPdwkj + dPdwkj2;
        obj.new_traces{2}{f}(n_i_pre, n_j_post) = dPdwij + dPdwij2;
    end
    
    
    %     keyboard
    if obj.use_class_connections
        for conn_type = 1:12;
            obj.wxy_traces{f}(obj.wxy_class==conn_type) = mean(obj.wxy_traces{f}(obj.wxy_class==conn_type));
        end
    end
    obj.wxy_traces{f}(1,2:end) = mean(obj.wxy_traces{f}(1,2:end));
    obj.wxy_traces_now{f}([n_k_pre n_i_pre], n_j_post) = obj.wxy_traces{f}([n_k_pre n_i_pre], n_j_post);
    
    %     keyboard;
    dPdwjk =  ((dsig_j .*  w_ja')* w_kj').*dsig_k .* x_i;
    dPdwjk = obj.prev_y{f}' * dPdwjk;
    obj.wyx_traces{f}(:,n_k_post) = obj.wyx_traces{f}(:,n_k_post) + dPdwjk;
    obj.wyx_traces{f}(obj.weights_yx{f}==0)=0;
    if obj.use_class_connections
        for conn_type = 1:12;
            obj.wyx_traces{f}(obj.wyx_class==conn_type) = mean(obj.wyx_traces{f}(obj.wyx_class==conn_type));
        end
    end
    if obj.check_derivatives
        obj.new_traces{3}{f} =  obj.wyx_traces{f}*0;
        obj.new_traces{3}{f}(:,n_k_post) = dPdwjk;
    end
    
    
    wxy_idces = find(isnan(obj.wxy_traces{f}) );
    wyz_idces = find(isnan(obj.wyz_traces{f}));
    wyx_idces = find(isnan(obj.wyx_traces{f}) );
    if ~isempty([wxy_idces; wyz_idces; wyx_idces]) %; wyzs_idces; wzzs_idces
        keyboard;
    end
end
end





