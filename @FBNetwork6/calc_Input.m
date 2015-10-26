function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections


modul_input = [1 obj.Y(obj.ny_normal+1:end)]* obj.weights_yx([1 obj.ny_normal+1+obj.bias_hidden:end],obj.n_inputs*2+1:end);
modul_input = modul_input-mean(modul_input);
modul_input(modul_input>2) = 2;

% modul_transformed = obj.hd_transform_normal((modul_input-mean(modul_input)).*obj.current_input*2+obj.current_input*2);%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)
modul_transformed = obj.hd_transform_normal(modul_input.*obj.current_input +obj.current_input );%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)

d_pos = obj.current_input - obj.prev_input;
d_pos( d_pos < 0) = 0;

obj.X = [obj.current_input d_pos modul_transformed];%modul_transformed

end
