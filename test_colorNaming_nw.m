function [net_success, input_acts, hidden_acts,q_acts,  pretty, trial_types, reward_trials ] = test_colorNaming_nw(nw)


pretty = false;
%trial_type_labels = {'R-1','R-2','R-3','R-4','R-5','R-6','R-7','G-1','G-2','G-3','G-4','G-5','G-6','G-7','B-1','B-2','B-3','B-4','B-5','B-6','B-7'};
trial_types = [0:0.01:1; 0.5*ones(1,101)];%[[ones(7,1);2*ones(7,1);3*ones(7,1)] repmat([2:8]', 3,1)];%[1 2; 1 3; 1 4; 1 5]; % p-l;p-r;a-l;a-r


states = zeros(size(trial_types,2), 50);
input_acts = zeros(size(trial_types,2), 50, nw.n_inputs*3);
hidden_acts = zeros(size(trial_types,2), 50,nw.ny);
q_acts = zeros(size(trial_types,2), 50, nw.nz);

trial_ends = zeros(size(trial_types,2),1);
reward_trials = zeros(size(trial_types,2),1);

% Number of tests
seed = 1;
net_success = true;

% for experiments, fix the random generator:
% rnd_stream = RandStream('mt19937ar','Seed', seed);
% RandStream.setDefaultStream(rnd_stream);

% Stop learning; set to completely greedy strategy
nw.beta = 0;

nw.exploit_prob = 1;
nw.resetTraces();
nw.previous_qa = 0;
nw.delta = 0;

% Test network on all trial-types
for i = 1:size(trial_types,2)
    
    epoch = 1;
    
    % Task Settings:
    t = ColorNamingTask();
   
    
    %t.setTrialType(trial_types(i,1), trial_types(i,2));
    t.setTrialType(trial_types(:,i))
    
    nw.resetTraces();
    nw.previous_qa = 0;
    nw.delta = 0;
    
    new_input = t.nwInput;
    reward = 0;
    trialend = false;
    
    
    
    
    while(true)
        %%% Update Network
        [action] = nw.doStep(new_input,reward, trialend);
        
        states(i,epoch) = t.STATE;
        input_acts(i,epoch, :) =  nw.X';
        hidden_acts(i,epoch,:) = nw.Y';
        q_acts(i,epoch,:) = nw.qas';
        
        
        if (trialend)
            t.stateReset();
            trial_ends(i) = epoch;
            
            if (reward <= 0.7)
                net_success = false;
                reward_trials(i)=0;
            else
                reward_trials(i)=1;
            end
            
            break;
        end
        
        %%% Update Task
        [new_input, reward, trialend] = t.doStep(action);
        epoch = epoch + 1;
    end
end

[ events, offsets, n_evs ] = ggsa_convInputEvent(squeeze(input_acts(1,1:trial_ends(1), : )));
event_idxes = [ offsets ];
xlabels = { 'F', 'C', 'G'};


%% plots and further analysis

activ = squeeze(hidden_acts(:,4,:));
activ = activ-repmat(mean(activ),101,1);
activ = activ./repmat(max(activ)-min(activ),101,1);
figure;plot(1:101,activ);
