function [nwinput] = convertAngleToNwInput(obj, rad_angle)
%CONVERTANGLETO Summary of this function goes here
%   Detailed explanation goes here
 
if (rad_angle ~= -1)
  
  rad_angle = rad_angle + obj.angle_noise*randn;

  nwinput_h = exp(-((rad_angle+2*pi) - obj.centers).^2 ./ (2 * (obj.sigma^2)));
  nwinput_norm = exp(-(rad_angle - obj.centers).^2 ./ (2 * (obj.sigma^2)));
  nwinput_l = exp(-((rad_angle-2*pi) - obj.centers).^2 ./ (2 * (obj.sigma^2)));

  nwinput = max([nwinput_h;nwinput_norm;nwinput_l],[],1);
else
  nwinput = zeros(1, obj.n_tuning_curves);
end

  
end

