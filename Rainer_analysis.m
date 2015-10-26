% load 150108_resultsColorVS_gen_fb.mat
% load('150112_resultsColorVS_gen_fb.mat')
% PngDir = 'C:\Users\wacongne\Documents\PostDoc\Modeling\AuGMEnT_Matlab\Results\190208\';
n_trials = 100;
test =  t.generalization_trials(1:n_trials);
% test = t.train_trials(1:n_trials);
trial_types = unique(test);
[net_success, input_acts, hidden_acts,q_acts,  pretty, trial_types, reward_trials ] = test_rainer_nw(n, test);

%% plot activity when the obj cue is presented 
cue_step = 5;
cue_activ = zeros(size(hidden_acts,3)/2,8);
for cue = 1:8
    cue_activ(:,cue) = mean(hidden_acts(floor(trial_types/1e8)==cue,cue_step,1:end/2));
    
end
figure; imagesc(cue_activ)

%% activity when the sample is presented
  sample_activ = zeros(size(hidden_acts,3)/2,3,2);
for pos = 1:3
    sample_activ(:,pos,1) = mean(hidden_acts( (floor(trial_types/1e5)-floor(trial_types/1e6)*10)==pos,cue_step+1,1:end/2));   
    sample_activ(:,pos,2) = mean(hidden_acts( (floor(trial_types/1e5)-floor(trial_types/1e6)*10)~=pos,cue_step+1,1:end/2));   
    figure; imagesc(squeeze(sample_activ(:,pos,1))- squeeze(sample_activ(:,pos,2)))
    

end

%% activ when the target is presented
