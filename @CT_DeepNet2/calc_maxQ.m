function [ winner ] = calc_maxQ( obj )
%CALC_MAXQ Selects the Q-value with the maximal value, and returns neuron
% index. Ties are broken randomly.

  [v,winner] = max(obj.qas);
  obj.prev_action_prob = obj.exploit_prob; 

  % Be sure to break ties randomly:
  mxes = find(obj.qas == v);
  if (size(mxes) ~= 1)
    winner = mxes(randi(size(mxes)));
  end

end

