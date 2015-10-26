classdef RainerTask < handle & Task
    %  Match to sample task with distractors:
    %     1/ object cue
    %     2/ sample display: 3 different obj appear at the 3 positions, one is
    %     the cued object -> give the position of the cued object
    %
    %     3/target display: the 3 same objects, if the cued obj is at the same
    %     position go to the match resp. Otherwise go to non match resp
    %
    properties(SetAccess=protected, GetAccess=public)
        
        intTrialType = 0;    % (cue_col-1)*n_pos + cue_pos (= index of input =1 )
        prev_intTrialType = -1;
        fp_input_index = 25; % index of the input vector that represents the fixation point
        fix_action_index = 4;
        
        
        n_col = 8;
        n_pos = 3;
        cue_pos = 1;         % 1
        cue_col = 0;         % 1 to 3
        trialTarget = 0;     % cue_col
        
        sample_input = [1 4 7];
        target_input = [1 4 7];
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
        n_genTrials = 100;
        Position_only = 1;
        reward_position = 1;
        
        
    end
    
    methods
        
        show_DisplayColor(obj,h3,a3,n,new_input,reward,trialno);
        
        % Constructor:
        function obj = RainerTask()
            obj.stateReset();
            obj.prev_intTrialType = obj.intTrialType;
            obj.intTrialType = -1;
            obj.n_col = 8;
            obj.n_pos = 3;
            obj.cue_pos = 0;
            obj.cue_col = 0;
%             obj.target_pos = 0;
            obj.fp_input_index = 25; % index of the input vector that represents the fixation point
            
            obj.fix_action_index = 4;
            obj.n_actions = 6;%position *3 + match/non match + FP.
            obj.mem_dur = 1;
            
        end
        
        
        function stateReset(obj)
            stateReset@Task(obj); % Call superclass stateReset method
        end
        
        function setDefaultNetworkInput(obj)
            obj.nwInput = zeros(1, obj.n_pos*obj.n_col+1);   % 
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
                        obj.pickTrialType(); %disp(['cue is col ' num2str(obj.cue_col), ' and at pos ' num2str(obj.cue_pos)]);
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
                                
                                obj.STATE = obj.SEQSTATE;
                            end
                            % Show cue:
                            obj.nwInput = 0*obj.nwInput;
                            
                            obj.nwInput(obj.fp_input_index) = 1;
                            obj.nwInput((obj.cue_col-1)*obj.n_pos+1:(obj.cue_col)*obj.n_pos) = 1;
                            
                            
                        else
                            obj.incrCounter();
                        end
                    end
                    
                case obj.MEMSTATE % errases all cues and switches the fix point off at the end of the delay
                    % disp('MEMSTATE')
                    
                    % Make sure no cues are shown:
                    obj.nwInput = 0*obj.nwInput;
                    obj.nwInput(obj.fp_input_index) = 1; % Activate Fixation point
                    % Check if still fixating:
                    if (~all(networkAction == fixation))
                        disp('Failure')
                        obj.stateReset();
                    else
                        if( obj.counter+1 == obj.mem_dur)
                            disp('cue  Fixation Reward')
                            obj.cur_reward = obj.cur_reward + obj.fix_reward;
                            obj.resetCounter();
                            
                            obj.STATE = obj.SEQSTATE;
                            obj.nwInput = 0*obj.nwInput;
                            obj.nwInput(obj.fp_input_index) = 1;
                            obj.nwInput(obj.sample_input) = 1;
                           
                        else
                            obj.incrCounter();
                        end
                    end
                case obj.SEQSTATE
                    if obj.reward_position
                        if (networkAction(obj.cue_pos) ~= 1)
                            disp('Failure')
                            obj.stateReset();
                        else
                            if( obj.counter == obj.fix_dur)
                                obj.cur_reward = obj.cur_reward + 3*obj.fix_reward; % second small reward for color task
                                disp('Position Reward !')
                                obj.resetCounter();
                                obj.nwInput = 0*obj.nwInput;
                                obj.nwInput(obj.fp_input_index) = 1;
                                obj.nwInput(obj.target_input) = 1;
                                
                                if obj.Position_only
                                    obj.stateReset();
                                else
                                    obj.STATE = obj.GOSTATE;
                                end
                            else
                                obj.incrCounter();
                            end
                        end
                    else
                        if (~all(networkAction == fixation)) % Trial failed
                            disp('Broke Fixation')
                            obj.stateReset();
                            
                            
                        elseif( obj.counter == obj.fix_dur)
                            %                             obj.cur_reward = obj.cur_reward + 3*obj.fix_reward; % second small reward for color task
                            disp('No more Position Reward !')
                            obj.resetCounter();
                            obj.nwInput = 0*obj.nwInput;
%                             obj.nwInput(obj.fp_input_index) = 1;
                            obj.nwInput(obj.target_input) = 1;
                            if obj.Position_only 
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
                        if obj.Position_only  ==1
                            obj.stateReset();
                            
                        elseif (~all(networkAction == fixation))  % Broke Fixation
                            
                            if (all(networkAction(obj.trialTarget) == 1) ) % Correct:
                                disp('Final Reward!')
                                obj.correct_trials = obj.correct_trials + 1;
                                
                                obj.cur_reward = obj.cur_reward + obj.fin_reward;
                            else
                                disp('Failure')
                            end
                            
                            obj.stateReset();
%                             if obj.var_mem_dur
%                                 obj.mem_dur = randi(3);
%                                 disp('VAR delay')
%                             end
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
        
        
        function setTrialType(obj, obj_col, sample_pos, target_pos)
            % Externally set the trial type
            % Note that trial type does not change automatically anymore
            obj.cue_pos = sample_pos(1);
            obj.cue_col = obj_col(1);
            obj.sample_input = (obj_col-1) * obj.n_pos +sample_pos;
            obj.target_input = (obj_col-1) * obj.n_pos +target_pos;
            
%             obj.intTrialType = (obj.cue_col-1)*obj.n_pos + obj.target_pos;
            if sample_pos(1) == target_pos(1)    
                obj.trialTarget = obj.n_pos+2;
            else
                obj.trialTarget = obj.n_pos+3;
            end
            obj.trialSetExternal = true;
        end
        
        function pickTrialType(obj)
            % Generate trial
            
            % Generate a random trial if type has not been externally set.
            if (~obj.trialSetExternal && ~obj.keepTrialsforGeneralization)
                obj_col = randperm(obj.n_col);
                obj_col = obj_col(1:3);
                sample_pos = randperm(3);
                target_pos = randperm(3);
                obj.cue_pos = sample_pos(1);
                obj.cue_col = obj_col(1);
                obj.sample_input = (obj_col-1) * obj.n_pos +sample_pos;
                obj.target_input = (obj_col-1) * obj.n_pos +target_pos;
                
                %                 obj.intTrialType = (obj.cue_col-1)*obj.n_pos + obj.target_pos;
                if sample_pos(1) == target_pos(1)
                    obj.trialTarget = obj.n_pos+2;
                else
                    obj.trialTarget = obj.n_pos+3;
                end
            elseif (~obj.trialSetExternal && obj.keepTrialsforGeneralization)
                trial_code = obj.train_trials(randi(numel(obj.train_trials)));
                obj.setTrialTypeGen(trial_code)
                obj.trialSetExternal = false;
                
%                 try
%                     obj.intTrialType = trial_code;
%                 catch
%                     obj.intTrialType =(obj.cue_col-1)*obj.n_pos + obj.target_pos;
%                 end
%                 obj.trialTarget = obj.target_pos+obj.fix_action_index;
                
            end
        end
        
        
        function setTrialTypeGen(obj,trial_code)
            StrCode = num2str(trial_code);
            obj_col = [str2num(StrCode(1)) str2num(StrCode(2)) str2num(StrCode(3))];
            sample_pos = [str2num(StrCode(4)) str2num(StrCode(5)) str2num(StrCode(6))];
            target_pos = [str2num(StrCode(7)) str2num(StrCode(8)) str2num(StrCode(9))];

            obj.cue_pos = sample_pos(1);
            obj.cue_col = obj_col(1);
            obj.sample_input = (obj_col-1) * obj.n_pos +sample_pos;
            obj.target_input = (obj_col-1) * obj.n_pos +target_pos;
            
            %                 obj.intTrialType = (obj.cue_col-1)*obj.n_pos + obj.target_pos;
            if sample_pos(1) == target_pos(1)
                obj.trialTarget = obj.n_pos+2;
            else
                obj.trialTarget = obj.n_pos+3;
            end
%             obj.intTrialType = (obj.cue_col-1)*obj.n_pos + obj.target_pos;
           

        end
        
        function setTrialsForGeneralisation(obj)
            %% generate the indices of all possible trials
            indices = zeros(1,obj.n_col*(obj.n_col-1)*(obj.n_col-2)/2*6*6);
            ind=1;
            poss_conf = [123 132 213 231 312 321];
            for cue = 1:obj.n_col
                poss_distr = 1:obj.n_col;
                poss_distr(cue) = [];
                for distr1 = 2:obj.n_col-1
                    for distr2 = 1:distr1-1
                        for conf_s = 1:6
                            for conf_t = 1:6
                                indices(ind)= poss_conf(conf_t)+1e3*poss_conf(conf_s)+1e6*poss_distr(distr2)+1e7*poss_distr(distr1)+1e8*cue;
                                ind=ind+1;
                            end
                        end
                    end
                end
            end                                  
                                              
            
            %%
            a = randperm(numel(indices));
            obj.generalization_trials = indices(a(1:obj.n_genTrials));
            obj.train_trials = indices(a(obj.n_genTrials+1:end));
            obj.keepTrialsforGeneralization = true;
        end
    end
    
    
    
    
    
    
end

