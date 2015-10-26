
function calc_Output( obj )


%CALC_OUTPUT Compute network output (action)
%   Given hidden layer activations, compute Q predictions and select 
%   an action to execute.



% Calculate initial activations of output layer:
Z = [obj.bias_hidden obj.Y]* obj.weights_yz;%[obj.bias_hidden obj.Y] * obj.weights_yz +

% Get rid of uninteresting differences:
Z = round(Z * obj.prec_q_acts) / obj.prec_q_acts;

% Constrain Q-values to [0, ]?
if (obj.constrain_q_acts)
  Z(Z < 0) = 0;
  
end

% Store predicted values;


winner = -1;
obj.qas = Z;
ZSZ =Z;

switch obj.controller
  
  case 'max'
    if (rand <= obj.exploit_prob) % Exploitation-step:
      [winner] = calc_maxQ( obj );
    else % Exploration-step:
      winner = randi(length(Z));
      [v, mx_q] = max(obj.qas);
      if (winner ~= mx_q)
        obj.prev_action_prob = obj.exploit_prob + (1-obj.exploit_prob) * Z(winner);
      else
        obj.prev_action_prob = (1-obj.exploit_prob) * Z(winner);
      end
    end
   
  case 'max-boltzmann'
    if  (rand <= obj.exploit_prob) % Exploitation-step:
    	[winner] = calc_maxQ( obj );
    else % Exploration step (Boltzmann)
      ZSZ = ZSZ - max(ZSZ);  % trick stolen from PRR.
      %Pull result through softmax operator:
      ZSZ = exp(ZSZ) ./ sum(exp(ZSZ));
      %Now, select winner with Roulette-Wheel
      winner = obj.calc_SoftWTA(ZSZ);
      
     
      [v, mx_q] = max(Z);
      
      if (winner == mx_q)
        obj.prev_action_prob = obj.exploit_prob + (1-obj.exploit_prob) * ZSZ(winner);
      else
        obj.prev_action_prob = (1-obj.exploit_prob) * ZSZ(winner);
      end  
    end

   case 'boltzmann'
    ZSZ = ZSZ - max(ZSZ);  % trick stolen from PRR.
    %Pull result through softmax operator:
    ZSZ = exp(ZSZ) ./ sum(exp(ZSZ));
    %Now, select winner with Roulette-Wheel
    winner = obj.calc_SoftWTA(ZSZ);
    obj.prev_action_prob = ZSZ(winner);

end

obj.prev_action = winner;
obj.Z = zeros(1,obj.nz);



obj.Z(winner) = 1;


end

