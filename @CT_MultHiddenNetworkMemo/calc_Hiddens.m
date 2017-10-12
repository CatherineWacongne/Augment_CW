function calc_Hiddens( obj )
%CALC_HIDDENS Calculate hidden unit activations

    modul_hidden =1;

    obj.prev_y = obj.Y;
    obj.prev_ym(2,:)= obj.prev_ym(1,:);
    obj.prev_ym(1,:) = obj.Ym;

    % Calculate activations of hidden neurons

    for f = 1:obj.n_hidden_features
        activations_normal = [obj.bias_input obj.X] * obj.weights_xy{f};
        
        % Calculate activations of 'instantanous/normal' hidden neurons
        normal_transformed = obj.hd_transform_normal(activations_normal);
        
        normal_transformed(activations_normal > 4) = activations_normal(activations_normal > 4);
        
        obj.mem_input = obj.dX;
        obj.Y_ma_current = obj.mem_input * obj.weights_dxym{f};
        obj.Y_ma_total = (obj.mem_decays .* obj.Y_ma_total) + obj.Y_ma_current;
        memory_transformed =  obj.hd_transform_normal(obj.Y_ma_total);
        memory_transformed(obj.Y_ma_total>4) = obj.Y_ma_total(obj.Y_ma_total>4);
           
        
        % modul_transformed = obj.hd_transform_memory(activation_modul);
        obj.Y{f}  = normal_transformed;% memory_transformed activation_modul ];%modul_transformed
        obj.Ym{f} = memory_transformed; 
    end
end

