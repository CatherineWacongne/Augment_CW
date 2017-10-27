function calc_Hiddens( obj )
%CALC_HIDDENS Calculate hidden unit activations


obj.prev_y1 = obj.Y1;
obj.prev_y1mod = obj.Y1mod;
obj.prev_y2 = obj.Y2;


% level 1
for f = 1:obj.n_hidden_features
    activations_normal = [obj.bias_input obj.X] * obj.v1{f} + obj.Xmod * obj.t1{f};
    normal_transformed = obj.hd_transform_normal(activations_normal);
    normal_transformed(activations_normal > 4) = activations_normal(activations_normal > 4);
    obj.Y1{f} = normal_transformed;
    
    
    modul_input = 0;
    for f2 = 1:obj.n_hidden_features
        modul_input = modul_input+ obj.Y2{f2} *obj.u2{f}{f2};
    end
    modul_normal = modul_input.*obj.Y1{f};
    modul_transformed = obj.hd_transform_normal(modul_normal );
    modul_transformed(modul_normal>4) = modul_normal(modul_normal>4);
    obj.Y1mod{f} = modul_transformed;
    
    
    
end

% level 2
for f2 = 1:obj.n_hidden_features
    activations_normal = 0*obj.Y2{f2};
    for f = 1:obj.n_hidden_features
        activations_normal = activations_normal + [obj.bias_input obj.Y1{f}] * obj.v2{f}{f2} + obj.Y1mod{f} * obj.t2{f}{f2};
    end
    normal_transformed = obj.hd_transform_normal(activations_normal);
    normal_transformed(activations_normal > 4) = activations_normal(activations_normal > 4);
    obj.Y2{f2} = normal_transformed;
end



end

