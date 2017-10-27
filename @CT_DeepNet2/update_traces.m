function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces

%% decay the traces
for f = 1:obj.n_hidden_features
    obj.v1_traces{f} = obj.v1_traces{f} * obj.gamma * obj.lambda;
    obj.t1_traces{f} = obj.t1_traces{f} * obj.gamma * obj.lambda;
    obj.u1_traces{f} = obj.u1_traces{f} * obj.gamma * obj.lambda;
    obj.u1mod_traces{f} = obj.u1mod_traces{f} * obj.gamma * obj.lambda;
    for f2 = 1:obj.n_hidden_features
        obj.v2_traces{f}{f2} = obj.v2_traces{f}{f2} * obj.gamma * obj.lambda;
        obj.t2_traces{f}{f2} = obj.t2_traces{f}{f2} * obj.gamma * obj.lambda;
        obj.u2_traces{f}{f2} = obj.u2_traces{f}{f2} * obj.gamma * obj.lambda;
    end
    obj.w_traces{f} = obj.w_traces{f} * obj.gamma * obj.lambda;
end
%% Now, update the traces:

%%     % Compute the actual update of traces
% w
for f = 1:obj.n_hidden_features
    obj.w_traces{f}(:, obj.prev_action) =   obj.w_traces{f}(:, obj.prev_action) + [obj.bias_hidden obj.Y2{f} ]';
end

dPinpY2 = cell(1,obj.n_hidden_features);
% v2 / t2 direct
for f2 = 1:obj.n_hidden_features
    dsig_j2 = obj.hd_transform_normal_deriv(obj.Y2{f2});
    w_j2a = obj.w{f2}(2:end, obj.prev_action);
    dPinpY2{f2} =  (w_j2a' .* dsig_j2) ;
    for f1 = 1:obj.n_hidden_features
        % v2 & t2(f is feature for Y1 and f2 is feature for Y2)
        % direct pathway
        obj.v2_traces{f1}{f2} = obj.v2_traces{f1}{f2} + [1 obj.Y1{f1}]'* dPinpY2{f2} ;
        obj.t2_traces{f1}{f2} = obj.t2_traces{f1}{f2} + obj.Y1mod{f1}'* dPinpY2{f2} ;
        
    end
end

% v1/ t1 direct & dPinpY1mod
dPinpY1 = cell(1,obj.n_hidden_features);
dPinpY1mod = cell(1,obj.n_hidden_features);
for f1 = 1:obj.n_hidden_features
    dPinpY1{f1} = zeros(1, obj.ny);
    dPinpY1mod{f1} = zeros(1, obj.ny);
    dsig_y1 = obj.hd_transform_normal_deriv(obj.Y1{f1});
    dsig_y1mod = obj.hd_transform_normal_deriv(obj.Y1mod{f1});
    for f2 = 1:obj.n_hidden_features
        dPinpY1{f1} = dPinpY1{f1} + (dPinpY2{f2} *obj.v2{f1}{f2}(2:end,:)').* dsig_y1;
        dPinpY1mod{f1} = dPinpY1mod{f1} + (dPinpY2{f2} *obj.t2{f1}{f2}').* dsig_y1mod;
    end   
end

for f1 = 1:obj.n_hidden_features
    for f2 = 1:obj.n_hidden_features
        dPinpY1{f1} = dPinpY1{f1} +    (obj.prev_y2{f2} * obj.u2{f1}{f2}').* dPinpY1mod{f1}.* dsig_y1;
    end
end

for f1 = 1:obj.n_hidden_features
    obj.v1_traces{f1} = obj.v1_traces{f1} + [1 obj.X]'* dPinpY1{f1} ;
    obj.t1_traces{f1} = obj.t1_traces{f1} + obj.Xmod' * dPinpY1{f1} ;
end


% u2
for f2 = 1:obj.n_hidden_features
    for f1 = 1:obj.n_hidden_features
        obj.u2_traces{f1}{f2} = obj.u2_traces{f1}{f2} + obj.Y2{f2}' * (obj.Y1{f1}.*dPinpY1mod{f1});
    end
    
end

% dPinpXmod
dPinpXmod = zeros(1,obj.nx);
for f1 = 1:obj.n_hidden_features
    dPinpXmod = dPinpXmod + (dPinpY1{f1} * obj.t1{f1}') .* obj.hd_transform_normal_deriv(obj.Xmod);
end

% u1 & u1 mod
for f1 = 1:obj.n_hidden_features
    obj.u1_traces{f1} =  obj.u1_traces{f1} + obj.prev_y1{f1}'*(dPinpXmod.*obj.X);
    obj.u1mod_traces{f1} =  obj.u1mod_traces{f1} + obj.prev_y1mod{f1}'*(dPinpXmod.*obj.X);
end



% dPinp_prevY2 
dPinp_prevY2 = cell(1,obj.n_hidden_features);
for f2 = 1:obj.n_hidden_features
    dPinp_prevY2{f2} = zeros(1,obj.ny);
    for f1 = 1:obj.n_hidden_features
        dPinp_prevY2{f2} = dPinp_prevY2{f2} + ((dPinpY1mod{f1}.* obj.Y1{f1}) * obj.u2{f1}{f2}').*obj.hd_transform_normal_deriv(obj.prev_y2{f2});
    end
    
end

% v2/t2 indirect 
for f1 = 1:obj.n_hidden_features
    for f2 = 1:obj.n_hidden_features
        obj.v2_traces{f1}{f2} = obj.v2_traces{f1}{f2} + [1 obj.prev_y1{f1}]'* dPinp_prevY2{f2} ;
        obj.t2_traces{f1}{f2} = obj.t2_traces{f1}{f2} + obj.prev_y1mod{f1}' * dPinp_prevY2{f2} ;
    end
end


% dPinp_prevY1 
dPinp_prevY1 = cell(1,obj.n_hidden_features);
for f1 = 1:obj.n_hidden_features    
    dPinp_prevY1{f1} =((dPinpXmod.* obj.X) * obj.u1{f1}').*obj.hd_transform_normal_deriv(obj.prev_y1{f1});
end

% % v1/t1 indirect 
for f1 = 1:obj.n_hidden_features
    obj.v1_traces{f1} = obj.v1_traces{f1} + [1 obj.prev_x]'* dPinp_prevY1{f1} ;
    obj.t1_traces{f1} = obj.t1_traces{f1} + obj.prev_xmod' * dPinp_prevY1{f1} ;
end


%% weight sharing
if obj.use_class_connections
    
    for conn_type = 1:12
        ind_v1 = find(obj.v1_class==conn_type);
        ind_t1 = find(obj.t1_class==conn_type);
        ind_u1 = find(obj.u1_class==conn_type);
        ind_v2 = find(obj.v2_class==conn_type);
        ind_t2 = find(obj.t2_class==conn_type);
        ind_u2 = find(obj.u2_class==conn_type);
        ind_w = find(obj.w_class==conn_type);
        for f1 = 1:obj.n_hidden_features
            
            obj.v1_traces{f1}(ind_v1) = mean(obj.v1_traces{f1}(ind_v1));
            obj.t1_traces{f1}(ind_t1) = mean(obj.t1_traces{f1}(ind_t1));
            obj.u1_traces{f1}(ind_u1) = mean(obj.u1_traces{f1}(ind_u1));
            obj.u1mod_traces{f1}(ind_u1) = mean(obj.u1mod_traces{f1}(ind_u1));
            for f2 = 1:obj.n_hidden_features
                obj.v2_traces{f1}{f2}(ind_v2) = mean(obj.v2_traces{f1}{f2}(ind_v2));
                obj.t2_traces{f1}{f2}(ind_t2) = mean(obj.t2_traces{f1}{f2}(ind_t2));
                obj.u2_traces{f1}{f2}(ind_u2) = mean(obj.u2_traces{f1}{f2}(ind_u2));
            end
            obj.w_traces{f1}(ind_w) = mean(obj.w_traces{f1}(ind_w));
        end
    end
    
    
end



%% limit eligibility traces
for f = 1:obj.n_hidden_features
    % If set (default: off) limit eligibility traces.
    if (obj.limit_traces)
        v1_idces = find(abs(obj.v1_traces{f}) > 1);
        t1_idces = find(abs(obj.t1_traces{f}) > 1);
        u1_idces = find(abs(obj.u1_traces{f}) > 1);
        u1mod_idces = find(abs(obj.u1mod_traces{f}) > 1);
        w_idces = find(abs(obj.w_traces{f}) > 1);
        
        obj.v1_traces{f}( v1_idces ) = sign(obj.v1_traces{f}( v1_idces ) ) *1;
        obj.t1_traces{f}( t1_idces ) = sign(obj.t1_traces{f}( t1_idces ) ) *1;
        obj.u1_traces{f}( u1_idces ) = sign(obj.u1_traces{f}( u1_idces ) ) *1;
        obj.u1mod_traces{f}( u1mod_idces ) = sign(obj.u1mod_traces{f}( u1mod_idces ) ) *1;
        obj.w_traces{f}( w_idces ) = sign(obj.w_traces{f}( w_idces ) ) *1;
        for f2 = 1:obj.n_hidden_features
            v2_idces = find(abs(obj.v2_traces{f}{f2}) > 1);
            t2_idces = find(abs(obj.t2_traces{f}{f2}) > 1);
            u2_idces = find(abs(obj.u2_traces{f}{f2}) > 1);
            obj.v2_traces{f}{f2}( v2_idces ) = sign(obj.v2_traces{f}{f2}( v2_idces ) ) *1;
            obj.t2_traces{f}{f2}( t2_idces ) = sign(obj.t2_traces{f}{f2}( t2_idces ) ) *1;
            obj.u2_traces{f}{f2}( u2_idces ) = sign(obj.u2_traces{f}{f2}( u2_idces ) ) *1;
        end
    end
end


