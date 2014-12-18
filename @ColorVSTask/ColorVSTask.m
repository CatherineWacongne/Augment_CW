classdef ColorVSTask < handle & Task
    % Pretraining for the Visual Search Task.
    
    
    properties(SetAccess=protected, GetAccess=public)
        
        intTrialType = 0;    % (cue_col-1)*n_pos + cue_pos (= index of input =1 )
        prev_intTrialType = -1;
        fp_input_index = 25; % index of the input vector that represents the fixation point
        fix_action_index = 4;
        
        n_col = 3;
        n_pos = 8;
        cue_pos = 1;         % 1
        cue_col = 0;         % 1 to 3
        trialTarget = 0;     % cue_col
        target_pos = 0;
        
        distr_col = zeros(1,7);
        display_col = zeros(1,8);
        cueInput;
        
        trialSetExternal = false;
        keepTrialsforGeneralization = false;
        
        
        fp_on = 0;      % used for plotting
        tar_on = 0;     % used for plotting
        left_on = 0;    % used for plotting
        old_fixpos=0;   % used for plotting: previously plotted fixation position
        old_reward=0;
    end
    properties
        train_trials = 0;
        generalization_trials = 0;
        n_genTrials = 100000;
        Color_only = 1;
        
    end
    
    methods
        
        show_DisplayColor(obj,h3,a3,n,new_input,reward,trialno);
        
        % Constructor:
        function obj = ColorVSTask()
            obj.stateReset();
            obj.prev_intTrialType = obj.intTrialType;
            obj.intTrialType = -1;
            obj.n_col = 3;
            obj.n_pos = 8;
            obj.cue_pos = 0;
            obj.cue_col = 0;
            obj.target_pos = 0;
            obj.fp_input_index = 25; % index of the input vector that represents the fixation point
            obj.fix_action_index = 4;
            obj.n_actions = 12;
            obj.mem_dur = 0;
        end
        
        
        function stateReset(obj)
            stateReset@Task(obj); % Call superclass stateReset method
        end
        
        function setDefaultNetworkInput(obj)
            obj.nwInput = zeros(1, obj.n_col*obj.n_pos+1);   % Fix + 8 positions*3colors(R,G,B)
        end
        
        function [nwInput, reward, trialend] = doStep(obj, networkAction)
            
            % Quick sanity check on input
            obj.checkInput(networkAction);
            obj.trialEnd = false;
            
            fixation = networkAction*0;
            fixation(obj.fix_action_index) = 1;
            
            switch (obj.STATE)
                case obj.INTERTRIAL % display fixation
                    %disp('INTERTRIAL')
                    if (obj.counter == obj.intertrial_dur)
                        obj.pickTrialType();
                        obj.nwInput(obj.fp_input_index) = 1; % Activate Fixation point
                        
                        obj.STATE = obj.WAITFIXSTATE;
                        obj.resetCounter(); % reset counter
                    else
                        obj.incrCounter()
                    end
                    
                case obj.WAITFIXSTATE % Wait with trial until fixation
                    %disp('WAITFIX')
                    
                    if (obj.counter <= obj.waitfix_timeout)
                        if (all(networkAction == fixation)) % Fixation
                            disp('Start Fixation')
                            obj.STATE = obj.FIXSTATE;
                            obj.resetCounter();
                        else
                            obj.incrCounter();
                        end
                    else
                        obj.stateReset();
                    end
                    
                case obj.FIXSTATE % wait for the fixation to last obj.fix_dur and displays target at the end
                    
                    %disp('FIX')
                    
                    if (~all(networkAction == fixation)) % Trial failed
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
                                obj.nwInput(obj.fp_input_index) = 0;
                                obj.STATE = obj.SEQSTATE;
                            end
                            % Show cue:
                            
                            obj.nwInput((obj.cue_col-1)*obj.n_pos+obj.cue_pos) = 1;
                            
                            
                        else
                            obj.incrCounter();
                        end
                    end
                    
                case obj.MEMSTATE % errases all cues and switches the fix point off at the end of the delay
                    % disp('MEMSTATE')
                    
                    % Make sure no cues are shown:
                    obj.nwInput(1:obj.n_col*obj.n_pos) = zeros(1,obj.n_col*obj.n_pos);
                    % Check if still fixating:
                    if (networkAction(obj.fix_action_index) ~= 1)
                        disp('Failure')
                        obj.stateReset();
                    else
                        if( obj.counter == obj.mem_dur)
                            obj.resetCounter();
                            
                            obj.nwInput = zeros(1,obj.n_col*obj.n_pos+1);  % turns everything off.
                           
                                obj.STATE = obj.GOSTATE;
                           
                        else
                            obj.incrCounter();
                        end
                    end
                case obj.SEQSTATE
                    if (networkAction(obj.cue_col) ~= 1)
                        disp('Failure')
                        obj.stateReset();
                    else
                        if( obj.counter == obj.fix_dur)
                            obj.cur_reward = obj.cur_reward + 3*obj.fix_reward; % second small reward for color task
                            disp('Color Reward !')
                            obj.resetCounter();
                            obj.nwInput = zeros(1,obj.n_col*obj.n_pos+1);
                            for d = 1:8
                                if obj.display_col(d)>0
                                    obj.nwInput((obj.display_col(d)-1)*obj.n_pos + d)=1; % bring the targets
                                end
                            end 
                            if obj.Color_only
                                obj.stateReset();
                            else 
                                obj.STATE = obj.GOSTATE;
                            end
                        else
                            obj.incrCounter();
                        end
                    end    
                case obj.GOSTATE
                    %disp('GO')
                    % Wait until fixation is broken
                    if (obj.counter <= obj.max_dur) % Trial expired?
                        if (~all(networkAction == fixation))  % Broke Fixation
                            
                            if (all(networkAction(obj.trialTarget) == 1) ) % Correct:
                                disp('VS Reward!')
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
            
            obj.handles_tv = zeros(1,25);
            
            
            for c = 1:3
                col_point = zeros(1,3);
                col_point(c) = 1;
                obj.handles_tv((c-1)*obj.n_pos+1) = plot(axes_handle, 5, 7, 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
                obj.handles_tv((c-1)*obj.n_pos+2) = plot(axes_handle, 5+2*cos(pi/4), 5+2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
                obj.handles_tv((c-1)*obj.n_pos+3) = plot(axes_handle, 7, 5, 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
                obj.handles_tv((c-1)*obj.n_pos+4) = plot(axes_handle, 5+2*cos(pi/4), 5-2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
                obj.handles_tv((c-1)*obj.n_pos+5) = plot(axes_handle, 5, 2, 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
                obj.handles_tv((c-1)*obj.n_pos+6) = plot(axes_handle, 5-2*cos(pi/4), 5-2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
                obj.handles_tv((c-1)*obj.n_pos+7) = plot(axes_handle, 2, 5, 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
                obj.handles_tv((c-1)*obj.n_pos+8) = plot(axes_handle, 5-2*cos(pi/4), 5+2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point);
            end
            obj.handles_tv(25) = plot(axes_handle,5,5,'k+'); % FIX
            
            set(gca,'XLim',[0,10],'YLim',[0,10]);
        end
        
        
        function updateTaskVisualizer(obj,figure_handle, axes_handle)
            
            % Check generated input for network:
            for i = 1:25
                if (obj.nwInput(i) == 1)
                    set(obj.handles_tv(i),'Visible', 'on');
                else
                    set(obj.handles_tv(i),'Visible','off');
                end
            end
            
        end
        
        
        function setTrialType(obj, cue_col, cue_pos, target_pos)
            % Externally set the trial type
            % Note that trial type does not change automatically anymore
            obj.cue_col = cue_col;
            obj.cue_pos = cue_pos;
            obj.target_pos = target_pos;
            
            poss_col = 0:obj.n_col;
            poss_col(obj.cue_col+1)=[];
            obj.distr_col = poss_col(randi(obj.n_col,1,obj.n_pos - 1));
            obj.display_col = zeros(1,obj.n_pos);
            obj.display_col(obj.target_pos)=obj.cue_col;
            if obj.target_pos==1
                obj.display_col(2:end)=obj.distr_col;
            else
                obj.display_col([1:obj.target_pos-1  obj.target_pos+1:end])=obj.distr_col;
            end
            
            obj.cueInput = (obj.cue_col-1)*obj.n_pos + obj.cue_pos;
            obj.intTrialType = (obj.cue_col-1)*obj.n_pos + obj.target_pos;
            obj.trialTarget = obj.target_pos+obj.fix_action_index;
            obj.trialSetExternal = true;
        end
        
        function pickTrialType(obj)
            % Generate trial
            
            % Generate a random trial if type has not been externally set.
            if (~obj.trialSetExternal && ~obj.keepTrialsforGeneralization)
                obj.cue_col = randi(obj.n_col);
                obj.cue_pos = randi(obj.n_pos);
                obj.target_pos = randi(obj.n_pos);
                poss_col = 0:obj.n_col;
                poss_col(obj.cue_col+1)=[];
                obj.distr_col = poss_col(randi(obj.n_col,1,obj.n_pos-1));
                obj.display_col = zeros(1,obj.n_pos);
                obj.display_col(obj.target_pos)=obj.cue_col;
                if obj.target_pos==1
                    obj.display_col(2:end)=obj.distr_col;
                else
                    obj.display_col([1:obj.target_pos-1  obj.target_pos+1:end])=obj.distr_col;
                end
                obj.cueInput = (obj.cue_col-1)*obj.n_pos + obj.cue_pos;
                obj.intTrialType = (obj.cue_col-1)*obj.n_pos + obj.target_pos;
                obj.trialTarget = obj.target_pos+obj.fix_action_index;
            elseif (~obj.trialSetExternal && obj.keepTrialsforGeneralization)
                trial_code = obj.train_trials(randi(numel(obj.train_trials)));
                obj.setTrialTypeGen(trial_code)
                obj.trialSetExternal = false;
                
                try
                    obj.intTrialType = trial_code;
                catch
                    obj.intTrialType =(obj.cue_col-1)*obj.n_pos + obj.target_pos;
                end
                obj.trialTarget = obj.target_pos+obj.fix_action_index;
                
            end
        end
        
        
        function setTrialTypeGen(obj,trial_code)
            StrCode = num2str(trial_code);
            obj.cue_col = str2num(StrCode(1));
            obj.cue_pos = str2num(StrCode(2));
            obj.target_pos = str2num(StrCode(3));
            poss_col = 0:3;
            poss_col(obj.cue_col+1)=[];
            for d = 1:7
                obj.distr_col(d)=poss_col(str2num(StrCode(d+3)));
            end
            
            obj.display_col = zeros(1,8);
            obj.display_col(obj.target_pos)=obj.cue_col;
            if obj.target_pos==1
                obj.display_col(2:end)=obj.distr_col;
            else
                obj.display_col([1:obj.target_pos-1  obj.target_pos+1:end])=obj.distr_col;
            end
            
            
            obj.cueInput = (obj.cue_col-1)*obj.n_pos + obj.cue_pos;
            obj.intTrialType = (obj.cue_col-1)*obj.n_pos + obj.target_pos;
            obj.trialTarget = obj.target_pos+obj.fix_action_index;
            obj.trialSetExternal = true;
        end
        
        function setTrialsForGeneralisation(obj)
            %% generate the indices of all possible trials
            indices = zeros(1,(obj.n_pos)^2*obj.n_col*(obj.n_col)^(obj.n_pos-1));
            ind=1;
            for c=1:obj.n_col;
                for cp = 1:obj.n_pos;
                    for tp = 1:obj.n_pos;
                        for d1 = 1:obj.n_col;
                            for d2 = 1:obj.n_col;
                                for d3 = 1:obj.n_col;
                                    for d4 = 1:obj.n_col;
                                        for d5 = 1:obj.n_col;
                                            for d6 = 1:obj.n_col;
                                                for d7 = 1:obj.n_col;
                                                    indices(ind)= c*1e9+cp*1e8+tp*1e7+d1*1e6+d2*1e5+d3*1e4+d4*1e3+d5*1e2+d6*1e1+d7*1e0;
                                                    ind=ind+1;
                                                    
                                                end;
                                            end  ;          
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            
            %%
            a = randperm(numel(indices));
            obj.generalization_trials = indices(a(1:obj.n_genTrials));
            obj.train_trials = indices(a(obj.n_genTrials+1:end));
            obj.keepTrialsforGeneralization = true;
        end
    end
    
    
    
    
    
    
end

