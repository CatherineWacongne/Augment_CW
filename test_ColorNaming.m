%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test run of Visual Search Task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clear all;clc
clear;
global DisplayStepSize;
global ProgramReady;
ProgramReady=0;

% Set random seed:
seed = 11;

% Test length:
%%
epochs = 30000*5; %60
n_trials = 20000*5; %60


TrainCol=0;
TrainPos = 0;
generalize = 1;
fb = 0;
%% Parameters
% learning
gamma  = 0.9;
beta   = 0.2;%15;
lambda = 0.40;

% network hidden units
ny_memory = 1;
ny_normal = 20;

% for experiments, fix the random generator:
% rnd_stream = RandStream('mt19937ar','Seed', seed);
% RandStream.setDefaultStream(rnd_stream);

%% Figures init
scrsz = get(0,'ScreenSize');
h = figure('Position',[1 25 scrsz(3)/2.8 scrsz(4)/2.8]);
a = axes();
set(a,'NextPlot','replace');

h2 = figure('Position',[1+scrsz(3)/2 scrsz(4)/2.4 scrsz(3)/2.8 scrsz(4)/2]);             % this figure is for showing the network state
a2 = axes();
set(a2,'NextPlot','add');
plot(a2,1:10,1:10,'Color',[1,1,1])
connection_update_frequency=100;    % number of iterations between redrawing of connections
connection_counter=1;               % number of iterations between redrawing of connections

% control of the time between network updates
DisplayStepSize=10000;                  % PR was 1000
uicontrol('Style', 'edit', 'String', int2str(DisplayStepSize),...
    'Position', [20 30 50 30],'Callback',@edittext1_Callback);

% control of quitting the program
uicontrol('Style', 'pushbutton', 'String', 'Quit',...
    'Position', [20 20 50 20],'Callback','quit_Callback');

h3 = figure('Position',[190 scrsz(4)/2.4 scrsz(3)/2.8 scrsz(4)/2]);   % this figure is for showing the display with visible input
a3 = axes();
set(a3,'NextPlot','add');
plot(a3,1:10,1:10,'Color',[1,1,1]);








%t.intertrial_dur = 1;
%t.mem_dur = 2;


%% Network Settings:
%
if fb
    n = FBNetwork();
    n.limit_traces = false;
    n.input_method = 'modulposneg';
    
    n.n_inputs = 3;%length(t.nwInput);
    n.ny_memory = ny_memory;
    n.ny_normal = ny_normal;
    n.nz =  12; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n.controller = 'max-boltzmann';
    n.exploit_prob = .975;
    
    n.setInstantTransform('shifted-sigmoid',2.5);
    n.setMemoryTransform('shifted-sigmoid',2.5);
    
    
    n.input_noise = false;
    
    
    n.gamma = gamma;
    n.lambda = lambda;
    n.beta = beta;
    
    n.population_decay = false;
    
    n.init_network();
else
    n = SNetwork();
    n.limit_traces = false;
    n.input_method = 'posnegcells';
    
    n.n_inputs = 7;%length(t.nwInput);
    n.ny_memory = ny_memory;
    n.ny_normal = ny_normal;
    n.nz =  3; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n.controller = 'max-boltzmann';
    n.exploit_prob = .975;
    
    n.setInstantTransform('shifted-sigmoid',2.5);
    n.setMemoryTransform('shifted-sigmoid',2.5);
    
    
    n.input_noise = false;
    
    
    n.gamma = gamma;
    n.lambda = lambda;
    n.beta = beta;
    
    n.population_decay = false;
    
    n.init_network();
end

%% Task
close all
DisplayStepSize=10000;

% Figures init
scrsz = get(0,'ScreenSize');
h = figure('Position',[1 25 scrsz(3)/2.8 scrsz(4)/2.8]);
a = axes();
set(a,'NextPlot','replace');

h2 = figure('Position',[1+scrsz(3)/2 scrsz(4)/2.4 scrsz(3)/2.8 scrsz(4)/2]);             % this figure is for showing the network state
a2 = axes();
set(a2,'NextPlot','add');
plot(a2,1:10,1:10,'Color',[1,1,1])
connection_update_frequency=100;    % number of iterations between redrawing of connections
connection_counter=1;               % number of iterations between redrawing of connections

% control of the time between network updates
% DisplayStepSize=1000;                  % PR was 1000
uicontrol('Style', 'edit', 'String', int2str(DisplayStepSize),...
    'Position', [20 30 50 30],'Callback',@edittext1_Callback);

% control of quitting the program
uicontrol('Style', 'pushbutton', 'String', 'Quit',...
    'Position', [20 20 50 20],'Callback','quit_Callback');

h3 = figure('Position',[190 scrsz(4)/2.4 scrsz(3)/2.8 scrsz(4)/2]);   % this figure is for showing the display with visible input
a3 = axes();
set(a3,'NextPlot','add');
plot(a3,1:10,1:10,'Color',[1,1,1]);



%load('TrainedColPos')
t3 = ColorNamingTask();
t3.setDefaultNetworkInput;


%%
% Reset all variables:
% n_trials (estimated number of completed trials)
trial_res3 = zeros(1, n_trials);

states3 = zeros(epochs, 1);
input_acts3 = ones(epochs, n.n_inputs) * -100;
hidden_acts3 = ones(epochs, (ny_memory + ny_normal)) * -100;
q_activations3 = ones(epochs, n.nz) * -100;
deltas3 = zeros(1,epochs);

correct_perc3 = zeros(1,epochs);
trial_choices3 = zeros(epochs,n.nz);

trial_types3 = zeros(epochs,numel(t3.stim_input));
trial_ends3 = zeros(epochs, 1);

new_input3 = t3.nwInput;
reward3 = 0;
trialend3 = false;

rewards3 = ones(1, epochs)*-1;
e_rewards3 = zeros(1,epochs);

trialno = 1;
connection_counter3=1;
res_trial_stats3 = false;


for i=1:epochs % an epoch is a point in time, a trial contains multiple epochs (defined by the CAPITALSTATES properties of the task)
    if ~ProgramReady
        
        %%% Update Network
        [action3] = n.doStep(new_input3,reward3, trialend3);
        
        % Network values:
        input_acts3(i,:) = n.noiseless_input;
        hidden_acts3(i,:) =  n.Y';
        q_activations3(i,:) =  n.qas'; %
        e_rewards3(i) = n.previous_critic_val; % Expected reward
        deltas3(i) = n.delta; % TD-error
        trial_choices3(i,:) = n.Z; % action on timestep
        
        % Task values:
        states3(i) = t3.STATE;
        trial_types3(i,:) = t3.intTrialType;
        rewards3(i) = reward3; % Reward for previous action
%         correct_perc3(i) = t3.getPerformance();
        if trialno<1001
%                 correct_perc(i) = t.getPerformance();
                correct_perc3(i) = numel(find(trial_res3==1))/trialno;
            else
                correct_perc3(i) = numel(find(trial_res3(trialno-1000:trialno)>0))/numel(trial_res3(trialno-1000:trialno));
            end
        if (trialend3)
            trial_ends3(i) = 1;
            % Check to see if we need to reset the trial statistics
            % (a task-parameter changed!)
            if(res_trial_stats3)
                t3.resetTrialStats();
                res_trial_stats3 = false;
            end
            if(reward3 == 1.5)
                trial_res3(trialno) = 1;
            else
                trial_res3(trialno) = -1;
            end
            % Total number of trials in this run:
            trialno = trialno + 1;
        end
        %%% Update Task
        [new_input3, reward3, trialend3] = t3.doStep(action3);
        connection_counter3=connection_counter3+1;      % number of iterations between redrawing of connections
        if (mod(i,DisplayStepSize) == 0)
            figure(h);
            plot(a,1:epochs, rewards3,'.',1:epochs,e_rewards3,'r.',1:epochs,correct_perc3,'k.');
%           
            drawnow;
        end
    end
end % For epoch
[converged3, c_epoch3]  = calcConv(trial_res3, 0.1 )
convergence_res3 = [converged3, c_epoch3]

save('150603_ColorName_gen', 'n')
save('150603_ColorNameComplete_gen.mat', 'n', 't3', 'gamma', 'beta', 'lambda', 'ny_memory', 'ny_normal', 'trial_types3','rewards3')