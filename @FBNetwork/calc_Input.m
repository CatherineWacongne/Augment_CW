function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections

d_pos = [obj.current_input - obj.prev_input];
d_pos( d_pos < 0) = 0;
d_neg = [obj.current_input - obj.prev_input];
d_neg( d_neg > 0) = 0;


modul_input = obj.current_input + [ obj.Y(obj.ny_normal+1:end)]*...
    obj.weights_yx([obj.bias_hidden+obj.ny_normal+1:end],obj.n_inputs+1:obj.n_inputs*2);

modul_transformed = obj.hd_transform_normal(modul_input);

obj.X = [obj.current_input modul_transformed d_pos abs(d_neg)];

end
