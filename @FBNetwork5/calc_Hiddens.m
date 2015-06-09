function calc_Hiddens( obj )
%CALC_HIDDENS Calculate hidden unit activations

% Calculate activations of hidden neurons
% activations_normal = [obj.bias_input obj.X(1:obj.n_inputs)] * ...
%   obj.weights_xy((1:(obj.n_inputs + obj.bias_input)), 1:obj.ny_normal); 

activations_normal = [obj.bias_input obj.X([1:obj.n_inputs obj.n_inputs*2+1:obj.n_inputs*3])] * ...
  obj.weights_xy([1:obj.n_inputs+obj.bias_input obj.bias_input+obj.n_inputs*2+1:obj.bias_input+obj.n_inputs*3], 1:obj.ny_normal); 

% Calculate activations of 'instantanous/normal' hidden neurons
normal_transformed = obj.hd_transform_normal(activations_normal);
if obj.prev_action<=obj.nzs
    activation_modul = obj.weights_yzs(1+obj.bias_hidden:obj.ny_normal+obj.bias_hidden+obj.ny_memory,obj.prev_action)' ;
else
   activation_modul = obj.weights_yzs(1+obj.bias_hidden:obj.ny_normal+obj.bias_hidden+obj.ny_memory,obj.prev_action-obj.nzs)' ;
%     activation_modul = obj.weights_zzs(obj.prev_action-obj.nzs,obj.prev_action-obj.nzs).* obj.weights_yzs(1+obj.bias_hidden:obj.ny_normal+obj.bias_hidden+obj.ny_memory,obj.prev_action-obj.nzs)'...
%         +obj.weights_yz(1+obj.bias_hidden:obj.ny_normal+obj.bias_hidden+obj.ny_memory,obj.prev_action-obj.nzs)' ;
    
end

% memory_transformed = obj.calc_MemoryHiddens();

obj.mem_input = obj.X(obj.n_inputs + 1:obj.n_inputs*2);
obj.Y_ma_current = obj.mem_input * obj.weights_xy((obj.bias_input+obj.n_inputs + 1):obj.bias_input+obj.n_inputs*2,obj.ny_normal + 1:obj.ny_normal +obj.ny_memory);
obj.Y_ma_total = (obj.mem_decays .* obj.Y_ma_total) + obj.Y_ma_current;
memory_transformed =  obj.hd_transform_memory(obj.Y_ma_total);



% modul_transformed = obj.hd_transform_memory(activation_modul);
obj.Y = [normal_transformed memory_transformed activation_modul];%modul_transformed

end

