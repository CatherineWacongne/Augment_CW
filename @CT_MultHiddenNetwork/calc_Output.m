
function calc_Output( obj )


%CALC_OUTPUT Compute network output (action)
%   Given hidden layer activations, compute Q predictions and select
%   an action to execute.



% Calculate initial activations of output layer:
Z = zeros(1,obj.nz);
for f = 1:obj.n_hidden_features
    Z = Z+ [obj.bias_hidden obj.Y{f}]* obj.weights_yz{f};%[obj.bias_hidden obj.Y] * obj.weights_yz +
end
% Get rid of uninteresting differences:
Z = round(Z * obj.prec_q_acts) / obj.prec_q_acts;

% Constrain Q-values to [0, ]?
if (obj.constrain_q_acts)
    Z(Z < 0) = 0;
    
end

% Store predicted values;


winner = -1;

obj.qas = Z;


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
            Z = Z - max(Z);  % trick stolen from PRR.
            %Pull result through softmax operator:
            Z = exp(Z) ./ sum(exp(Z));
            %Now, select winner with Roulette-Wheel
            winner = obj.calc_SoftWTA(Z);
            
            
            [v, mx_q] = max(Z);
            
            if (winner == mx_q)
                obj.prev_action_prob = obj.exploit_prob + (1-obj.exploit_prob) * Z(winner);
            else
                obj.prev_action_prob = (1-obj.exploit_prob) * Z(winner);
            end
        end
        
    case 'boltzmann'
        Z = Z - max(Z);  % trick stolen from PRR.
        %Pull result through softmax operator:
        Z = exp(Z) ./ sum(exp(Z));
        %Now, select winner with Roulette-Wheel
        winner = obj.calc_SoftWTA(Z);
        obj.prev_action_prob = Z(winner);
        
end

obj.prev_action = winner;
obj.Z = zeros(1,obj.nz);
% obj.ZS = zeros(1,obj.nzs);

obj.Z(winner) = 1;

end

