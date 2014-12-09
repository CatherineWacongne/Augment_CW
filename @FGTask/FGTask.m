classdef FGTask < handle & Task
    %%%%%%%%%%%%%%%%%%%%%%
    % Visual search task
    %%%%%%%%%%%%%%%%%%%%%%%%
    properties(SetAccess=protected, GetAccess=public)
        
        intTrialType = 0;    % (cue_col-1)*n_pos + cue_pos (= index of input =1 )
        prev_intTrialType = -1;
        fp_input_index = 201; % index of the input vector that represents the fixation point
        fix_action_index = 1;
        FGunits= 1:200;
        FGinput = zeros(1,200);
        
        trialTarget = 0;     % cue_col
        target_pos = 0;
        
        trialSetExternal = false;
        keepTrialsforGeneralization = false;
        
        
        fp_on = 0;      % used for plotting
        tar_on = 0;     % used for plotting
        left_on = 0;    % used for plotting
        old_fixpos=0;   % used for plotting: previously plotted fixation position
        old_reward=0;
    end
    properties % properties that can be changed from the command window or an external script
        
        size_net = 10;
        target_sizes = 3;
        edge_size = 2;
        
    end
    
    methods
        
        show_DisplayColor(obj,h3,a3,n,new_input,reward,trialno);
        
        % Constructor:
        function obj = FGTask()
            obj.stateReset();
            obj.prev_intTrialType = obj.intTrialType;
            obj.intTrialType = -1;
            obj.fp_input_index = 201; % index of the input vector that represents the fixation point
            obj.fix_action_index = 1;
            obj.n_actions = 101;
            obj.mem_dur = 0;
            obj.fix_dur = 2;
        end
        
        
        function stateReset(obj)
            stateReset@Task(obj); % Call superclass stateReset method
        end
        
        function setDefaultNetworkInput(obj)
            obj.nwInput = zeros(1, 2*obj.size_net^2+1);
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
                                obj.STATE = obj.GOSTATE;
                            end
                            % Show cue:
                            
                            obj.nwInput(obj.FGunits) = obj.FGinput;
                            
                        else
                            obj.incrCounter();
                        end
                    end
                    
                    
                case obj.GOSTATE
                    %disp('GO')
                    % Wait until fixation is broken
                    
                    if (obj.counter <= obj.max_dur) % Trial expired?
                        if (~all(networkAction == fixation))  % Broke Fixation
                            
                            if (any(networkAction(obj.trialTarget+1) == 1) ) % Correct:
                                disp('Reward!')
                                %                                  keyboard
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
                    
                case obj.MEMSTATE % errases all cues and switches the fix point off at the end of the delay
                    % disp('MEMSTATE')
                    
                    % Make sure no cues are shown:
                    
                    obj.nwInput(obj.fp_input_index) = 1;
                    
                    % Check if still fixating:
                    if (networkAction(obj.fix_action_index) ~= 1)
                        disp('Failure')
                        obj.stateReset();
                    else
                        if( obj.counter == obj.mem_dur)
                            obj.resetCounter();
                            
                            
                            
                            obj.STATE = obj.SEQSTATE;
                        else
                            obj.incrCounter();
                        end
                    end
                case obj.SEQSTATE
                    if (networkAction(obj.fix_action_index) ~= 1)
                        disp('Failure')
                        obj.stateReset();
                    else
                        if( obj.counter == obj.fix_dur)
                            obj.cur_reward = obj.cur_reward + obj.fix_reward; % second fixation reward
                            obj.resetCounter();
                            obj.nwInput(obj.fp_input_index) = 0;
                            obj.nwInput = zeros(1,obj.n_col*obj.n_pos+1);
                            obj.STATE = obj.GOSTATE;
                        else
                            obj.incrCounter();
                        end
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
        
        
        function setTrialType(obj, targ_size, target_pos, Fig_col)
            % Externally set the trial type
            %
            targ_x = target_pos(1);
            targ_y = target_pos(2);
            Fig_coord_x = targ_x: targ_x+targ_size-1;
            Fig_coord_y = targ_y: targ_y+targ_size-1;
            layer_1 = zeros(obj.size_net);
            layer_2 = zeros(obj.size_net);
            if Fig_col==1
                layer_1(Fig_coord_x, Fig_coord_y) = ones(targ_size);
                layer_2 = (layer_2+1)-layer_1;
            else
                layer_2(Fig_coord_x, Fig_coord_y) = ones(targ_size);
                layer_1 = (layer_1+1)-layer_2;
            end
            
            
            obj.FGinput = [reshape(layer_1,1,[]), reshape(layer_2,1,[])];
            obj.intTrialType = 1e3*Fig_col+1e2*targ_size+1e1*targ_x+targ_y;
            if Fig_col==1
                if targ_size<=2
                    obj.trialTarget = find(reshape(layer_1,1,[]));
                else
                    Targ_coord_x = targ_x+1: targ_x+targ_size-2;
                    Tag_coord_y = targ_y+1: targ_y+targ_size-2;
                    layer_t = zeros(obj.size_net);
                    layer_t(Targ_coord_x, Tag_coord_y) = ones(targ_size-2);
                    obj.trialTarget = find(reshape(layer_t,1,[]));
                end
            else
                if targ_size<=2
                    obj.trialTarget = find(reshape(layer_2,1,[]));
                else
                    Targ_coord_x = targ_x+1: targ_x+targ_size-2;
                    Tag_coord_y = targ_y+1: targ_y+targ_size-2;
                    layer_t = zeros(obj.size_net);
                    layer_t(Targ_coord_x, Tag_coord_y) = ones(targ_size-2);
                    obj.trialTarget = find(reshape(layer_t,1,[]));
                end
            end
            obj.trialSetExternal = true;
        end
        
        function pickTrialType(obj)
            % Generate trial
            
            % Generate a random trial if type has not been externally set.
            if (~obj.trialSetExternal )
                targ_size = obj.target_sizes(randi(numel(obj.target_sizes)));
                targ_possible_pos = ones(obj.size_net);
                targ_possible_pos([1:obj.edge_size end-obj.edge_size-targ_size+1:end],:)=0;
                targ_possible_pos(:,[1:obj.edge_size end-obj.edge_size-targ_size+1:end])=0;
                [poss_x,poss_y,~] = find(targ_possible_pos);
                a = randi(numel(poss_x));
                targ_x = poss_x(a);
                targ_y = poss_y(a);
                Fig_col = randi(2)-1;
                
                Fig_coord_x = targ_x: targ_x+targ_size-1;
                Fig_coord_y = targ_y: targ_y+targ_size-1;
                layer_1 = zeros(obj.size_net);
                layer_2 = zeros(obj.size_net);
                if Fig_col==1
                    layer_1(Fig_coord_x, Fig_coord_y) = ones(targ_size);
                    layer_2 = (layer_2+1)-layer_1;
                else
                    layer_2(Fig_coord_x, Fig_coord_y) = ones(targ_size);
                    layer_1 = (layer_1+1)-layer_2;
                end
                
                
                obj.FGinput = [reshape(layer_1,1,[]), reshape(layer_2,1,[])];
                obj.intTrialType = 1e3*Fig_col+1e2*targ_size+1e1*targ_x+targ_y;
                if Fig_col==1
                    if targ_size<=2
                        obj.trialTarget = find(reshape(layer_1,1,[]));
                    else
                        Targ_coord_x = targ_x+1: targ_x+targ_size-2;
                        Tag_coord_y = targ_y+1: targ_y+targ_size-2;
                        layer_t = zeros(obj.size_net);
                        layer_t(Targ_coord_x, Tag_coord_y) = ones(targ_size-2);
                        obj.trialTarget = find(reshape(layer_t,1,[]));
                    end
                else
                    if targ_size<=2
                        obj.trialTarget = find(reshape(layer_2,1,[]));
                    else
                        Targ_coord_x = targ_x+1: targ_x+targ_size-2;
                        Tag_coord_y = targ_y+1: targ_y+targ_size-2;
                        layer_t = zeros(obj.size_net);
                        layer_t(Targ_coord_x, Tag_coord_y) = ones(targ_size-2);
                        obj.trialTarget = find(reshape(layer_t,1,[]));
                    end
                end
                
            end
            
        end
        
        
        
        
        
    end
    
    
    
    
    
end

