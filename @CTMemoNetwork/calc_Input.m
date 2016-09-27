function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections


modul_input =  obj.Y *obj.weights_yx(:,end/2+1:end); 
modul_normal = modul_input.*obj.current_input;
delta_modul_input = modul_normal - obj.prev_input_mod;
obj.prev_input_mod = modul_normal;
% modul_transformed = obj.hd_transform_normal((modul_input-mean(modul_input)).*obj.current_input*2+obj.current_input*2);%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)
try
modul_transformed = obj.hd_transform_normal(delta_modul_input );%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)
modul_transformed(delta_modul_input>4) = delta_modul_input(delta_modul_input>4);
catch
    keyboard
end
% d_pos = obj.current_input - obj.prev_input;
% d_pos( d_pos < 0) = 0;
obj.prev_x = obj.X(1:obj.n_inputs);
obj.X = [obj.current_input  modul_transformed];%modul_transformed
obj.sum_t_xd = obj.sum_t_xd+modul_transformed;
end
