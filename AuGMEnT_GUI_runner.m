function [] = experiment_runner()
%%

% for experiments, fix the random generator:
seed = 1;
rnd_stream = RandStream('mt19937ar','Seed', seed);
RandStream.setDefaultStream(rnd_stream);


% Create simpleTI GUI
ghandles = guihandles( AuGMEnT_GUI );

steptime = 0.1; % Pause time between execution steps
runmode = 0; % 0=step, 1=continuous

%% Here initial task and network are created;
% Create a Task object:
taskType = 'GGSATask';
taskTypeIdx = 1;
t = GGSATask();

new_input = t.nwInput;
reward = 0;
trialend = false;
cur_epoch = 0;

% Create a Network object:
n = SNetwork();
n.n_inputs = length(t.nwInput);
n.init_network();


% Statistics loggers:
log_size = 10000;
rewards = zeros(1,log_size);
exp_rewards = zeros(1,log_size);
max_rewards = zeros(1,log_size);

trace_mem = 50;
e_traces_m_xy = zeros(n.nx * n.ny_memory, trace_mem);
e_traces_m_yz = zeros(n.ny_memory * n.nz, trace_mem);
e_traces_n_xy = zeros((n.bias_input + n.nx) * n.ny_normal, trace_mem);
e_traces_n_yz = zeros((n.bias_hidden + n.ny_normal) * n.nz , trace_mem);

trial_idx = 1;

% Handles for task visualizer:
handles_tv = [];

% Handles for network visualizer:
handles_nv_input = [];
handles_nv_hidden = [];
handles_nv_output = [];
handles_nv_wxy = [];
handles_nv_wyz = [];

colormap_neurons = colormap('cool');
colormap_neurons_size = size(colormap_neurons,1);

% Handles for rewards visualizer:
reward_handles = [];

% Handles for trace visualizers:
traces_m_xy_handles = [];
traces_m_yz_handles = [];

traces_n_xy_handles = [];
traces_n_yz_handles = [];


% Initialize the GUI:
initializeGUI();

%%% NO PARAMETERS BELOW THIS LINE!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Run the simulation in continuous mode:
  function runSimulator()
     while(runmode==1)
        doStep();
        pause(steptime);
     end    
  end

  % Execute one step of network/task interaction:
  function doStep()
    
    [action] = n.doStep(new_input,reward, trialend);
    [new_input, reward, trialend] = t.doStep(action);

    rewards(mod(cur_epoch,log_size ) + 1) = reward;
    exp_rewards(mod(cur_epoch,log_size ) + 1) = n.previous_critic_val;
    

    % Store e-trace info:
    tmp_mxy = n.wxy_traces(n.bias_input + 1 : end, 1+n.ny_normal:end);
    tmp_myz = n.wyz_traces((n.bias_hidden + n.ny_normal + 1):end, :); 
    
    tmp_nxy = n.wxy_traces(:, 1:n.ny_normal);
    tmp_nyz = n.wyz_traces(1:n.ny_normal + n.bias_hidden, :);
   
    e_traces_m_xy(:,trial_idx) = tmp_mxy(:)';
    e_traces_m_yz(:,trial_idx) = tmp_myz(:)';
    
    e_traces_n_xy(:,trial_idx) = tmp_nxy(:)';
    e_traces_n_yz(:,trial_idx) = tmp_nyz(:)';
    
    trial_idx = trial_idx + 1;
    
    
    % Update GUI:
    updateTaskVisualizer();
    updateNetworkVisualizer();
    
    if( mod(cur_epoch,50) == 0 || runmode==0)
      updateRewardsVisualizer();
      updateHintonVisualizers();
      updateTraceVisualizers();
     end
    
     if (trialend)      
         
        % Performance gauge:
        updatePerformance();
        
        updateTraceVisualizers();
        e_traces_m_xy = zeros(n.nx * n.ny_memory, trace_mem);
        e_traces_m_yz = zeros(n.ny_memory * n.nz, trace_mem);
        e_traces_n_xy = zeros((n.bias_input + n.nx) * n.ny_normal, trace_mem);
        e_traces_n_yz = zeros((n.bias_hidden + n.ny_normal) * n.nz , trace_mem);
        
        trial_idx = 1;
     end
    
    cur_epoch = cur_epoch + 1;
  end



  function initializeGUI
    % This function is called first for setting up the GUI

    % Performance gauge:
    updatePerformance();
    set(ghandles.b_performance_reset,'callback', @performance_reset_CB);

    %% Init Network Architecture panel:
    set(ghandles.e_ny_normal,'String', num2str(n.ny_normal));
    set(ghandles.e_ny_memory,'String', num2str(n.ny_memory));
    % Callbacks:
    set(ghandles.b_apply, 'callback', @apply_CB);
    set(ghandles.pushbutton10, 'callback', @dummy_CB);

    %% Task control panel:
    set(ghandles.s_steptime, 'callback', @slider_steptime_CB);
    set(ghandles.t_delay_indicator, 'String', t.mem_dur); 
    set(ghandles.t_delay_indicator, 'callback', @t_delay_CB);
    
    set(ghandles.t_reward_indicator, 'String', t.fin_reward); 
    set(ghandles.t_reward_indicator, 'callback', @t_reward_CB);
    set(ghandles.t_fixreward_indicator, 'String', t.fix_reward); 
    set(ghandles.t_fixreward_indicator, 'callback', @t_fixreward_CB);
    
    
    % Callbacks:
    set(ghandles.b_go, 'callback', @go_CB);
    set(ghandles.b_pause, 'callback', @pause_CB);
    set(ghandles.b_step, 'callback', @step_CB);
    set(ghandles.p_taskselect,'callback', @p_taskselect_CB);
    task_idx = get(ghandles.p_taskselect, 'Value');
    task_items = get(ghandles.p_taskselect,'String');
    taskType= task_items{task_idx};
    taskTypeIdx = task_idx;

    %% Network meta-parameter panel:
    set(ghandles.e_beta, 'callback', @e_beta_CB);
    set(ghandles.e_beta, 'String', n.beta); 

    set(ghandles.e_gamma, 'callback', @e_gamma_CB);
    set(ghandles.e_gamma, 'String', n.gamma);

    set(ghandles.e_lambda, 'callback', @e_lambda_CB);
    set(ghandles.e_lambda, 'String', n.lambda);

    set(ghandles.e_lambda_mem, 'callback', @e_lambda_mem_CB);
    set(ghandles.e_lambda_mem, 'String', n.lambda_mem);
    set(ghandles.e_lambda_mem, 'String',n.lambda_mem);

    % Create and init visualizers:
    createTaskVisualizer();
    updateTaskVisualizer();

    createNetworkVisualizer();
    updateNetworkVisualizer();

    createRewardsVisualizer();

    updateHintonVisualizers();

    createTraceVisualizers();
  end


  function updatePerformance()
    % Shows the performance (% trials correct of total trials)
    set(ghandles.t_performance,'String',sprintf('%.2f %%',t.getPerformance()*100));
  end

  function performance_reset_CB(hObject, eventdata, handles)
    % Resets performance measure
    t.resetTrialStats()
    updatePerformance();
  end

  function t_reward_CB(hObject, eventdata, handles)
    % Sets final reward
    value = get(hObject,'String');
    value = str2double(value);
    t.fin_reward = value;
    set(hObject, 'String', value); 
  end

  function t_fixreward_CB(hObject, eventdata, handles)
    % Sets fixation reward

    value = get(hObject,'String');
    value = str2double(value);
    t.fix_reward = value;
    set(hObject, 'String', value); 
  end

  function p_taskselect_CB(hObject, eventdata, handles)
   % Get the index of currently selected Task:
   value = get(hObject,'Value');
   items = get(hObject,'String');

   check = false;
   %Construct a questdlg with three options
   choice = questdlg('Are you sure you want to change Task? This will reset all current results and network', ...
    'Warning', ...
    'OK','Cancel','OK');
    % Handle response
    switch choice      
        case 'OK'
            check = true;
        case 'Cancel'
            check = false;        
    end

    if (~check)
      % Do not apply change:
      set(hObject,'Value',taskTypeIdx);
    else % Apply change:
      taskType = items{value};
      taskTypeIdx = value;
      initRunner(items{value}, n.ny_normal, n.ny_memory);
    end
  end


  function e_beta_CB(hObject, eventdata, handles)
    value = get(hObject,'String');
    value = str2double(value);
    n.beta = value;
    set(hObject, 'String', value); 
  end

  function e_gamma_CB(hObject, eventdata, handles)
    value = get(hObject,'String');
    value = str2double(value);
    n.gamma = value;
    set(hObject, 'String', value); 
  end

  function e_lambda_CB(hObject, eventdata, handles)
    value = get(hObject,'String');
    value = str2double(value);
    n.lambda = value;
    set(hObject, 'String', value); 
  end

  function e_lambda_mem_CB(hObject, eventdata, handles)
    value = get(hObject,'String');
    value = str2double(value);
    n.lambda_mem = value;
    set(hObject, 'String', value); 
  end

  function slider_steptime_CB(hObject, eventdata, handles)
    slider_value = get(hObject,'Value');
    steptime = slider_value;
    set(ghandles.t_steptime_indicator, 'String', num2str(steptime)); 
  end

  function t_delay_CB(hObject, eventdata, handles)
   value = get(hObject,'String');
   value = str2num(value);
   set(ghandles.t_delay_indicator, 'String', value); 
   t.mem_dur_now = value;
  end

  function go_CB(hObject, eventdata, handles)
    runmode = 1; % Set mode to continous running
    runSimulator();
  end

  function step_CB(hObject, eventdata, handles)
    runmode = 0; % Set mode to stepping
    doStep();
  end


  function pause_CB(hObject, eventdata, handles)
    runmode = 0; % Set mode to stepping
  end

  function apply_CB(hObject, eventdata, handles)
    % Apply new network hidden layer configuration

    new_ny_normal = str2num(get(ghandles.e_ny_normal,'String'));
    new_ny_memory = str2num(get(ghandles.e_ny_memory,'String'));

    initRunner(taskType, new_ny_normal, new_ny_memory);
  end

 function dummy_CB(hObject, eventdata, handles)
   disp('haha')
 end


  function reapplyMetaParams()
    % Applies new meta parameters to the network

    value = get(ghandles.e_beta,'String');
    value = str2double(value);
    n.beta = value;

     value = get(ghandles.e_gamma,'String');
    value = str2double(value);
    n.gamma = value;

     value = get(ghandles.e_lambda,'String');
    value = str2double(value);
    n.lambda = value;

    value = get(ghandles.e_lambda_mem,'String');
    value = str2double(value);
    n.lambda_mem = value;

  end

  function initRunner(nw_taskType, nw_ny_normal, nw_ny_memory)
    % Clear old network and all settings + visualizers:
    clear n;
    clear t;

    switch nw_taskType
      case 'GGSA Task'
        t = GGSATask();
      case 'GGSA Task [pro-only]'
        t = GGSATask();
        t.only_pro = true;
      otherwise
        disp('Something went wrong. Unrecognized task type:')
        nw_taskType

    end
    
    % Set memory delay:
    value = get(ghandles.t_delay_indicator, 'String'); 
    value = str2num(value);
    t.mem_dur = value;    

    n = SNetwork();

    n.n_inputs = length(t.nwInput);
    n.ny_normal = nw_ny_normal;
    n.ny_memory = nw_ny_memory;

    n.init_network();

    reapplyMetaParams();

    new_input = t.nwInput();
    reward = 0;
    trialend = false;
    cur_epoch = 1;

    resetVisualizers();
  end

  function resetVisualizers()
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.reward_visualizer);
    cla;
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.network_visualizer);
    cla;
   
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.task_visualizer);
    cla;
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_mem_xy);
    cla;
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_mem_yz);
    cla;
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_n_xy);
    cla;
    
     
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_n_yz);
    cla;
    
    
    % Handles for network visualizer:
    handles_nv_input = [];
    handles_nv_hidden = [];
    handles_nv_output = [];
    handles_nv_wxy = [];
    handles_nv_wyz = [];
    
    % Handles task visualizer:
    tv_handles = [];

    % Handles for rewards visualizer:
    reward_handles = [];
    
    % Reward data
    rewards = zeros(1,log_size);
    exp_rewards = zeros(1,log_size);
    max_rewards = zeros(1,log_size);
    
    % Trace Visualizers:
    e_traces_m_xy = zeros(n.nx * n.ny_memory, trace_mem);
    e_traces_m_yz = zeros(n.ny_memory * n.nz, trace_mem);
    e_traces_n_xy = zeros((n.bias_input + n.nx) * n.ny_normal, trace_mem);
    e_traces_n_yz = zeros((n.bias_hidden + n.ny_normal) * n.nz , trace_mem);
    
    createTaskVisualizer();
    updateTaskVisualizer();

    createNetworkVisualizer();
    updateNetworkVisualizer();

    createRewardsVisualizer();

    updateHintonVisualizers();
    createTraceVisualizers();
  end

  function createTraceVisualizers()
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_mem_xy);
    
    % Add plots:
    traces_m_xy_handles = plot(1:trace_mem, e_traces_m_xy(:,:));
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_mem_yz);
    
    % Add plots:
    traces_m_yz_handles = plot(1:trace_mem, e_traces_m_yz(:,:));
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_n_xy);
    
    % Add plots:
    traces_n_xy_handles = plot(1:trace_mem, e_traces_n_xy(:,:));
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_n_yz);
    
    % Add plots:
    traces_n_yz_handles = plot(1:trace_mem, e_traces_n_yz(:,:));
     
  end
  
  function updateTraceVisualizers()
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_mem_xy);
  
    % Update plots:
    for i=1:size(traces_m_xy_handles,1)
      set(traces_m_xy_handles(i),'YData',e_traces_m_xy(i,:));   
    end
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_mem_yz);
    
    % Update plots:
    for i=1:size(traces_m_yz_handles,1)
      set(traces_m_yz_handles(i),'YData',e_traces_m_yz(i,:));   
    end
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_n_xy);
    
     % Update plots:
    for i=1:size(traces_n_xy_handles,1)
      set(traces_n_xy_handles(i),'YData',e_traces_n_xy(i,:));   
    end
     
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.trace_visualizer_n_yz);
    
     % Update plots:
    for i=1:size(traces_n_yz_handles,1)
      set(traces_n_yz_handles(i),'YData',e_traces_n_yz(i,:));   
    end
  end

  function createRewardsVisualizer()
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.reward_visualizer);
    axis([1 1000 0 3]); 
    
    % Add plots
   
      
    reward_handles = plot(1:log_size,rewards, 'b.',...
                          1:log_size,exp_rewards,'r.');
    
  end


  function updateRewardsVisualizer()
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.reward_visualizer);
    
    % update plots:
    set(reward_handles(1),'YData',rewards);   
    set(reward_handles(2),'YData',exp_rewards);  
  end

  function updateHintonVisualizers()
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.weight_xy_vis);
    cla;
    set(gca, 'YTick', []);
    set(gca, 'XTick', []);
    set(gca, 'Box', 'on');
    
    hinton(n.weights_xy);
    
    set(0,'CurrentFigure',ghandles.figure1)
    set(ghandles.figure1,'CurrentAxes',ghandles.weight_yz_vis);
    cla;
    set(gca, 'YTick', []);
    set(gca, 'XTick', []);
    set(gca, 'Box', 'on');
    
    hinton(n.weights_yz);
  end

  function createTaskVisualizer()
      % Task visualizer
      set(0,'CurrentFigure',ghandles.figure1)
      set(ghandles.figure1,'CurrentAxes',ghandles.task_visualizer);
      set(gca, 'YTick', []);
      set(gca, 'XTick', []);
      set(gca, 'Box', 'on');
      set(gca,'NextPlot','add')
      
      % Calls task-specific visualizer
      t.createTaskVisualizer(gcf, gca);

      % Network actions:
      handles_tv = zeros(1,3);
      handles_tv(1) = rectangle('Position',[5-(1.25/2),5-(1.25/2),1.25,1.25],'LineWidth',2);
      handles_tv(2) = rectangle('Position',[2-.125,4.5-.125,1.25,1.25],'LineWidth',2);
      handles_tv(3) = rectangle('Position',[7-.125,4.5-.125,1.25,1.25],'LineWidth',2);

      set(ghandles.task_visualizer,'XLim',[0,10],'YLim',[0,10]);
  end


  function updateTaskVisualizer()

      set(0,'CurrentFigure',ghandles.figure1)
      set(ghandles.figure1,'CurrentAxes',ghandles.task_visualizer);

      % Calls task-specific visualizer
      t.updateTaskVisualizer(gcf, gca);
      
      % Network action:
      for i=1:3
        if (n.prev_action == i)
           set(handles_tv(i),'Visible', 'on');
        else
           set(handles_tv(i),'Visible', 'off');
        end
      end
  end



    function createNetworkVisualizer()
        set(0,'CurrentFigure',ghandles.figure1)
        set(ghandles.figure1,'CurrentAxes',ghandles.network_visualizer);
        set(ghandles.network_visualizer,'XLim',[0,10],'YLim',[0,10]);
        set(gca, 'YTick', []);
        set(gca, 'XTick', []);
        set(gca, 'Box', 'on');
        
        % Create network representation (neurons + weights) 
        handles_nv_input = zeros(1, (n.bias_input + n.nx));
        handles_nv_hidden = zeros(1, (n.bias_hidden + n.ny));
        handles_nv_output = zeros(1, n.nz);

        input_draw_centers = zeros(1, (n.bias_input + n.nx));
        hidden_draw_centers = zeros(1, (n.bias_hidden + n.ny));
        output_draw_centers =  zeros(1, n.nz);

        % Calculate neuron diameter:
        max_units = max([(n.bias_input + n.nx), (n.bias_hidden + n.ny), n.nz]);

        % Now, we want the largest layer of neurons to fit the image (width 10), with at
        % least 1/2 neuron diameter between neurons:
        max_layer_size = (3 * max_units + 1) / 2;
        n_diam = 10 / max_layer_size;
        n_hdiam = .5 * n_diam;

        % Draw input neurons:
        layer_width = ((3 * length(handles_nv_input) + 1) / 2) * n_diam;
        next_draw_pos = n_hdiam+  (10 - layer_width) / 2;
        for i=1:length(handles_nv_input)
            handles_nv_input(i) = rectangle('Position',[next_draw_pos,7,n_diam,n_diam], 'Curvature',[1,1]);
            if(i == 1 && (n.bias_input ==1))
              set(handles_nv_input(i), 'FaceColor',[0,0,0]);
            end
            input_draw_centers(i) = next_draw_pos + n_hdiam;
            next_draw_pos = next_draw_pos + n_diam + n_hdiam; 
        end

        % Draw hidden neurons:
        layer_width = ((3 * length(handles_nv_hidden) + 1) / 2) * n_diam;
        next_draw_pos = n_hdiam + (10 - layer_width) / 2;
        for i=1:length(handles_nv_hidden)
            handles_nv_hidden(i) = rectangle('Position',[next_draw_pos,4,n_diam,n_diam], 'Curvature',[1,1]);
         
            if(i == 1 && (n.bias_hidden ==1))
              set(handles_nv_hidden(i), 'FaceColor',[0,0,0]);
            end
            
            if(i > (n.ny_normal + n.bias_hidden))
              set(handles_nv_hidden(i), 'LineWidth',2);
            end
            
      
            hidden_draw_centers(i) = next_draw_pos + n_hdiam;
            next_draw_pos = next_draw_pos + n_diam + n_hdiam; 
        end

        % Draw output neurons:
        layer_width = ((3 * length(handles_nv_output) + 1) / 2) * n_diam;
        next_draw_pos = n_hdiam + (10 - layer_width) / 2;
        for i=1:length(handles_nv_output)
            handles_nv_output(i) = rectangle('Position',[next_draw_pos,1,n_diam,n_diam], 'Curvature',[1,1]);
            output_draw_centers(i) = next_draw_pos + n_hdiam;
            next_draw_pos = next_draw_pos + n_diam + n_hdiam; 
        end

        handles_nv_wxy = zeros(n.bias_input + n.nx, n.ny);
        % Now, we will draw the connections:
        for i=1:(n.bias_input + n.nx)
            for j=1:n.ny % Note: no connection from bias to bias! :)
                handles_nv_wxy(i,j) = line([input_draw_centers(i) hidden_draw_centers(n.bias_hidden+j)],[(7 + n_hdiam) (4 + n_hdiam)]);            
            end
        end

        handles_nv_wyz = zeros(n.bias_hidden + n.ny, n.nz);
        % Now, we will draw the connections:
        for i=1:(n.bias_hidden + n.ny)
            for j=1:n.nz % Note: no connection from bias to bias! :)
                handles_nv_wyz(i,j) = line([hidden_draw_centers(i) output_draw_centers(j)],[(4 + n_hdiam) (1 + n_hdiam)]);            
            end
        end
    
    end

    function updateNetworkVisualizer()
      set(0,'CurrentFigure',ghandles.figure1)
      set(ghandles.figure1,'CurrentAxes',ghandles.network_visualizer);
      
     
      % Update input-layer:
      for i=1:n.nx
        if (n.X(i) == 1)
          set(handles_nv_input(i + n.bias_input), 'FaceColor',[0,0,0]);
        else
          set(handles_nv_input(i + n.bias_input), 'FaceColor',[1,1,1]);
        end
      end
      
      % Update hidden-layer:
      for i=1:n.ny
        if (i <= n.ny_normal)
          set(handles_nv_hidden(i + n.bias_hidden), 'FaceColor', ...
            colormap_neurons(...
            min(round(1 + n.Y(i)* colormap_neurons_size),colormap_neurons_size),:));
        else
          set(handles_nv_hidden(i + n.bias_hidden), 'FaceColor', ...
            colormap_neurons(...
            min(round(1 +  ((n.Y(i) + 1)/2) * colormap_neurons_size),colormap_neurons_size),:));

        end
      end
      
      % Update output-layer:
      for i=1:n.nz
        set(handles_nv_output(i), 'FaceColor',(1 - n.prev_action_probs(i)*ones(1,n.nz)));
        
        if (i == n.prev_action)
          set(handles_nv_output(i ), 'LineWidth', 2);
        else
          set(handles_nv_output(i ), 'LineWidth', 1, 'LineStyle','-');
        end
      end
      
      % Now, update weights:
      % Calculate interesting (strong) weights 
      i_weights = abs(n.weights_xy);
      i_weights(i_weights > .25) = 1;
      
      for i=1:(size(i_weights,1) * size(i_weights,2))
        if (i_weights(i) == 1)
          set(handles_nv_wxy(i), 'Visible','on');
          if (n.weights_xy(i) > 0)
           set(handles_nv_wxy(i), 'Color',[0,1,0]);
          else
           set(handles_nv_wxy(i), 'Color',[1,0,0],'LineStyle','--');
          end
        else
          set(handles_nv_wxy(i), 'Visible','off');
        end
      end
      
      % Now, update weights:
      % Calculate interesting (strong) weights 
      i_weights = abs(n.weights_yz);
      i_weights(i_weights > .25) = 1;
      
      for i=1:(size(i_weights,1) * size(i_weights,2))
        if (i_weights(i) == 1)
          set(handles_nv_wyz(i), 'Visible','on');
          if (n.weights_yz(i) > 0)
           set(handles_nv_wyz(i), 'Color',[0,1,0]);
          else
           set(handles_nv_wyz(i), 'Color',[1,0,0],'LineStyle','--');
          end
        else
          set(handles_nv_wyz(i), 'Visible','off');
        end
      end
    end
end
