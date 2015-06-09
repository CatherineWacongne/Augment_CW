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
beta   = 0.02;%15;
lambda = 0.2;%.20;

% network hidden units
ny_memory = 25;
ny_normal = 100;

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
set(a3,'NextPlot','replace');
% plot(a3,1:10,1:10,'Color',[1,1,1]);








%t.intertrial_dur = 1;
%t.mem_dur = 2;


%% Network Settings:
%
if fb
    n = FBNetwork5();
    n.limit_traces = false;
    n.input_method = 'modulcells';
    
    n.n_inputs = 201;%length(t.nwInput);
    
    n.ny_normal = ny_normal;
    n.nz =  103; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n.nzs = n.nz;
    n.controller = 'max-boltzmann';
    n.exploit_prob = .975;
    
%     n.instant_transform_fn = 'rectified-linear' ;
    n.delta_limit = 2;
    n.limit_delta = 1;
%     n.limit_traces = 1;
    
    n.setInstantTransform('shifted-sigmoid',2.5);
    n.setMemoryTransform('shifted-sigmoid',2.5);
%     n.setInstantTransform() 
    
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



t = FGTask();
t.fix_dur = 1;
t.bg_on = 0;
% t.n_genTrials = 1e5;
% t.setTrialsForGeneralisation;

% Reset all variables:
% n_trials (estimated number of completed trials)

for color_on = [0]
    % Test length:
    epochs = 50000*45;%0-50000*55*color_on;
    n_trials = 10000*50;%0-10000*60*color_on;

%     t.Color_only = color_on;
    trial_res = zeros(1, n_trials);
    
    states = zeros(epochs, 1);
    input_acts = ones(epochs, n.n_inputs) * -100;
    hidden_acts = ones(epochs, ny_normal*2) * -100;
    q_activations = ones(epochs, n.nz+n.nzs) * -100;
    deltas = zeros(1,epochs);
    
    correct_perc = zeros(1,epochs);
    trial_choices = zeros(epochs,n.nz);
    
    trial_types = ones(epochs,1) * -1;
    trial_ends = zeros(epochs, 1);
    
    
    
    
    new_input = t.nwInput;
    reward = 0;
    trialend = false;
    
    rewards = ones(1, epochs)*-1;
    e_rewards = zeros(1,epochs);
    
    trialno = 1;
%     w51 = zeros(n.ny_normal,epochs);
%     w26 = zeros(n.ny_normal,epochs);
%     wy15 = zeros(n.nzs+1,epochs);
    res_trial_stats = false;
    tic = 1;
%     t.showdistractors = 1;
%     t.reward_vs = 0;
%     t.reward_color = 1;
    wxy = n.weights_xy;
    for i=1:epochs % an epoch is a point in time, a trial contains multiple epochs (defined by the CAPITALSTATES properties of the task)
        if ~ProgramReady
            
            %%% Update Network
            [action] = n.doStep(new_input,reward, trialend);
%             n.prev_action
            % Network values:
            input_acts(i,:) = n.noiseless_input;
            hidden_acts(i,:) =  n.Y';
%             q_activations(i,:) =  n.qas'; %
            e_rewards(i) = n.previous_critic_val; % Expected reward
            deltas(i) = n.delta; % TD-error
            trial_choices(i,:) = n.Z; % action on timestep
            
            % Task values:
            states(i) = t.STATE;
            trial_types(i) = t.intTrialType;
            rewards(i) = reward; % Reward for previous action
%             w51(:,i) = n.weights_xy(51,1:n.ny_normal)';
%             w26(:,i) = n.weights_xy(26,1:n.ny_normal)';
%             wy15(:,i)= n.weights_zzs(:,4);
            if trialno<1001
                %                 correct_perc(i) = t.getPerformance();
                correct_perc(i) = numel(find(trial_res==1))/trialno;
            else
                correct_perc(i) = numel(find(trial_res(trialno-1000:trialno)>0))/numel(trial_res(trialno-1000:trialno));
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
                % Total number of trials in this run:
                trialno = trialno + 1;
                b = find(trial_ends==1);
                
               
                
                if numel(b)>1001 && t.reward_position == 0
                    if  numel(find(rewards(b(max(1,trialno-10000):trialno-1)-1)>=0.4))>9250
                        t.reward_position = 1;
                        
                        tic =trialno;
%                       keyboard
                    end
                end
                
                
            end
            %%% Update Task
            [new_input, reward, trialend] = t.doStep(action);
             if reward>0
                r = 1;
            end
            connection_counter=connection_counter+1;      % number of iterations between redrawing of connections
            if (mod(i,DisplayStepSize) == 0)
                figure(h);
                plot(a,1:epochs, rewards,'.',1:epochs,e_rewards,'r.',1:epochs,correct_perc,'k.');ylim([-1.2 2.5])
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

save('150306_resultsFG_fb3.mat', 'n', 't', 'gamma', 'beta', 'lambda', 'ny_memory', 'ny_normal', 'trial_types','rewards')