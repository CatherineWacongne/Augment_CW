function calc_Hiddens( obj )
%CALC_HIDDENS Calculate hidden unit activations

%% Normal Hidden

inpj = [1 obj.Xi] * obj.weights_xiyj + obj.Xk * obj.weights_xkyj; 
obj.Yj = obj.hd_transform_normal(inpj);
obj.Yj(inpj > 4) = inpj(inpj > 4); % makes sure that the transform does not give NaN for large values due to computer precision


%% Memory Hidden
obj.prev_ym(2,:) = obj.prev_ym(1,:);
obj.prev_ym(1,:) = obj.Ym;

obj.Y_ma_current = obj.Xon * obj.weights_xonym + obj.Xoff * obj.weights_xoffym +...
    obj.Xkon * obj.weights_xkonym + obj.Xkoff * obj.weights_xkoffym;
obj.Y_ma_total =  obj.Y_ma_total + obj.Y_ma_current;
memory_transformed =  obj.hd_transform_normal(obj.Y_ma_total);
memory_transformed(obj.Y_ma_total  > 4) = obj.Y_ma_total(obj.Y_ma_total  > 4);
obj.Ym = memory_transformed;






end