function calc_Input(obj) % substracts the lateral inhibition
%% Bad, some subindeing to make to match input format.
    dX = obj.X(1:obj.n_inputs)*obj.weights_xx;
    obj.X(1:obj.n_inputs) = obj.X(1:obj.n_inputs) + 0.05*dX;
    a = obj.X(1:obj.n_inputs);
    obj.X(a<0) = 0;

end