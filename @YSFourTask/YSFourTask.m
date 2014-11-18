classdef YSFourTask < handle & Task
    %YSTwoTask Implementation of Yang and Shadlen (2007) Probabilistic
    % classification task, with four retinotropic locations
    
    
   properties(SetAccess=protected, GetAccess=public) 
        trialInput = 0;
        selectedTrial = 0;
        lastTrialSuccess = false;
        trialSuccess = false;
   end
    

    properties        
        task_type = 0; % 0 for immediate (symbols remain visible during GO)
                       % 1 for delayed sequence (symbols disappear during
                       % GO)
                         
        trial_target = [0 0];
        trial_type = -1;
        intTrialType = -1;
        prev_intTrialType = -1;
              
        n_symbols = 10; % Number of distinct visual symbols.
             
        
        seq_idx = 1; % Place in sequence
      
        sequence_length = 1; % 1-4 to set the ammount of symbols generated
                       
        possible_symbols = 1; % Allowed symbols (to scale training)
                              % 1 means that only ~(+/-)inf-weighted symbols
                              % can be selected.
                              % 2 means ~(+/-)inf and (+/-).9 etc.
        handles_tv_symbols = [];
        
        
       % L-symbols (1-5), R-symbols (6-10)
       symbol_weights = [-99, -0.9, -0.7, -0.5, -0.3, 99, 0.9, 0.7, 0.5, 0.3];
        
       % Dynamic variables.
       sequence = [];
       sequence_symbol = []; 
      
       weight = 0;
       prob_r = 0;
       prob_l = 0;
        
       
       retina = zeros(4,10);
        
    end

    methods
  
       
      
      % Constructor:
      function obj = YSFourTask()
        obj.stateReset();
        obj.fin_reward = 1;
      end

      function stateReset(obj)
        stateReset@Task(obj); % Call superclass stateReset method
        obj.seq_idx = 1; % Reset sequence index
        obj.prev_intTrialType = obj.intTrialType;
        obj.intTrialType = -1;
       
        obj.lastTrialSuccess = obj.trialSuccess;
        obj.trialSuccess = false;
        
        obj.retina = zeros(4,obj.n_symbols);
        
        obj.weight = 0;
        obj.prob_r = 0;
        obj.prob_l = 0;
      end

      function setDefaultNetworkInput(obj)
        % [F [Symbols] * 4]
        obj.nwInput = [0 zeros(1,obj.n_symbols*4)];
      end
         
      function [nwInput, reward, trialend] = doStep(obj, networkAction)

          % Quick sanity check on input
          if (nargin ~= 2 || ...
              (length(networkAction) ~= obj.n_actions) || ...
              sum(networkAction) ~= 1)
            % Create exception
            ex=MException('Task:doStep:InputError','Task:DoStep: input not correct');
            throw(ex)

          end

         obj.trialEnd = false;

          switch (obj.STATE)
              case obj.INTERTRIAL
                
                 if (obj.intTrialType == -1)
                  obj.generateTrial();
                 end
                
                  %disp('INTERTRIAL')
                  if (obj.counter >= obj.intertrial_dur)
                      obj.generateTrial();
                      obj.nwInput(1) = 1; % Activate Fixation point

                      obj.STATE = obj.WAITFIXSTATE;
                      obj.resetCounter(); % reset counter
                  else
                      obj.incrCounter()
                  end

              case obj.WAITFIXSTATE % Wait with trial until fixation
                  if (all(networkAction == [1,0,0])) % Fixation
                      disp('Start Fixation')
                      obj.STATE = obj.FIXSTATE;
                      %obj.resetCounter(); 
                  end

             case obj.FIXSTATE

                  obj.incrCounter();

                  if (~all(networkAction == [1,0,0])) % Trial failed
                      disp('Broke Fixation')
                      obj.stateReset();

                  elseif (obj.counter > obj.fix_dur) % Fixated enough
                      disp('Fixation Reward')

                      obj.cur_reward = obj.cur_reward + obj.fix_reward;
                      obj.resetCounter();

                      % Activate first symbol 
                      obj.updateRetina();
                      
                      obj.STATE = obj.SEQSTATE;

                  end

                  
              case obj.SEQSTATE
%                 disp('SEQSTATE')
                obj.incrCounter();
                
                % Check if still fixating:
                 if (networkAction(1) == 1)

                    % Check if all symbols in sequence have been shown,
                    % and move to appropriate state:
                    if (obj.seq_idx <= obj.sequence_length)
                     % Activate next symbol
                     obj.updateRetina();
                      
                    else % All sequence elements shown:
                      
                      % Clear symbols.
                      obj.clearRetina();
                      
                      if (obj.mem_dur ~= 0)   
                          obj.STATE = obj.MEMSTATE;
                      else
                          % Switch off fixation point (->GO)
                          obj.nwInput(1) = 0;
                          obj.STATE = obj.GOSTATE;
                      end
                        obj.resetCounter();
                    end

                 else
                    disp('Failure')
                    obj.stateReset();
                 end
              
              case obj.MEMSTATE
%                  disp('MEMSTATE')
                

                 % Remove all symbol inputs:
                 obj.clearRetina();
                 
                 % Check if still fixating:
                 if (networkAction(1) == 1)  
                  if( obj.counter >= obj.mem_dur)
                      obj.resetCounter();
                      
                      obj.nwInput(1) = 0; % Switch off fixation point
                      obj.STATE = obj.GOSTATE;

                  end 
                  % Increase counter for memory time-step
                  obj.incrCounter();
                 else
                    disp('Failure')
                    obj.stateReset();           
                 end    
                 

              case obj.GOSTATE
%                 disp('GOSTATE')
                  obj.incrCounter();
                  
                  % Wait until fixation is broken                   
                  if (obj.counter <= obj.max_dur) % Trial expired?
                      if (networkAction(1) ~= 1)  % Broke Fixation

                        
                          if (all(obj.trial_target == [1,1]))
                            fprintf('Correct. ');
                            obj.correct_trials = obj.correct_trials + 1;
                            obj.trialSuccess = true;
                             
                          elseif (all(networkAction(2:3) == obj.trial_target) ) % Correct:
                              fprintf('Correct. ');
                              obj.correct_trials = obj.correct_trials + 1;
                              obj.trialSuccess = true;
                          else
                              fprintf('Failure. ');
                          end
                          
                          
                          % Now stochastically generate reward:
                          reward = obj.generateReward(networkAction(2:3));
                          fprintf('Reward = %.1f\n',reward);
                          obj.cur_reward = obj.cur_reward + reward;
                          obj.stateReset();
                      end
                  else
                      fprintf('Failure to select action...\n');
                      obj.stateReset();
                  end

          end

          reward  = obj.cur_reward;
          nwInput = obj.nwInput;
          trialend = obj.trialEnd;
          obj.cur_reward = 0; % Reset current accumulated reward

      end
        
      function [reward] =  generateReward(obj, action)
        
        rnd = rand;
        reward = 0;
        
        % Sanity check: at least one action selected?
        assert(all(action == [0 1]) || all(action == [1 0]));
        
        if (all(action == [0 1])) % Choice was R-target
          if (rnd < obj.prob_r)
            reward = obj.fin_reward;
          end
        elseif(rnd < obj.prob_l) % Choice was L-target
            reward = obj.fin_reward;
        end
        
      end
      
      

      % Generate a trial, which is:
      % A sequence of symbols plus the activation order of the 
      %  retinotropic areas
      % The function also sets the correct action that should be taken by 
      % a perfect observer, with knowledge of the symbol-weights (i.e.,
      % choose the target which has the highest probability of yielding
      % reward).
      %
      function generateTrial(obj)
        
        obj.sequence_symbol = zeros(1,obj.sequence_length);
       
        perm = randperm(4);
        obj.sequence = perm(1:obj.sequence_length);
       
        obj.weight = 0;
        for i=1:obj.sequence_length
          % Select either R or L symbol:
          if (randi(2) == 1) % Generate L-symbol
            obj.sequence_symbol(i) = randi(obj.possible_symbols);
          else % Generate R-symbol
            obj.sequence_symbol(i) = randi(obj.possible_symbols) + 5;
          end
          obj.weight = obj.weight + obj.symbol_weights(obj.sequence_symbol(i));
          
        end

        % Calculate final reward probabilities for L/R choices:
 
        obj.prob_r = obj.calcProbRfromWeights(  ...
          obj.symbol_weights(obj.sequence_symbol) );
        obj.prob_l = 1 -  obj.prob_r;
        
        % Determine `correct' choice 
        if ( obj.prob_r >  obj.prob_l)
          obj.trial_target = [0 1]; % Saccade should be made to right
          obj.trial_type = 1;
          obj.intTrialType = 1;
        elseif ( obj.prob_r <  obj.prob_l) % Saccade should be made to left
          obj.trial_target = [1 0];
          obj.trial_type = 0;
          obj.intTrialType = 0;
        else % Equal probability: both should be considered correct.
          obj.trial_target = [1 1];
          obj.trial_type = 3;
          obj.intTrialType = 3;
        end

      end
      
      
      % Calculate the probability of the Right target being rewarded as a
      % function of the shape-weights:
      
      function [pr_R] = calcProbRfromWeights(obj, weights )
        
        summed_weight = sum(weights);
        
        pr_R = 10^( summed_weight ) / ( 1 + 10^( summed_weight ));
        
        % Deal with infinite weight-shapes:
        if (summed_weight >= 90)
          pr_R = 1;
        elseif (summed_weight <= -90)
          pr_R = 0;
        end
        
      end
      
      
      
      
      % Clear retina of all inputs
      function clearRetina(obj)
        
        % Set retina to all zeros
        obj.retina = zeros(1,obj.n_symbols * 4);
        
        % Note that retina(:) makes a list, taking columns from retina
        % retina(:)' does *NOT* give the correct result 
        obj.nwInput(2:end) = reshape(obj.retina',[],1)';

      end
      
      
      % Add next symbol to the retina, and update the input to the network
      % Note that the sequence-idx is increased here
      function updateRetina(obj)
        
        % Create a new [1x10] vector of zeros (clear retina location)
        newInput = zeros(1,obj.n_symbols);
        newInput(obj.sequence_symbol(obj.seq_idx)) = 1;

        % Update retina and flatten it for network-input 
        obj.retina(obj.sequence(obj.seq_idx),:) = newInput;
        
        % Note that retina(:) makes a list, taking columns from retina
        % retina(:)' does *NOT* give the correct result 
        obj.nwInput(2:end) = reshape(obj.retina',[],1)';
  
        % Increase sequence-index
        obj.seq_idx = obj.seq_idx + 1;
        
      end
      
     
      
     % For visualization:
     function createTaskVisualizer(obj,figure_handle,axes_handle)
      % This is a stub
      assert(false);
      
     end
    
    
    function updateTaskVisualizer(obj,figure_handle, axes_handle)
      % This is a stub
      assert(false);
    end
    
    end
end

