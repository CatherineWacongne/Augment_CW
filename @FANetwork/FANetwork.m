classdef FANetwork < SNetwork 
  %ODSNETWORK Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    % We cannot redefine parameters inherited from SNetwork
    % unless they would be private in SNetwork.
    % Now this is done in the init_network function below
    
    % Parameters for tuning curves in input-layer
    sigma = 12 * (pi / 180);
    
    % coding noise:
    angle_noise = 5 * (pi/ 180); % noise in angle perception
    
    % Contains the preferred orientations of input-units
    centers = [];
    
    n_tuning_curves = 20;
    
  end
  
  methods (Access=protected) % Protected methods
    calcNeuronCenters(obj);
  end
  
  methods
    
  [nwinput] = convertAngleToNwInput(obj, rad_angle);
  
  
  function init_network(obj, varargin) % variable number of arguments
    
    if (nargin == 1)
    
     obj.n_inputs = 1 + obj.n_tuning_curves; % F G + 20 tuning curves
     %obj.nx = 2 + obj.n_tuning_curves; 
     obj.ny_normal = 2;
     obj.ny_memory = 10;
     obj.nz = 1+12; % F + 12 15 degree intervals
     
    elseif (nargin == 6)    % in case of 6 input arguments
      obj.n_tuning_curves = varargin{1};
      obj.n_inputs = varargin{2} + obj.n_tuning_curves;
      obj.ny_normal = varargin{3};
      obj.ny_memory = varargin{4};
      obj.nz = varargin{5}; % F + 12 15 degree intervals
    end
    
   obj.init_network@SNetwork;
   obj.calcNeuronCenters();
   
  end
  
   function init_network_python(obj, pmat)
      % Load network trained with python version of AuGMEnT
      obj.init_network_python@SNetwork(pmat)
     
      % FA Network specific parameters:
     
      obj.n_tuning_curves = single(pmat.n_tuning_curves);
      obj.sigma = pmat.sigma;
      obj.centers = pmat.centers';
      obj.angle_noise = pmat.angle_noise; 
      
      obj.n_inputs = 1 + obj.n_tuning_curves; % F G + 20 tuning curves
      
    end
  

  
  end

  
end

