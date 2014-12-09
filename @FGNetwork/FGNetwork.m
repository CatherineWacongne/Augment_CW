classdef FGNetwork < SNetwork 
  %ODSNETWORK Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    % We cannot redefine parameters inherited from SNetwork
    % unless they would be private in SNetwork.
    % Now this is done in the init_network function below
    
    % Parameters for the lateral inhibition
    size_net = 10;
    rad_i = 2;
    wi = .4;
    
    weights_xx = zeros(201);
    
  end
  
  methods (Access=protected) % Protected methods
    calcLateralInhib(obj);
    calc_input(obj);
  end
  
  methods
    
  
  
  function init_network(obj, varargin) % variable number of arguments
    
   obj.init_network@SNetwork;
   obj.calcLateralInhib();
   
  end
  
   
  

  
  end

  
end

