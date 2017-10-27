function [ fdelta ] = calc_fdelta( obj )
%CALC_FDELTA Summary of this function goes here
%   Detailed explanation goes here
 
pch = max(obj.prev_action_prob, obj.min_pch);

if (obj.delta > 0) 
  fdelta = obj.delta / pch;
else
  if (obj.max_critic)
    fdelta = obj.delta_max;
  else
    fdelta = obj.delta * obj.minfact;
  end
end

end

