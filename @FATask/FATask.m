classdef FATask < Task
  %FATask Simple implementation of Freedman and Assad Motion Cat. Task.
  %   Detailed explanation goes here
  
  
  
  properties(SetAccess=protected, GetAccess=public) 
    lastTrialGO = false;
    trialGO = false;
  end
   
     
  properties
    min_angle = 0;
    max_angle = 359;
    
    r_i = 1;
    
    cat_task = false;
   
    intTrialType = 0;
    
    input_angles = (0:30:359) .* (pi / 180);
    
    cat_boundary = [135, 315]  .* (pi / 180); % Defines category boundary
    % everything between these angles is in category 2, rest in 1.
    in_angle = [];
    target = [];
    
    trialSetExternal = false;
    old_ori=-1;     % used for plotting: previously plotted orientation
    old_fixpos=0;     % used for plotting: previously plotted fixation position
    old_reward=0;
    stim_handle1=-1;
    stim_handle2=-1;
  end
  
  

  
  
  methods

    show_Display(obj,h3,a3,n,new_input,reward);

    % Constructor:
    function obj = FATask()
      obj.n_actions = 3; % Fixate + Classify
       
      obj.stateReset();
      
    end
    
    function stateReset(obj)
        stateReset@Task(obj); % Call superclass stateReset method
        obj.lastTrialGO = obj.trialGO;
        obj.trialGO = false;
    end
    
    function setDefaultNetworkInput(obj)
      obj.nwInput = [0 -1];
      % Fix, Go, angle
    end
    
    
    function [nwInput, reward, trialend] = doStep(obj, networkAction)

       % Quick sanity check on input
       obj.checkInput(networkAction);
       networkAction = obj.convertNetworkAction(networkAction);
       
       obj.trialEnd = false;

       switch obj.STATE
         case obj.INTERTRIAL
%                 disp('INTERTRIAL')
                if (obj.counter == obj.intertrial_dur)
                    obj.generateTrial();
                    obj.nwInput(1) = 1; % Activate Fixation point

                    obj.STATE = obj.WAITFIXSTATE;
                    obj.resetCounter(); % reset counter
                else
                    obj.incrCounter()
                end

            case obj.WAITFIXSTATE % Wait with trial until fixation
%               disp('WAIT FIX')
              if (obj.counter <= obj.waitfix_timeout)  
                if (networkAction(1) == 1) % Fixation
%                     disp('Start Fixation')
                    obj.STATE = obj.FIXSTATE;
                    obj.resetCounter();
                else
                  obj.incrCounter();
                end
              else
                obj.stateReset();
              end

           case obj.FIXSTATE

                
%                disp(' FIX')
                if (~networkAction(1) == 1) % Trial failed
%                     disp('Broke Fixation')
                    obj.stateReset();

                else
                  if (obj.counter == obj.fix_dur) % Fixated enough
                    disp('Fixation Reward')

                    obj.cur_reward = obj.cur_reward + obj.fix_reward;
                    obj.resetCounter();

                    % Ugly: evaluate next trial state:
                    if (obj.mem_dur == 0)
                        obj.STATE = obj.GOSTATE;
                        obj.nwInput(1) = 0; % Switch off fixation point
                    else
                        obj.STATE = obj.MEMSTATE;
                    end

                    % Show input-angle:
                    obj.nwInput(2) = obj.in_angle;
                  else
                    obj.incrCounter();
                  end
                end

            case obj.MEMSTATE
%                    disp('MEMSTATE')
               obj.nwInput(2) = -1;
               
               % Check if still fixating:
               if (networkAction(1) ~= 1)
%                   disp('Failure')
                  obj.stateReset();    
               else
                if( obj.counter == obj.mem_dur)
                    obj.resetCounter();

                    obj.nwInput = [0 -1];

                    obj.STATE = obj.GOSTATE;
                else
                obj.incrCounter();

                end             
               end    

            case obj.GOSTATE
%               disp('GO')
%                 obj.incrCounter();

                % Wait until fixation is broken                   
                if (obj.counter <= obj.max_dur) % Trial expired?
                    if (networkAction(1) ~= 1)  % Broke Fixation
                        obj.trialGO = true;
                      
                        if (networkAction(2) == obj.target ) % Correct:
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
    
    
    function [networkAction] = convertNetworkAction(obj, nwAction)
      
      clasf = find(nwAction(2:end),1,'first');
      if (isempty(clasf))
        clasf = 0;
      end
      
      
      networkAction = [nwAction(1) clasf];
    end
    
    function generateTrial(obj)
      % Generate one of the possible input-angles:
      
      if (~obj.trialSetExternal)
        obj.r_i = randi(length(obj.input_angles));
      end
      
      obj.in_angle = obj.input_angles(obj.r_i);

      obj.target = obj.r_i;
      
      % Categorization-version of task:
      if (obj.cat_task)
        if ((obj.cat_boundary(1) <= obj.in_angle) && (obj.in_angle <= obj.cat_boundary(2)))
          obj.target = 2; % L
        else
          obj.target = 1; % R
        end
       end
      
    end
    
           
	function setTrialType(obj, trialtype)
		% Externally set the trial type
		% Note that trial type does not change automatically anymore
		obj.r_i = trialtype;
    
    obj.trialSetExternal = true;
		
	end
    
    
    function createTaskVisualizer(obj,figure_handle,axes_handle)
        assert(false);
    end
    
    
    function updateTaskVisualizer(obj,figure_handle, axes_handle)
      assert(false);
        
    end
  end
  
end

