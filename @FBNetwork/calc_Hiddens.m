function calc_Hiddens( obj )
%CALC_HIDDENS Calculate hidden unit activations

if (strcmp(obj.input_method, 'modulposneg'))
    activations_normal = [obj.bias_input obj.X(1:obj.n_inputs*2)] * ...
        obj.weights_xy((1:(obj.n_inputs*2 + obj.bias_input)), 1:obj.ny_normal);
    
else
    
    % Calculate activations of hidden neurons
    activations_normal = [obj.bias_input obj.X(1:obj.n_inputs)] * ...
        obj.weights_xy((1:(obj.n_inputs + obj.bias_input)), 1:obj.ny_normal);
end


% Calculate activations of 'instantanous/normal' hidden neurons
normal_transformed = obj.hd_transform_normal(activations_normal);

% Calculate activations of memory hidden neurons:
memory_transformed = obj.calc_MemoryHiddens();
% keyboard
obj.Y = [normal_transformed memory_transformed];

end

