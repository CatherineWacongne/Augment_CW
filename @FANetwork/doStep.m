function [action] = doStep(obj, input, reward, reset_traces )
%DOSTEP Simulate one epoch of the network

% Convert input angle to network-input

%input

recoded = obj.convertAngleToNwInput( input(2) );

%[input(1:2) recoded]
% Call superclass doStep function
action = doStep@SNetwork(obj, [input(1) recoded], reward, reset_traces); 

%action

end

