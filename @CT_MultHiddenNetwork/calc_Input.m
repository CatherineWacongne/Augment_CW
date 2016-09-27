function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections

modul_input = zeros(1,obj.n_inputs);
for f = 1:obj.n_hidden_features
    modul_input = modul_input+ obj.Y{f} *obj.weights_yx{f}(:,end/2+1:end);
end
% modul_transformed = obj.hd_transform_normal((modul_input-mean(modul_input)).*obj.current_input*2+obj.current_input*2);%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)
try
    modul_normal = modul_input.*obj.current_input;
    modul_transformed = obj.hd_transform_normal(modul_normal );%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)
    modul_transformed(modul_normal>4) = modul_normal(modul_normal>4);
catch
    keyboard
end
% d_pos = obj.current_input - obj.prev_input;
% d_pos( d_pos < 0) = 0;

obj.X = [obj.current_input  modul_transformed];%modul_transformed

end
