function calc_Input( obj )
%CALC_INPUT Calculate input vector if there is moluatory connections

%% Xi
obj.prev_xi = obj.Xi;
obj.Xi = obj.current_input;

%% Xk
modul_input =  [1 obj.Ym] *obj.weights_ymxk;
modul_normal = modul_input.*obj.current_input;
modul_transformed = obj.hd_transform_normal(modul_normal);%+obj.current_input*2   obj.hd_transform_normal((modul_input)+obj.current_input);%-mean(modul_input)
modul_transformed(modul_normal>4) = modul_normal(modul_normal>4);
obj.Xk = modul_transformed;

%% d_pos d_neg
d_input =  obj.current_input - obj.prev_xi;
obj.Xon = d_input;
obj.Xon(obj.Xon<0) = 0;

obj.Xoff = -d_input;
obj.Xoff(obj.Xoff<0) = 0;

%% d_pos_modul d_neg_modul
d_modul_input = modul_transformed - obj.prev_input_mod;%modul_normal
obj.Xkon = d_modul_input;
obj.Xkon(obj.Xkon<0) = 0;

obj.Xkoff = -d_modul_input;
obj.Xkoff(obj.Xkoff<0) = 0;


obj.prev_input_mod = modul_transformed;% modul_normal;



%% update record keeping variables
obj.sum_t_xon   = obj.sum_t_xon  + obj.Xon;
obj.sum_t_xoff  = obj.sum_t_xoff + obj.Xoff;
obj.sum_t_xkon  = obj.sum_t_xkon + obj.Xkon;
obj.sum_t_xkoff = obj.sum_t_xkoff+ obj.Xkoff;
end
