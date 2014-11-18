classdef GGSATask < handle & Task
    % Gottlieb and Goldberg [Delayed] (anti) Saccade task.
    % Difference with standard SA task is that P/A signal is given by the
    % fixation point.
    
   properties(SetAccess=protected, GetAccess=public)
        trialTarget = 0;
        trialType = [0 0];
    
        selectedTrial = 0;
        
        intTrialType = 0;
        prev_intTrialType = -1;
       
        fp_type = 0;    % 1 = Pro-saccade, 2 = Anti;
		cue = 0;        % 0 = left, 1= right
		trialSetExternal = false;
        fp_on = 0;      % used for plotting
        tar_on = 0;     % used for plotting
        left_on = 0;    % used for plotting
        old_fixpos=0;   % used for plotting: previously plotted fixation position
        old_reward=0;
   end
    
   properties
     only_pro = false; % both fixation points signify pro trial. 
   end
   
  methods
    
    show_DisplayGGSA(obj,h3,a3,n,new_input,reward,trialno);
    
    % Constructor:
    function obj = GGSATask()
      obj.stateReset();
      obj.prev_intTrialType = obj.intTrialType;
      obj.intTrialType = -1;
      obj.fp_type = 0;
      obj.cue = 0;
    end


    function stateReset(obj)
        stateReset@Task(obj); % Call superclass stateReset method
    end
      
    function setDefaultNetworkInput(obj)
      obj.nwInput = [0 0 0 0];
      % Fix_P, Fix_A, Left-target, Right-target
    end
    
    function [nwInput, reward, trialend] = doStep(obj, networkAction)

       % Quick sanity check on input
       obj.checkInput(networkAction);
       
       obj.trialEnd = false;

        switch (obj.STATE)
            case obj.INTERTRIAL
                %disp('INTERTRIAL')
                if (obj.counter == obj.intertrial_dur)
                    obj.pickTrialType();
                    obj.nwInput(obj.fp_type) = 1; % Activate Fixation point

                    obj.STATE = obj.WAITFIXSTATE;
                    obj.resetCounter(); % reset counter
                else
                    obj.incrCounter()
                end

            case obj.WAITFIXSTATE % Wait with trial until fixation
              %disp('WAITFIX')
              if (obj.counter <= obj.waitfix_timeout)  
                if (all(networkAction == [1,0,0])) % Fixation
                      disp('Start Fixation')
                      obj.STATE = obj.FIXSTATE;
                      obj.resetCounter(); 
                else
                  obj.incrCounter();
                end
              else
                obj.stateReset();
              end

           case obj.FIXSTATE

               %disp('FIX')
                
                if (~all(networkAction == [1,0,0])) % Trial failed
                    disp('Broke Fixation')
                    obj.stateReset();

                else
                  if (obj.counter == obj.fix_dur) % Fixated enough
                    disp('Fixation Reward')

                    obj.cur_reward = obj.cur_reward + obj.fix_reward;
                    obj.resetCounter();

                    % Ugly: evaluate next trial state:
                    if (obj.mem_dur > 0)
                       obj.STATE = obj.MEMSTATE;
                    else
                       % Switch off fixation point
                       obj.nwInput(obj.fp_type) = 0;
                       obj.STATE = obj.GOSTATE;
                    end
                    % Show targets:
                    obj.nwInput(3:4) = obj.trialType;
                    
                  else
                    obj.incrCounter();
                  end
                end

            case obj.MEMSTATE
                  % disp('MEMSTATE')
               
               % Make sure no cues are shown:
               obj.nwInput(3:4) = [0 0]; 
               % Check if still fixating:
               if (networkAction(1) ~= 1)
                 disp('Failure')
                 obj.stateReset();           
               else
                if( obj.counter == obj.mem_dur)
                    obj.resetCounter();

                    obj.nwInput = [0 0 0 0];

                    obj.STATE = obj.GOSTATE;
                else
                    obj.incrCounter();
                end
               end    
                 
            case obj.GOSTATE
              %disp('GO')
                % Wait until fixation is broken                   
                if (obj.counter <= obj.max_dur) % Trial expired?
                    if (networkAction(1) ~= 1)  % Broke Fixation

                        if (all(networkAction(2:3) == obj.trialTarget) ) % Correct:
                            disp('Reward!')
                            obj.correct_trials = obj.correct_trials + 1;

                            obj.cur_reward = obj.cur_reward + obj.fin_reward;
                        else
                            disp('Failure')
                        end

                        obj.stateReset();
                    else
                      obj.incrCounter();
                    end
                else
                    disp('Failure')
                    obj.stateReset();
                end
        end

        reward  = obj.cur_reward;
        nwInput = obj.nwInput;
        trialend = obj.trialEnd;
        obj.cur_reward = 0; % Reset current accumulated reward

    end
    
    
    
    function createTaskVisualizer(obj,figure_handle,axes_handle)

      obj.handles_tv = zeros(1,4);
      obj.handles_tv(1) = plot(axes_handle,5,5,'k+'); % FIX: Pro
      obj.handles_tv(2) = plot(axes_handle,5,5,'r+'); % FIX: Anti
      
      obj.handles_tv(3) = rectangle('Parent',axes_handle,'Position',[2,4.5,1,1],'Curvature',[1,1]); % LEFT
      obj.handles_tv(4) = rectangle('Parent',axes_handle,'Position',[7,4.5,1,1],'Curvature',[1,1]); % RIGHT
      
      set(gca,'XLim',[0,10],'YLim',[0,10]);
    end
    
    
    function updateTaskVisualizer(obj,figure_handle, axes_handle)

      % Check generated input for network:
      for i = 1:4
        if (obj.nwInput(i) == 1)
          set(obj.handles_tv(i),'Visible', 'on');
        else
          set(obj.handles_tv(i),'Visible','off');
        end
      end
      
    end
   
        
	function setTrialType(obj, cue, fp_type)
		% Externally set the trial type
		% Note that trial type does not change automatically anymore
		obj.fp_type = fp_type;
		obj.cue = cue;
		obj.trialSetExternal = true;
		
	end

    function pickTrialType(obj)
      % Generate trial
      
      % Generate a random trial if type has not been externally set.
      if (~obj.trialSetExternal)
              obj.cue = randi(2)-1;
              % Select context / trial-type: 
              obj.fp_type = randi(2);
      end
            
            
      if (obj.cue)
          obj.trialType = [0,1]; % right cue
          obj.intTrialType = 0;
      else
          obj.trialType = [1,0]; % left cue
          obj.intTrialType = 1;
      end

      obj.trialTarget = obj.trialType;

      if (~obj.only_pro)

        if (obj.fp_type == 2)
          obj.trialTarget = not(obj.trialType);
          obj.intTrialType = obj.intTrialType + 2;
        else
          obj.trialTarget = obj.trialType;
        end
      end
    end
  end
    
  
 
    
end

