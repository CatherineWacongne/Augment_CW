%
% Test run of Gottlieb and Goldberg Task 
%

clear;
global DisplayStepSize;
global ProgramReady;
ProgramReady=0;

% Set random seed:
seed = 10;

% Test length:
epochs = 50000;
n_trials = 10000;

ny_memory = 4;
ny_normal = 3;

% Parameters
gamma  = 0.9;
beta   = 0.15;
lambda = 0.30;

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
DisplayStepSize=1000;                  % PR was 1000
uicontrol('Style', 'edit', 'String', int2str(DisplayStepSize),...
       'Position', [20 30 50 30],'Callback',@edittext1_Callback);     

% control of quitting the program
uicontrol('Style', 'pushbutton', 'String', 'Quit',...
          'Position', [20 20 50 20],'Callback','quit_Callback');     

h3 = figure('Position',[190 scrsz(4)/2.4 scrsz(3)/2.8 scrsz(4)/2]);   % this figure is for showing the display with visible input
a3 = axes();
set(a3,'NextPlot','add');
plot(a3,1:10,1:10,'Color',[1,1,1]);

     
% Reset all variables:
% n_trials (estimated number of completed trials) 
trial_res = zeros(1, n_trials);

states = zeros(epochs, 1);
input_acts = ones(epochs, 4) * -100;
hidden_acts = ones(epochs, (ny_memory + ny_normal)) * -100;
q_activations = ones(epochs, 3) * -100;
deltas = zeros(1,epochs);

correct_perc = zeros(1,epochs);
trial_choices = zeros(epochs,3);

trial_types = ones(epochs,1) * -1;
trial_ends = zeros(epochs, 1);

% for experiments, fix the random generator:
rnd_stream = RandStream('mt19937ar','Seed', seed);
RandStream.setDefaultStream(rnd_stream);

% Task Settings:
t = GGSATask();

%t.intertrial_dur = 1; 
%t.mem_dur = 2;


% Network Settings:
n = SNetwork();
n.limit_traces = false;
n.input_method = 'posnegcells';

n.n_inputs = length(t.nwInput);
n.ny_memory = ny_memory;
n.ny_normal = ny_normal;
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

new_input = t.nwInput;
reward = 0;
trialend = false;

rewards = ones(1, epochs)*-1;
e_rewards = zeros(1,epochs);

trialno = 1;

res_trial_stats = false;

for i=1:epochs
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
        t.show_DisplayGGSA(h3,a3,n,new_input,reward,trialno);
        drawnow;
      end
  end
end % For epoch
plot(a,1:epochs, rewards,'.',1:epochs,e_rewards,'r.',1:epochs,correct_perc,'k.');

% Now, check whether this run converged (last 10% at least):
[converged, c_epoch]  = calcConv(trial_res, 0.1 )
convergence_res = [converged, c_epoch]

%   if (converged == 1)
%     % Save all relevant variables to file:
%     save([logfile '_' num2str(seeds(seed_idx)) '.mat'], ...
%       'states', 'input_acts','hidden_acts','q_activations','rewards', ...
%       'deltas', 'trial_types', 'trial_ends','trial_res');
% 	save(['ds_network_' num2str(seeds(seed_idx)), '.mat'],'n');
%   end



