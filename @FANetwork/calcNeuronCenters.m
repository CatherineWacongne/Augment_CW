function calcNeuronCenters( obj )
%CALCNEURONCENTERS Summary of this function goes here
%   Detailed explanation goes here
obj.centers = ((2*pi/obj.n_tuning_curves)*(0:(obj.n_tuning_curves-1)));

end

