function [ winner ] = calc_SoftWTA( probabilities )
%CALC_SOFTWTA Roulette wheel selection of action

  wheel = zeros(length(probabilities) + 1, 1);
  for i = 2:(length(probabilities) + 1)
    wheel(i) = wheel(i - 1) + probabilities(i-1);
  end

  action = length(probabilities);
  rnd_val = rand;
  for i= 1:(length(wheel) - 1)
    if( (rnd_val >= wheel(i)) && (rnd_val <= wheel(i+1)))
      action = i;
      break;
    end
  end

winner = action;

end

