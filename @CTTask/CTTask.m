classdef CTTask < handle & Task
    % Curve Tracing task.
    
    
    properties(SetAccess=protected, GetAccess=public)
        grid_size = 6;
        
        
        trialTarget = 0;
        trialDistr = 0;
        target_display = zeros(1,4*4*3)
        pos_on_curve = 0;
        
        trialSetExternal = false;
        fp_on = 0;      % used for plotting
        fix_action = 1;
        
    end
    
    properties
        distr_curve_on = 0;
        curve_length = 2;
        active_tracing = 1;
        actual_tracing = 1;
        turnoff_fp = 1;
    end
    
    methods
        
        show_DisplayCT(obj,h3,a3,n,new_input,reward,trialno);
        
        % Constructor:
        function obj = CTTask()
            obj.stateReset();
            obj.curve_length = 2;
            obj.distr_curve_on = 0;
            obj.n_actions = 37;
            obj.active_tracing = 1;
            obj.actual_tracing = 1;
        end
        
        
        function stateReset(obj)
            stateReset@Task(obj); % Call superclass stateReset method
            obj.pos_on_curve = 0;
        end
        
        function setDefaultNetworkInput(obj)
            obj.nwInput = zeros(1,obj.grid_size^2*3+1);
            % Fix_P, Fix_A, Left-target, Right-target
        end
        
        function [nwInput, reward, trialend] = doStep(obj, networkAction)
            
            % Quick sanity check on input
            try
                obj.checkInput(networkAction);
            catch
                keyboard
            end
            
            obj.trialEnd = false;
            
            switch (obj.STATE)
                case obj.INTERTRIAL
                    %disp('INTERTRIAL')
                    if (obj.counter == obj.intertrial_dur)
                        obj.pickTrialType();
                        obj.nwInput(1) = 1; % Activate Fixation point
                        
                        obj.STATE = obj.WAITFIXSTATE;
                        obj.resetCounter(); % reset counter
                    else
                        obj.incrCounter()
                    end
                    
                case obj.WAITFIXSTATE % Wait with trial until fixation
                    %disp('WAITFIX')
                    if (obj.counter <= obj.waitfix_timeout)
                        if  networkAction(obj.fix_action)==1 %(all(networkAction == [1,0,0])) % Fixation
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
                    
                    if (networkAction(obj.fix_action) ~= 1) % Trial failed
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
                                if obj.active_tracing
                                    obj.actual_tracing = 1;
                                    obj.nwInput(1) = 0;
                                else
                                    if rand<1
                                        obj.actual_tracing = 0;
                                        obj.nwInput(1) = 1;
                                    else
                                        obj.actual_tracing = 1;
                                        obj.nwInput(1) = 0;
                                        disp('active tracing')
                                    end
                                end
                                obj.STATE = obj.GOSTATE;
                            end
                            % Show targets:
                            obj.nwInput(2:end) = obj.target_display;
                            
                        else
                            obj.incrCounter();
                        end
                    end
                    
                case obj.MEMSTATE
                    disp('MEMSTATE')
                    
                    % % % %                % Make sure no cues are shown:
                    % % % %                obj.nwInput(3:4) = [0 0];
                    % % % %                % Check if still fixating:
                    % % % %                if (networkAction(1) ~= 1)
                    % % % %                  disp('Failure')
                    % % % %                  obj.stateReset();
                    % % % %                else
                    % % % %                 if( obj.counter == obj.mem_dur)
                    % % % %                     obj.resetCounter();
                    % % % %
                    % % % %                     obj.nwInput = [0 0 0 0];
                    % % % %
                    % % % %                     obj.STATE = obj.GOSTATE;
                    % % % %                 else
                    % % % %                     obj.incrCounter();
                    % % % %                 end
                    % % % %                end
                    
                case obj.GOSTATE
                    %disp('GO')
                    % Wait until fixation is broken
                    if (obj.counter <= obj.max_dur) % Trial expired?
                        if obj.actual_tracing
                            if (networkAction(1) ~= 1)  % Broke Fixation
                                Pos_on_display = find(networkAction)-1;
                                new_pos_on_curve = find(obj.trialTarget==Pos_on_display);
                                if ~isempty(new_pos_on_curve) && (new_pos_on_curve>=obj.pos_on_curve)   %(all(networkAction(2:3) == obj.trialTarget) ) % Correct:
                                    if new_pos_on_curve==obj.curve_length
                                        disp('Final reward!')
                                        obj.correct_trials = obj.correct_trials + 1;
                                        
                                        obj.cur_reward = obj.cur_reward + obj.fin_reward*2;
                                        obj.stateReset();
                                    elseif new_pos_on_curve>=obj.pos_on_curve
                                        disp('interm reward!')
                                        obj.pos_on_curve = new_pos_on_curve;
                                        
                                        obj.cur_reward = 0;%obj.cur_reward + obj.fix_reward*(1+new_pos_on_curve);
                                        obj.incrCounter();
%                                         keyboard;
                                    else
                                        disp('Failure')
                                        obj.stateReset();
                                    end
                                else
                                    disp('Failure')
                                    obj.stateReset();
                                end
                                
                                
                            else
                                %
                                obj.incrCounter();
                            end
                        else % only final saccade
                            if (networkAction(1) ~= 1)  % Broke Fixation
                                
                                if (find(networkAction)-1)== obj.trialTarget(end) && obj.counter>=floor(obj.curve_length/2);%obj.curve_length-1
                                    disp('Final reward!')
                                    obj.correct_trials = obj.correct_trials + 1;
                                    
                                    obj.cur_reward = obj.cur_reward + obj.fin_reward;
                                    obj.stateReset();
%                                 elseif obj.counter<obj.curve_length/2;
%                                     disp('Early Resp')
%                                     obj.stateReset();
                                else 
                                    disp('Failure')
                                    obj.stateReset();
                                end
                            else
                                disp('Holding Fix')
%                                 obj.cur_reward = obj.cur_reward + obj.fix_reward/2;
                                obj.incrCounter();
                                if obj.counter==floor(obj.curve_length/2);%obj.curve_length-1
                                    disp(' Fix Reward 2')
                                    obj.cur_reward = obj.cur_reward + obj.fix_reward;
                                    %                                 keyboard;
                                    if obj.turnoff_fp%                                    
                                        obj.nwInput(1) = 0;
                                    end
                                    
                                end
                                if obj.counter>=obj.curve_length
                                    disp('LengthOut')
                                    obj.stateReset();
                                end
                            end
                        end
                    else
                        disp('TimeOut')
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
        
        
        function setTrialType(obj, target_curve, distr_curve)
            % Externally set the trial type
            % Note that trial type does not change automatically anymore
            
            targ_display = zeros(1,obj.grid_size^2*3);
            for i = 1:numel(target_curve)
                if i==1
                    targ_display(target_curve(1)) = 1;
                elseif i== numel(target_curve)
                    targ_display(target_curve(i)+2*obj.grid_size^2) = 1;
                else
                    targ_display(target_curve(i)+obj.grid_size^2) = 1;
                end
                
                
            end
            if ~isempty(distr_curve)
                for i = 1:numel(distr_curve)
                    if i== numel(distr_curve)
                        targ_display(distr_curve(i)+2*obj.grid_size^2) = 1;
                    else
                        targ_display(distr_curve(i)+obj.grid_size^2) = 1;
                    end
                    
                end
            end
            obj.trialTarget = target_curve;
            obj.trialDistr = distr_curve;
            obj.target_display = targ_display;
            obj.trialSetExternal = true;
            
        end
        
        function pickTrialType(obj)
            % Generate trial
            distr_curve = [];
            % Generate a random trial if type has not been externally set.
            if (~obj.trialSetExternal)
                % generate target curve
                W = obj.create_conn_pattern();
                target_curve = randi(obj.grid_size^2);
                for l = 1:obj.curve_length-1
                    poss_continuation = find(W(target_curve(end),:));
                    for n = 1:numel(target_curve)
                        poss_continuation(poss_continuation==target_curve(n)) = [];
                        if n<numel(target_curve)
                            lat_pos = find(W(target_curve(n),:));
                            for p = 1:numel(lat_pos)
                                poss_continuation(poss_continuation==lat_pos(p)) = [];
                            end
                        end
                    end
                    target_curve = [target_curve poss_continuation(randi(numel(poss_continuation)))];
                end
                %generate distr_curve if is on
                if obj.distr_curve_on
                    forbidden_pos = target_curve;
                    for n = 1:numel(target_curve)
                        forbidden_pos = [forbidden_pos find(W(target_curve(n),:))];
                    end
                    forbidden_pos = unique(forbidden_pos);
                    
                    %               keyboard;
                    distr_curve_ok = 0;
                    while ~distr_curve_ok
                        free_pos = 1:obj.grid_size^2;
                        free_pos(forbidden_pos) = [];
                        distr_curve = free_pos(randi(numel(free_pos)));
                        free_pos(free_pos==distr_curve(end))=[];
                        for l = 1:obj.curve_length-1
                            poss_cont = intersect(free_pos,find(W(distr_curve(end),:)));
                            if isempty(poss_cont)
                                break
                            else
                                distr_curve = [distr_curve poss_cont(randi(numel(poss_cont)))];
                                free_pos(free_pos==distr_curve(end))=[];
                                
                                lat_pos = find(W(distr_curve(end-1),:));
                                for p = 1:numel(lat_pos)
                                    free_pos(free_pos==lat_pos(p)) = [];
                                end
                                
                                if numel(distr_curve)==obj.curve_length
                                    distr_curve_ok=1;
                                end
                            end
                        end
                    end
                    
                end
            end
            
            
            targ_display = zeros(1,obj.grid_size^2*3);
            for i = 1:numel(target_curve)
                if i==1
                    targ_display(target_curve(1)) = 1;
                elseif i== numel(target_curve)
                    targ_display(target_curve(i)+2*obj.grid_size^2) = 1;
                else
                    targ_display(target_curve(i)+obj.grid_size^2) = 1;
                end
                
                
            end
            if ~isempty(distr_curve)
                for i = 1:numel(distr_curve)
                    if i== numel(distr_curve)
                        targ_display(distr_curve(i)+2*obj.grid_size^2) = 1;
                    else
                        targ_display(distr_curve(i)+obj.grid_size^2) = 1;
                    end
                    
                end
            end
            
            obj.trialTarget = target_curve;
            obj.trialDistr = distr_curve;
            obj.target_display = targ_display;
            
            
            
        end
        
        function W = create_conn_pattern(obj)
            [X,Y] = meshgrid(1:obj.grid_size);
            X = reshape(X,[1,obj.grid_size^2]);
            Y = reshape(Y,[1,obj.grid_size^2]);
            W = sqrt(min(abs(ones(obj.grid_size^2,1) *X - X'*ones(1,obj.grid_size^2)),obj.grid_size-abs(ones(obj.grid_size^2,1) *X - X'*ones(1,obj.grid_size^2)) ).^2 +...
                min(abs(ones(obj.grid_size^2,1) *Y - Y'*ones(1,obj.grid_size^2)),obj.grid_size-abs(ones(obj.grid_size^2,1) *Y - Y'*ones(1,obj.grid_size^2)) ).^2);
            W = abs(W-1)<0.001;
        end
        
        
    end
    
    
    
    
end

