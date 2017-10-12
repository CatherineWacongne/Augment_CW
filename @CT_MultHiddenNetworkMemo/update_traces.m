function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces

% Contains the indices of normal units in input layer presyn
n_i_pre = 1: (obj.bias_input + obj.n_inputs);

% Contains the indices of modulated units in input layer
n_k_pre = (obj.bias_input + obj.n_inputs)+1: (obj.bias_input + obj.n_inputs*2);
n_don = 1:obj.n_inputs;
n_doff = obj.n_inputs+1:obj.n_inputs*2;
n_dmon = obj.n_inputs*2+1:obj.n_inputs*3;
n_dmoff = obj.n_inputs*3+1:obj.n_inputs*4;

% Contains the indices of normal units in hidden layer
n_j_pre = 1: (obj.bias_hidden + obj.ny_normal);


% Contains the indices of normal hidden and modulated units postyn
n_j_post = 1:obj.ny_normal;
n_k_post = obj.n_inputs+1:obj.n_inputs*2;

for f = 1:obj.n_hidden_features
    % For  hiddens
    obj.wxy_traces{f}   = obj.wxy_traces{f}  * obj.gamma * obj.lambda;
    obj.wdxym_traces{f} = obj.wdxym_traces{f}* obj.gamma * obj.lambda;
    
    obj.wymx_traces{f}  = obj.wymx_traces{f} * obj.gamma * obj.lambda;
        
    % For output traces:
    obj.wyz_traces{f}  = obj.wyz_traces{f}  * obj.gamma * obj.lambda;
    obj.wymz_traces{f} = obj.wymz_traces{f} * obj.gamma * obj.lambda;
    

end
%% Now, update the traces:
% If set (default: off) limit eligibility traces.
for f = 1:obj.n_hidden_features
    if (obj.limit_traces)
        % identify crazy high traces
        wxy_idces   = find(abs(obj.wxy_traces{f}) > 1);
        wdxym_idces = find(abs(obj.wdxym_traces{f}) > 1);
        
        wymx_idces  = find(abs(obj.wymx_traces{f}) > 1);
        
        wyz_idces   = find(abs(obj.wyz_traces{f}) > 1);
        wymz_idces  = find(abs(obj.wymz_traces{f}) > 1);
        
        
        % set them to 1 or -1 in function of their sign
        obj.wxy_traces{f}( wxy_idces ) = sign(obj.wxy_traces{f}( wxy_idces ) ) *1;
        obj.wdxym_traces{f}( wdxym_idces ) = sign(obj.wdxym_traces{f}( wdxym_idces ) ) *1;
        
        obj.wymx_traces{f}( wymx_idces ) = sign(obj.wymx_traces{f}( wymx_idces ) ) *1;
        
        obj.wyz_traces{f}( wyz_idces ) = sign(obj.wyz_traces{f}( wyz_idces ) ) *1;
        obj.wymz_traces{f}( wymz_idces ) = sign(obj.wymz_traces{f}( wymz_idces ) ) *1;
        
    end
    
    
    % basic variables for code readability
    % activity
    y_j = obj.Y{f}(1:obj.ny_normal); 
    y_m = obj.Ym{f}; 
    x_i = obj.X(1:obj.n_inputs);     
    x_k = obj.X(obj.n_inputs+1:obj.n_inputs*2);
    x_on   = obj.dX(n_don);
    x_off  = obj.dX(n_doff);
    x_mon  = obj.dX(n_dmon);
    x_moff = obj.dX(n_dmoff);
    prev_xi = obj.prev_x(1:obj.n_inputs); 
    prev_xk = obj.prev_x(obj.n_inputs+1:obj.n_inputs*2);
    prev_ym = obj.prev_ym{f}(1,:);
    prev_ym2 = obj.prev_ym{f}(2,:);
    
    %weights
    w_ja = obj.weights_yz{f}(n_j_pre(2:end),obj.prev_action);
    w_ma = obj.weights_ymz{f};
    v_ij = obj.weights_xy{f}(n_i_pre,1:obj.ny_normal);
    t_ij = obj.weights_xy{f}(n_k_pre,1:obj.ny_normal);
    u_ji = obj.weights_ymx{f}(:, n_k_post);
    v_on = obj.weights_dxym{f}(n_don,:);
    v_off = obj.weights_dxym{f}(n_doff,:);
    t_on = obj.weights_dxym{f}(n_dmon,:);
    t_off = obj.weights_dxym{f}(n_dmoff);
    
    % Compute all the activ derivatives :
    dsig_j = obj.hd_transform_normal_deriv(y_j);
    dsig_m = obj.hd_transform_normal_deriv(y_m);
    dsig_k = obj.hd_transform_normal_deriv(x_k);
    dsig_prevk = obj.hd_transform_normal_deriv(prev_xk);

    % useful intermediate quantities
    dwsigj = (dsig_j .*  w_ja');
    
    % Compute the actual update of traces
    
    % hidden to output: w_ja & w^M_ja
    obj.wyz_traces{f}([n_j_pre], obj.prev_action) =  obj.wyz_traces{f}([n_j_pre], obj.prev_action) + [obj.bias_hidden y_j ]';
    obj.wymz_traces{f}(:, obj.prev_action) = obj.wymz_traces{f}(:, obj.prev_action) + y_m';
    
    
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
        obj.wyz_traces{f}(2,2:end) = mean(obj.wyz_traces{f}(2,2:end));
        
        obj.wymz_traces{f}(1,2:end) = mean(obj.wymz_traces{f}(1,2:end));
        b = 0*obj.wymz_traces{f};
        b(2:end,2:end) = a;
        obj.wymz_traces{f}(b==1) = mean(obj.wymz_traces{f}(b==1));
    end
    obj.wyz_traces{f}(obj.weights_yz{f}==0)=0;  
    
    
    % normal input to hidden: v_ij & t_ij
    
    dPdtvij = [1 x_i x_k]' * dwsigj; 
    obj.wxy_traces{f} = obj.wxy_traces{f} + dPdtvij;

    if obj.use_class_connections
        for conn_type = 1:12;
            obj.wxy_traces{f}(obj.wxy_class==conn_type) = mean(obj.wxy_traces{f}(obj.wxy_class==conn_type));
        end
    end
    obj.wxy_traces{f}(1,2:end) = mean(obj.wxy_traces{f}(1,2:end));
    
    
    %% memory to modulated : u_ji
    % tags from the path trhough normal hidden
    Int1 = t_ij *dwsigj' *0;
    
    for j1 = 1:obj.n_hidden_features
        w_j1a = obj.weights_yz{j1}(n_j_pre(2:end),obj.prev_action);
        dsig_j1 = obj.hd_transform_normal_deriv(obj.Y{j1}(1:obj.ny_normal));
        t_ij1 = obj.weights_xy{j1}(n_k_pre,1:obj.ny_normal);
        Int1 = Int1+t_ij1 *(dsig_j1 .*  w_j1a')';
    end
    dPdui1 =  prev_ym *(x_i .*dsig_k) * Int1;
    
    % tags from the path through memory hidden
    dXimod_duji_t= prev_ym'*(x_i.*dsig_k);
    dXimod_duji_t1 = prev_ym2' *(prev_xi .* dsig_prevk);
    sum_t_dXmon_duji = sum_t_dXmon_duji+(ones(obj.ny_memory,1)*(x_mon>0)).* (dXimod_duji_t-dXimod_duji_t1);
    sum_t_dXmoff_duji = sum_t_dXmoff_duji+(ones(obj.ny_memory,1)*(x_moff>0)).* (dXimod_duji_t1- dXimod_duji_t);
    
    dPdui2 = dPdui1*0;
    for j2 = 1:obj.n_hidden_features
        dwsigmint = (obj.hd_transform_normal_deriv(obj.Ym{j2}) .*  obj.weights_ymz{j2}(:,obj.prev_action)');
        
        dPdui2 = dPdui2 + sum_t_dXmon_duji .* (ones(obj.ny_memory,1) * (dwsigmint*obj.weights_dxym{j2}(n_dmon,:)'));
        dPdui2 = dPdui2 + sum_t_dXmoff_duji .* (ones(obj.ny_memory,1) * (dwsigmint*obj.weights_dxym{j2}(n_dmoff,:)'));
    end
    
    obj.wymx_traces{f} = obj.wymx_traces{f} + dPdui1 + dPdui2;
    
    if obj.use_class_connections
        for conn_type = 1:12;
            obj.wymx_traces{f}(obj.wymx_class==conn_type) = mean(obj.wymx_traces{f}(obj.wymx_class==conn_type));
        end
    end
    
    %% Derivatives to hidden memory
    % direct path
    
    % indirect path 1 through modulatory -> Y normal 
    dPvijon1 = sum_t1_xon  * (dsig_ym_prev.*(u_ji * (Int1.*x_i.*dsig_k)));

    
    % indirect path 2 through mod -> deriv mON -> Ym
    
    % indirect path 3 through mod -> deriv moff -> Ym 
    
    
    
    wxy_idces = find(isnan(obj.wxy_traces{f}) );
    wyz_idces = find(isnan(obj.wyz_traces{f}));
    wyx_idces = find(isnan(obj.wyx_traces{f}) );
    if ~isempty([wxy_idces; wyz_idces; wyx_idces]) %; wyzs_idces; wzzs_idces
        keyboard;
    end
end
end





