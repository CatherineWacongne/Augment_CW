function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections


modul_input =  obj.Y(obj.ny_normal+1:end)* obj.weights_xy(obj.bias_input+1:obj.n_inputs+obj.bias_input, 1:obj.ny_normal)';%obj.hd_transform_normal_deriv(
modul_transformed = obj.hd_transform_normal((modul_input-mean(modul_input)).*obj.current_input*2);%+obj.current_input*2

obj.X = [obj.current_input modul_transformed];%modul_transformed

end
