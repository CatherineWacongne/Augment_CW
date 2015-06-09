function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections


modul_input =  obj.Y(obj.ny/2+1:obj.ny/2+obj.ny_normal)* obj.weights_xy(obj.bias_input+1:obj.n_inputs+obj.bias_input, 1:obj.ny_normal)'+ ... 
    obj.Y(obj.ny/2+obj.ny_normal+1:end)* obj.weights_xy(obj.n_inputs+obj.bias_input+1:obj.n_inputs*2+obj.bias_input, obj.ny_normal+1:obj.ny_normal+obj.ny_memory)';
modul_transformed = obj.hd_transform_normal((modul_input-mean(modul_input)).*obj.current_input*2+obj.current_input*2);%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)

d_pos = obj.current_input - obj.prev_input;
d_pos( d_pos < 0) = 0;

obj.X = [obj.current_input d_pos modul_transformed];%modul_transformed

end
