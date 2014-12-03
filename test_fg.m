% test for the FG task


close all; clear all;clc
clear;
global DisplayStepSize;
global ProgramReady;
ProgramReady=0;

% Set random seed:
seed = 11;

% Test length:
epochs = 50000;
n_trials = 10000;


%% Parameters
% learning
gamma  = 0.9;
beta   = 0.15;
lambda = 0.40;

% network hidden units
ny_memory = 15;
ny_normal = 80;

% for experiments, fix the random generator:
rnd_stream = RandStream('mt19937ar','Seed', seed);
RandStream.setDefaultStream(rnd_stream);

%% Figures init
scrsz = get(0,'ScreenSize');
h = figure('Position',[1 25 scrsz(3)/2.8 scrsz(4)/2.8]);
a = axes();
set(a,'NextPlot','replace');

% control of the time between network updates
DisplayStepSize=10000;                  % PR was 1000
uicontrol('Style', 'edit', 'String', int2str(DisplayStepSize),...
    'Position', [20 30 50 30],'Callback',@edittext1_Callback);

%% Network Settings:
%
n = FGNetwork();
n.limit_traces = false;
n.input_method = 'old';

n.n_inputs = 201;%length(t.nwInput);
n.ny_memory = ny_memory;
n.ny_normal = ny_normal;
n.nz =  12; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n.controller = 'max-boltzmann';
n.exploit_prob = .975;

n.setInstantTransform('shifted-sigmoid',2.5);
n.setMemoryTransform('shifted-sigmoid',2.5);


n.input_noise = false;
n.population_decay = false;

n.gamma = gamma;
n.lambda = lambda;
n.beta = beta;

n.init_network();

%% Task init
t = ColorTask();


% Reset all variables:
trial_res = zeros(1, n_trials);

states = zeros(epochs, 1);
input_acts = ones(epochs, 25) * -100;
hidden_acts = ones(epochs, (ny_memory + ny_normal)) * -100;
q_activations = ones(epochs, 12) * -100;
deltas = zeros(1,epochs);

correct_perc = zeros(1,epochs);
trial_choices = zeros(epochs,12);

trial_types = ones(epochs,1) * -1;
trial_ends = zeros(epochs, 1);


new_input = t.nwInput;
reward = 0;
trialend = false;

rewards = ones(1, epochs)*-1;
e_rewards = zeros(1,epochs);

trialno = 1;

res_trial_stats = false;

for i=1:epochs % an epoch is a point in time, a trial contains multiple epochs (defined by the CAPITALSTATES properties of the task)
    if ~ProgramReady
        
        %%% Update Network
        [action] = n.doStep(new_input,reward, trialend);
        
        % Network values:
        input_acts(i,:) = n.noiseless_input;
        hidden_acts(i,:) =  n.Y';
        q_activations(i,:) =  n.qas'; %
        e_rewards(i) = n.previous_critic_val; % Expected reward
        deltas(i) = n.delta; % TD-error
        trial_choices(i,:) = n.Z; % action on timestep
        
        % Task values:
        states(i) = t.STATE;
        trial_types(i) = t.intTrialType;
        rewards(i) = reward; % Reward for previous action
        correct_perc(i) = t.getPerformance();
        
        if (trialend)
            trial_ends(i) = 1;
            % Check to see if we need to reset the trial statistics
            % (a task-parameter changed!)
            if(res_trial_stats)
                t.resetTrialStats();
                res_trial_stats = false;
            end
            if(reward == 1.5)
                trial_res(trialno) = 1;
            else
                trial_res(trialno) = -1;
            end
            % Total number of trials in this run:
            trialno = trialno + 1;
        end
        %%% Update Task
        [new_input, reward, trialend] = t.doStep(action);
        connection_counter=connection_counter+1;      % number of iterations between redrawing of connections
        if (mod(i,DisplayStepSize) == 0)
            figure(h);
            plot(a,1:epochs, rewards,'.',1:epochs,e_rewards,'r.',1:epochs,correct_perc,'k.');
            if connection_counter>connection_update_frequency
                connection_counter=0;
                n.show_NetworkActivity(h2,a2,1);
            else
                n.show_NetworkActivity(h2,a2,0);
            end
            t.show_DisplayColor(h3,a3,n,new_input,reward,trialno);
            drawnow;
        end
    end
end % For epoch
plot(a,1:epochs, rewards,'.',1:epochs,e_rewards,'r.',1:epochs,correct_perc,'k.');

% Now, check whether this run converged (last 10% at least):
[converged, c_epoch]  = calcConv(trial_res, 0.1 )
convergence_res = [converged, c_epoch]
%     keyboard
if (converged == 1)
    save('TrainedCol', 'n')
end