function calc_Hiddens( obj )
%CALC_HIDDENS Calculate hidden unit activations

% Calculate activations of hidden neurons
% activations_normal = [obj.bias_input obj.X(1:obj.n_inputs)] * ...
%   obj.weights_xy((1:(obj.n_inputs + obj.bias_input)), 1:obj.ny_normal); 

activations_normal = [obj.bias_input obj.X] * ...
  obj.weights_xy(:, 1:obj.ny_normal); 

% Calculate activations of 'instantanous/normal' hidden neurons
normal_transformed = obj.hd_transform_normal(activations_normal);

activation_modul = obj.weights_yz(1+obj.bias_hidden:obj.ny_normal+obj.bias_hidden,obj.prev_action)';
modul_transformed = obj.hd_transform_memory(activation_modul);
obj.Y = [normal_transformed activation_modul];%modul_transformed

end

