function [critic_estimate, maxcritic_estimate] =  calc_Critic( obj )
%CALC_CRITIC Calculate value estimate of Critic (linear)

critic_estimate = ([obj.bias_value obj.X] * obj.values_x') + (obj.Y * obj.values_y');

if(obj.max_critic)
  maxcritic_estimate = ([obj.bias_value obj.X] * obj.values_x_max') + (obj.Y * obj.values_y_max');
else
  maxcritic_estimate = NaN;
end


end

