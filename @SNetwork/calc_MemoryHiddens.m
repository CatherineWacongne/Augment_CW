function [ mem_activations ] = calc_MemoryHiddens( obj )
%CALC_MEMORYHIDDENS 

%assert(all((obj.X .* ~(obj.X == obj.prev_input)) == obj.mem_input))
if (strcmp(obj.input_method, 'modulposneg'))
    obj.mem_input = obj.X((obj.n_inputs*2 + 1):end);
else
    obj.mem_input = obj.X((obj.n_inputs + 1):end);
end

% Calculate current activations (no bias)
% mem_decays can be used to decay memory activations (experimental)
if (strcmp(obj.input_method, 'modulposneg'))
    obj.Y_ma_current = obj.mem_input * obj.weights_xy((obj.bias_input+obj.n_inputs*2 + 1):end,obj.ny_normal + 1:end);
else
    obj.Y_ma_current = obj.mem_input * obj.weights_xy((obj.bias_input+obj.n_inputs + 1):end,obj.ny_normal + 1:end);
end
obj.Y_ma_total = (obj.mem_decays .* obj.Y_ma_total) + obj.Y_ma_current;

% Transform:

mem_activations =  obj.hd_transform_memory(obj.Y_ma_total);

end

