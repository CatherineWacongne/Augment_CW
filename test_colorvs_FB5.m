%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test run of Visual Search Task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clear all; clc
clear;
global DisplayStepSize;
global ProgramReady;
ProgramReady=0;

% Set random seed:
seed = 11;

% Test length:
epochs = 50000;%*20;
n_trials = 10000;%*30;

generalize = 1;
fb = 1;
%% Parameters
% learning
gamma  = 0.9;
beta   = 0.05;%15;
lambda = 0.5;%.20;

% network hidden units
ny_memory = 10;
ny_normal = 25;

% for experiments, fix the random generator:
% rnd_stream = RandStream('mt19937ar','Seed', seed);
% RandStream.setDefaultStream(rnd_stream);

%% Figures init
scrsz = get(0,'ScreenSize');
h = figure('Position',[1 25 scrsz(3)/2.8 scrsz(4)/1.1]);
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
set(a3,'NextPlot','replace');
% plot(a3,1:10,1:10,'Color',[1,1,1]);








%t.intertrial_dur = 1;
%t.mem_dur = 2;


%% Network Settings:
%
if fb
    n = FBNetwork5();
    n.limit_traces = false;
    n.input_method = 'modulcells_on_memo';
    
    n.n_inputs = 26;%length(t.nwInput);
    
    n.ny_normal = ny_normal;
    n.ny_memory = ny_memory;
    n.nz =  12; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n.nzs = n.nz;
    n.controller = 'max-boltzmann';
    n.exploit_prob = .975;
    
    n.instant_transform_fn = 'rectified-linear' ;
    n.delta_limit = 2;
    n.limit_delta = 1;
%     n.limit_traces = 1;
    
%     n.setInstantTransform('shifted-sigmoid',2.5);
%     n.setMemoryTransform('shifted-sigmoid',2.5);
    n.setInstantTransform(n.instant_transform_fn) 
    
    n.input_noise = false;
%     n.constrain_q_acts = 1;
    
    n.gamma = gamma;
    n.lambda = lambda;
    n.beta = beta;
    
    n.population_decay = false;
    
    n.init_network();
else
    n = SNetwork();
    n.limit_traces = false;
    n.input_method = 'posnegcells';
    
    n.n_inputs = 26;%length(t.nwInput);
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

Task2 = 1;
if Task2
    t = ColorVSTask2();
    t.mem_dur = 1;
else 
    t = ColorVSTask();
end
t.n_genTrials = 1e5;
t.setTrialsForGeneralisation;

% Reset all variables:
% n_trials (estimated number of completed trials)

for color_on = [0]
    % Test length:
    epochs = 50000*30;%0-50000*55*color_on;
    n_trials = 20000*25;%0-10000*60*color_on;

    t.Color_only = color_on;
    trial_res = zeros(1, n_trials);
    trial_res_color = zeros(1, n_trials);
    last_trial_end =0;
    
    states = zeros(epochs, 1);
    input_acts = ones(epochs, 26) * -100;
    
    if fb
        hidden_acts = ones(epochs, (ny_normal+ny_memory)*2) * -100;
        q_activations = ones(epochs, n.nz+n.nzs) * -100;
    else
        hidden_acts = ones(epochs, (ny_normal+ny_memory)) * -100;
        q_activations = ones(epochs, n.nz) * -100;
    end
    deltas = zeros(1,epochs);
    
    correct_perc = zeros(1,epochs);
    correct_perc_color = zeros(1,epochs);
    trial_choices = zeros(epochs,12);
    
    trial_types = ones(epochs,1) * -1;
    trial_ends = zeros(epochs, 1);
    
    
    
    
    new_input = t.nwInput;
    reward = 0;
    trialend = false;
    
    rewards = ones(1, epochs)*-1;
    e_rewards = zeros(1,epochs);
    
    trialno = 1;
    w51 = zeros(n.ny_normal,epochs);
    w26 = zeros(n.ny_normal,epochs);
%     wy15 = zeros(n.nzs,epochs);
    res_trial_stats = false;
    tic = 1;
    t.showdistractors = 1;
    t.reward_vs = 0;
    t.reward_color = 1;
    for i=1:epochs % an epoch is a point in time, a trial contains multiple epochs (defined by the CAPITALSTATES properties of the task)
        if ~ProgramReady
            
            %%% Update Network
            [action] = n.doStep(new_input,reward, trialend);
%             n.prev_action
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
            w51(:,i) = n.weights_xy(26,1:n.ny_normal)';
            w26(:,i) = n.weights_xy(15,1:n.ny_normal)';
%             wy15(:,i)= n.weights_zzs(:,4);
            if trialno<1001
                %                 correct_perc(i) = t.getPerformance();
                correct_perc(i) = numel(find(trial_res==1))/trialno;
                correct_perc_color(i) = numel(find(trial_res_color==1))/trialno;
            else
                correct_perc(i) = numel(find(trial_res(trialno-1000:trialno)>0))/numel(trial_res(trialno-1000:trialno));
                correct_perc_color(i) = numel(find(trial_res_color(trialno-1000:trialno)>0))/numel(trial_res_color(trialno-1000:trialno));
            end
            if (trialend)
                trial_ends(i) = 1;
                
                % Check to see if we need to reset the trial statistics
                % (a task-parameter changed!)
                if(res_trial_stats)
                    t.resetTrialStats();
                    res_trial_stats = false;
                end
                if(reward >= .7-color_on*.1)%== 1.5)
                    trial_res(trialno) = 1;
%                 elseif(rewards(i-1) >= .5)%== 1.5)
%                      trial_res(trialno) = 0.5;
                else
                    trial_res(trialno) = -1;
                end
                if ~isempty(find(abs(rewards(last_trial_end+1:i)-0.6)<0.05))
                    trial_res_color(trialno) = 1;
                else 
                    trial_res_color(trialno) = -1;
                end
                % Total number of trials in this run:
                trialno = trialno + 1;
                b = find(trial_ends==1);
                if t.reward_vs && ~t.reward_color  && (trialno-tac)>100 
                    if correct_perc(i-1) > .9
                        toc = trialno;
                    end
                end
                if   ~t.reward_color  && (trialno-tac)>1000
                    if correct_perc(i-1) > .9
                       
                        t.var_mem_dur =1;
                         n.beta   = 0.01;
                        tuc =trialno;
%                         keyboard;
                    end

                end
                
                if t.reward_vs   && (trialno-tic)>10000 && t.reward_color
                    if correct_perc(i-1) > .9
                       
                        t.reward_color = 0;
                         n.beta   = 0.01;
                        tac =trialno;
%                         keyboard;
                    end

                end
                
                if numel(b)>30001 && t.reward_vs == 0
                    if  mean(correct_perc_color(i-10000:i-1)) >0.9
                        t.reward_vs = 1;
%                         t.reward_color = 0;
                         n.beta   = 0.025;
%                         tac =trialno; %%%%%%%%%%%%
                        tic =trialno;
%                         keyboard
                    end
                end
                last_trial_end = i;
            end
            %%% Update Task
            [new_input, reward, trialend] = t.doStep(action);
             if reward>0
                r = 1;
            end
            connection_counter=connection_counter+1;      % number of iterations between redrawing of connections
            if (mod(i,DisplayStepSize) == 0)
                figure(h);
                plot(a,1:epochs, rewards,'.',1:epochs,e_rewards,'r.',1:epochs,correct_perc,'k.',1:epochs,correct_perc_color,'g.');ylim([-1.2 2.5])
%                 plot(a3,1:i, w26(:,1:i),'b',1:i,w51(:,1:i),'r');
                if connection_counter>connection_update_frequency
                    connection_counter=0;
                    n.show_NetworkActivity(h2,a2,1);
                else
                    n.show_NetworkActivity(h2,a2,0);
                end
                %                 t.show_DisplayColor(h3,a3,n,new_input,reward,trialno);
                drawnow;
            end
            
        end
    end % For epoch
    
    
    % Now, check whether this run converged (last 10% at least):
    [converged, c_epoch]  = calcConv(trial_res, 0.1 )
    convergence_res = [converged, c_epoch]
end

save('150811_resultsColorVS2_gen_fb5.mat', 'n', 't', 'gamma', 'beta', 'lambda', 'ny_memory', 'ny_normal', 'trial_types','rewards')