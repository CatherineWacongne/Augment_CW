function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections

% keeps the previous input in storage for trace computation
obj.prev_x = obj.X;
modul_input = zeros(1,obj.n_inputs);

% computes modul input 
for f = 1:obj.n_hidden_features
    modul_input = modul_input+ obj.Y{f} *obj.weights_yx{f}(:,end/2+1:end);
end

try
    modul_normal = modul_input.*obj.current_input;
    modul_transformed = obj.hd_transform_normal(modul_normal );
    modul_transformed(modul_normal>4) = modul_normal(modul_normal>4);
catch
    keyboard
end


obj.X = [obj.current_input  modul_transformed];%modul_transformed

end
