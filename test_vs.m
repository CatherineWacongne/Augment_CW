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
epochs = 50000*2;
n_trials = 10000*2;

TrainCol=1;
TrainPos = 1;
generalize = 1;
fb = 0;
%% Parameters
% learning
gamma  = 0.9;
beta   = 0.15;%15;
lambda = 0.40;

% network hidden units
ny_memory = 15;
ny_normal = 30;

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
    
    n.n_inputs = 25;%length(t.nwInput);
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
    
    n.n_inputs = 25;%length(t.nwInput);
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
end

%% Task Settings:

if TrainCol
    
    t = ColorTask();
    
    
    % Reset all variables:
    % n_trials (estimated number of completed trials)
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
            if trialno<1001
%                 correct_perc(i) = t.getPerformance();
                correct_perc(i) = numel(find(trial_res==1))/trialno;
            else
                correct_perc(i) = numel(find(trial_res(trialno-1000:trialno)>0))/numel(trial_res(trialno-1000:trialno));
            end
            if correct_perc(i) > .9
                break
            end
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
    %   if (converged == 1)
    %     % Save all relevant variables to file:
    %     save([logfile '_' num2str(seeds(seed_idx)) '.mat'], ...
    %       'states', 'input_acts','hidden_acts','q_activations','rewards', ...
    %       'deltas', 'trial_types', 'trial_ends','trial_res');
    % 	save(['ds_network_' num2str(seeds(seed_idx)), '.mat'],'n');
    %   end
end

%% Pos Training
if TrainPos
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
    
    
    
    
    load('TrainedCol')
    t2 = PosTask();
    
    epochs = 50000*2;
    n_trials = 10000*2;
    
    % Reset all variables:
    % n_trials (estimated number of completed trials)
    trial_res2 = zeros(1, n_trials);
    
    states2 = zeros(epochs, 1);
    input_acts2 = ones(epochs, 25) * -100;
    hidden_acts2 = ones(epochs, (ny_memory + ny_normal)) * -100;
    q_activations2 = ones(epochs, 12) * -100;
    deltas2 = zeros(1,epochs);
    
    correct_perc2 = zeros(1,epochs);
    trial_choices2 = zeros(epochs,12);
    
    trial_types2 = ones(epochs,1) * -1;
    trial_ends2 = zeros(epochs, 1);
    
    new_input2 = t2.nwInput;
    reward2 = 0;
    trialend2 = false;
    
    rewards2 = ones(1, epochs)*-1;
    e_rewards2 = zeros(1,epochs);
    
    trialno = 1;
    connection_counter2=1;
    res_trial_stats2 = false;
    
    
    for i=1:epochs % an epoch is a point in time, a trial contains multiple epochs (defined by the CAPITALSTATES properties of the task)
        if ~ProgramReady
            
            %%% Update Network
            [action2] = n.doStep(new_input2,reward2, trialend2);
            
            % Network values:
            input_acts2(i,:) = n.noiseless_input;
            hidden_acts2(i,:) =  n.Y';
            q_activations2(i,:) =  n.qas'; %
            e_rewards2(i) = n.previous_critic_val; % Expected reward
            deltas2(i) = n.delta; % TD-error
            trial_choices2(i,:) = n.Z; % action on timestep
            
            % Task values:
            states2(i) = t2.STATE;
            trial_types2(i) = t2.intTrialType;
            rewards2(i) = reward2; % Reward for previous action
            if trialno<1001
%                 correct_perc(i) = t.getPerformance();
                correct_perc2(i) = numel(find(trial_res2==1))/trialno;
            else
                correct_perc2(i) = numel(find(trial_res2(trialno-1000:trialno)>0))/numel(trial_res2(trialno-1000:trialno));
            end
%             correct_perc2(i) = t2.getPerformance();
            
            if (trialend2)
                trial_ends2(i) = 1;
                % Check to see if we need to reset the trial statistics
                % (a task-parameter changed!)
                if(res_trial_stats2)
                    t2.resetTrialStats();
                    res_trial_stats2 = false;
                end
                if(reward2 == 1.5)
                    trial_res2(trialno) = 1;
                else
                    trial_res2(trialno) = -1;
                end
                % Total number of trials in this run:
                trialno = trialno + 1;
            end
            %%% Update Task
            [new_input2, reward2, trialend2] = t2.doStep(action2);
            connection_counter2=connection_counter2+1;      % number of iterations between redrawing of connections
            if (mod(i,DisplayStepSize) == 0)
                figure(h);
                plot(a,1:epochs, rewards2,'.',1:epochs,e_rewards2,'r.',1:epochs,correct_perc2,'k.');
%                 if connection_counter2>connection_update_frequency
%                     connection_counter2=0;
%                     n.show_NetworkActivity(h2,a2,1);
%                 else
%                     n.show_NetworkActivity(h2,a2,0);
%                 end
                %t2.show_DisplayColor(h3,a3,n,new_input,reward,trialno);
                drawnow;
            end
        end
    end % For epoch
    [converged2, c_epoch2]  = calcConv(trial_res2, 0.1 )
    convergence_res2 = [converged2, c_epoch2]
    %     keyboard
    %if (converged2 == 1)
    save('TrainedColPos', 'n')
    %end
    
end
%% Actual VS
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
t3 = VSTask();
t3.n_genTrials = 500;
t3.setTrialsForGeneralisation;

%%
epochs = 50000*12; %60
n_trials = 10000*12; %60

% Reset all variables:
% n_trials (estimated number of completed trials)
trial_res3 = zeros(1, n_trials);

states3 = zeros(epochs, 1);
input_acts3 = ones(epochs, 25) * -100;
hidden_acts3 = ones(epochs, (ny_memory + ny_normal)) * -100;
q_activations3 = ones(epochs, 12) * -100;
deltas3 = zeros(1,epochs);

correct_perc3 = zeros(1,epochs);
trial_choices3 = zeros(epochs,12);

trial_types3 = ones(epochs,1) * -1;
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
        trial_types3(i) = t3.intTrialType;
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
%             keyboard
            %             if connection_counter3>connection_update_frequency
            %                 connection_counter3=0;
            %                 n.show_NetworkActivity(h2,a2,1);
            %             else
            %                 n.show_NetworkActivity(h2,a2,0);
            %             end
            %t2.show_DisplayColor(h3,a3,n,new_input,reward,trialno);
            drawnow;
        end
    end
end % For epoch
[converged3, c_epoch3]  = calcConv(trial_res3, 0.1 )
convergence_res3 = [converged3, c_epoch3]

save('TrainedColPosVS_gen', 'n')
save('141216_resultsComplete_gen_nofb.mat', 'n', 't3', 'gamma', 'beta', 'lambda', 'ny_memory', 'ny_normal', 'trial_types3','rewards3')