function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections

% keeps the previous input in storage for trace computation
obj.prev_x = obj.X;
obj.prev_xmod = obj.Xmod;
modul_input = zeros(1,obj.n_inputs);

% computes modul input 
for f = 1:obj.n_hidden_features
    modul_input = modul_input+ obj.Y1{f} *obj.u1{f}+obj.Y1{f} *obj.u1{f};
end

try
    modul_normal = modul_input.*obj.current_input;
    modul_transformed = obj.hd_transform_normal(modul_normal );
    modul_transformed(modul_normal>4) = modul_normal(modul_normal>4);
catch
    keyboard
end


obj.X = [obj.current_input ];%modul_transformed
obj.Xmod = modul_transformed;

end
