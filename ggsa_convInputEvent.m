function [ events, offsets, n_evs ] = ggsa_convInputEvent( network_inputs )
%GGSA_CONVINPUTEVENT convert input to network to `Events' in delayed
%Gottlieb and Goldberg saccade-antisaccade task


% We need to extract:
% Which fixation-point type 
% - Onset + Offset
% Cue (L/R) + onset
events = zeros(size(network_inputs,1),1);
offsets = 0;
n_evs = 0;

fix_on_time = [];
% Pro-saccade fixation point:
fix_P_on_time = find(network_inputs(:,1),1,'first');
% Anti-saccade fixation point:
fix_A_on_time = find(network_inputs(:,2),1,'first');

if (~isempty(fix_P_on_time == 1))
  fix_on_time = fix_P_on_time;
  fix_off_time = find(network_inputs(:,1),1,'last') + 1;
else
  fix_on_time = fix_A_on_time;
  fix_off_time = find(network_inputs(:,2),1,'last') + 1;
end


Ltarget_on_time =  find(network_inputs(:,3),1,'first');
Rtarget_on_time =  find(network_inputs(:,4),1,'first');
target_on_time = [Ltarget_on_time, Rtarget_on_time];

% Sanity check:
if (length(target_on_time) == 1)

  events(fix_on_time) = 1; % fix signal on;
  events(target_on_time) = 2; % Target on;
  events(fix_off_time) = 3; % fix signal off;

  offsets = [fix_on_time, target_on_time, fix_off_time];
  
  n_evs = length(find(offsets));
end


end

