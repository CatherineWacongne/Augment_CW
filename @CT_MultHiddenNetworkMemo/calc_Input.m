function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections

% keeps the previous input in storage for trace computation
obj.prev_x = obj.X;
obj.prev_dx = obj.dX;
modul_input = zeros(1,obj.n_inputs);

% computes modul input 
for f = 1:obj.n_hidden_features
    modul_input = modul_input+ obj.Y{f} *obj.weights_ymx{f}(:,end/2+1:end);
end

try
    modul_normal = modul_input.*obj.current_input;
    modul_transformed = obj.hd_transform_normal(modul_normal );
    modul_transformed(modul_normal>4) = modul_normal(modul_normal>4);
catch
    keyboard
end

% computes derivatives 
delta = obj.current_input - obj.prev_x(1:obj.n_inputs);
dpos = delta.*(delta>0);
dneg = -delta.*(delta<0);

delta_m = modul_transformed- obj.prev_x(1+obj.n_inputs:end);
dmpos = delta_m.*(delta_m>0);
dmneg = -delta_m.*(delta_m<0);


obj.X = [obj.current_input  modul_transformed];%modul_transformed
obj.dX = [dpos dneg dmpos dmneg];

end
