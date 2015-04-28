function mem_activations = calc_MemoryHiddens( obj )
%CALC_MEMORYHIDDENS 

%assert(all((obj.X .* ~(obj.X == obj.prev_input)) == obj.mem_input))

obj.mem_input = obj.X(obj.n_inputs + 1:obj.n_inputs*2);


% Calculate current activations (no bias)
obj.Y_ma_current = obj.mem_input * obj.weights_xy((obj.bias_input+obj.n_inputs + 1):obj.bias_input+obj.n_inputs*2,obj.ny_normal + 1:obj.ny_normal +obj.ny_memory);

obj.Y_ma_total = (obj.mem_decays .* obj.Y_ma_total) + obj.Y_ma_current;

% Transform:

mem_activations =  obj.hd_transform_memory(obj.Y_ma_total);

end

