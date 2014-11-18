%
% Test run of Yang and Shadlen Task
%


% Set random seed:
seed = 1;



% Parameters
gamma  = 0.9;
beta   = 0.15;
lambda = 0.30;


% Number of trials (max):
n_trials = 250000;


% Store success/failure of individual trials: 
trial_res = zeros(1, n_trials);

stopping_crit = 0.85;

task_settings = [1 1 1000; % possible symbols, sequence length, least # train-samples (and window size)
                 2 1 1500;
                 3 1 2000;
                 4 1 2500;
                 5 1 3000;
                 5 2 10000;
                 5 3 10000;
                 5 4 20000];


tic;

h = figure;
a = axes();
set(a,'NextPlot','replace');

windowSize = 500;
learn_points = ones(size(task_settings,1),1); 

% for experiments, fix the random generator:
rnd_stream = RandStream('mt19937ar','Seed', seed);
RandStream.setDefaultStream(rnd_stream);

% Create Network and Task:
t = YSFourTask();

t.intertrial_dur = 1; 
t.mem_dur = 2;

n = SNetwork();

n.n_inputs = length(t.nwInput);
n.ny_memory = 4;
n.ny_normal = 3;

n.input_noise = false;

% Set memory-neuron input cells (posneg / sustain-filter);
n.input_method = 'posnegcells';

n.setInstantTransform('shifted-sigmoid', 2.5);
n.setMemoryTransform('shifted-sigmoid', 2.5);

n.beta   = beta;
n.lambda = lambda;
n.gamma  = gamma;


n.controller = 'max-boltzmann';
n.exploit_prob = .975;

n.init_network();



%%%%% RUN %%%%%

new_input = t.nwInput;
reward = 0;
trialend = false;

converged = false;
c_epoch = -1;
trial_running = true;

c_settingTime = 0;
c_setting = 1;

ps = task_settings(1,1);
sl = task_settings(1,2);
res_trial_stats = false;






for i=1:n_trials

    % Run trial:
    while(trial_running && ~converged)

      [action] = n.doStep(new_input,reward, trialend);


      if (trialend)
        c_settingTime = c_settingTime + 1;
        % Store Success/Failure of episode

        if(t.lastTrialSuccess)
          trial_res(i) = 1;
        else
          trial_res(i) = 0;
        end

        % Determine task difficulty (shaping)
        if((c_setting < size(task_settings,1))  && ...
            (c_settingTime > task_settings(c_setting,3)))
          % Compute mean performance:
          mean_perf = mean(trial_res((i - task_settings(c_setting,3)):i));

          if (mean_perf >= stopping_crit)

            learn_points(c_setting) = i;

            c_settingTime = 0;
            c_setting = c_setting + 1;
            ps = task_settings(c_setting,1);
            sl = task_settings(c_setting,2);


            res_trial_stats = true;
            disp('########################## TASK SETTING CHANGE ##########################');
            plot(a, 1:n_trials, filter(ones(1,windowSize)/windowSize,1,trial_res));
            % Plot learn points (vline plots to gca);
            gca = a;
            vline(learn_points)
            drawnow;
          end
        end

         % Determine task difficulty (`recording' in most difficult configuration)
         if ((c_setting == size(task_settings,1)) && ...
                 (c_settingTime > task_settings(c_setting,3)))
             
             % Compute mean performance:
             mean_perf = mean(trial_res((i - task_settings(c_setting,3)):i));
             
             
             if (mean_perf >= stopping_crit)
                 fprintf('Learning Crit. Reached after %d trials\n', i);
                 learn_points(c_setting) = i;
                 converged = true;
                 c_settingTime = 0;
                 data_epoch = i;
                 c_epoch = i;
             end
         end


        if(res_trial_stats)
          t.resetTrialStats();
          res_trial_stats = false;
        end

        t.possible_symbols = ps;
        t.sequence_length = sl;

        trial_running = false;
      end

      [new_input, reward, trialend] = t.doStep(action);


    end % Trial
      
    trial_running = true;


    if (converged)
      break;
    end

end % trial-block
plot(a, 1:n_trials, filter(ones(1,windowSize)/windowSize,1,trial_res));
% Plot learn points (vline plots to gca);
gca = a;
vline(learn_points)

%%%%%%%%%%%%%%%

learn_points





