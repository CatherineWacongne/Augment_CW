classdef Task < handle
    %TASK Abstract class
    
   properties(SetAccess=protected, GetAccess=public)
        STATE = 0;
        counter = 0;
        trialEnd = false;
   end
    
   
    % Enum-like hack:
    % For now, these properties are assumed to be shared over all 
    % Task types
    properties(Constant)
        INTERTRIAL = 0;
        WAITFIXSTATE = 1;
        FIXSTATE = 2;
        TARSTATE = 3;
        MEMSTATE = 4;
        GOSTATE = 5;
        SEQSTATE = 6;
    end
    
    properties
      
        n_actions = 3;
        
        intertrial_dur = 0; 
        fix_dur = 0; % Duration of fixation;
        
        waitfix_timeout = 10 % Maximum ammount of steps to wait for fixation;
        max_dur = 8; % Maximum ammount of steps to wait in GO state;
        
        mem_dur = 2; % Number of delay-steps
       
        cur_reward = 0;
        
        fix_reward = 0.2; % Reward for fixating
        fin_reward = 1.5; % Reward for correct completion of task

        nwInput; % Input shown to network [Fix,Go,Mem, variable]
       
        % Keeps track of performance on task:
        total_trials = 0;
        correct_trials = 0;
        
        % For visualizer:
        handles_tv = [];
        
 
    end


    
    % Abstract methods:
    methods (Abstract = true)
      [nwInput, reward, trialend] = doStep(obj, networkAction);
      setDefaultNetworkInput(obj);
      
      % For visualization:
      createTaskVisualizer(obj,figure_handle, axes_handle);
      updateTaskVisualizer(obj,figure_handle, axes_handle);
    end
    

    % Shared public methods
    methods
      
      
      function value = getPerformance(obj)
        if (obj.total_trials ~= 0)
          value = obj.correct_trials / obj.total_trials;
        else
          value = 0.;
        end
        
      end
      
      % Reset the trial statistics
      function resetTrialStats(obj)
        obj.total_trials = 0;
        obj.correct_trials = 0;
      end
      
      
      function stateReset(obj)
        obj.trialEnd = true;
        obj.resetCounter();
        obj.setDefaultNetworkInput();
        obj.STATE = obj.INTERTRIAL;
        obj.total_trials = obj.total_trials + 1;
      end
      
      % Get current state
      function value = get.STATE(obj)
          value = obj.STATE;
      end
      
      %% Functions for Counter
      function incrCounter(obj)
          obj.counter = obj.counter + 1;
      end

      function resetCounter(obj)
          obj.counter = 0;
      end
      
      function checkInput(obj, networkAction)
        if (nargin ~= 2 || ...
            (length(networkAction) ~= obj.n_actions) || ...
            sum(networkAction) ~= 1)
          % Create exception
          ex=MException('Task:doStep:InputError','Task:DoStep: input not correct');
          throw(ex)
        end
      
      end
      
    end

end

