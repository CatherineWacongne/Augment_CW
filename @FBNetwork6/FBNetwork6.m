classdef FBNetwork6 < handle
  %SNETWORK Encapsulates structure, settings and state for an AuGMEnT network
  %Network with feedback from the memory units that learns also the feedback connections 
  
  properties
    %% Network meta-parameters:
    beta  = 0.15; % Learning rate synapses
    gamma  = 0.9; % Discounting of future rewards
    %lambda_xy = 0.0; % Decay of eligibility traces (input->hidden)
    %lambda_yz = 0.0; %  Decay of eligibility traces (hidden->output)
    lambda = 0.3; % Decay of non-memory eligibility traces
    lambda_mem = 1.0; % Decay of eligibility traces memory neurons
    lambda_mem_arr = 0; % For population of different decays.
    
    % Very experimental: population of memory-decays:
    population_decay = false;
    mem_decays = 1.0; % Dummy variable for population decay matrix

    xy_weight_range = .3; % Range [-a,a] of initial weights
    yz_weight_range = .1; % Range [-a,a] of initial weights
    
    bias_input = 1; % 1 for a bias unit in input layer, else 0
    bias_hidden = 1; % 1 for a bias unit in hidden layer, else 0
    
    % Not used in AuGMEnT but left for legacy purposes (used in \calc_fdelta)
    min_pch = 0.1; % Minimal choice probability as used in calc_fdelta
    minfact = 3;   % Multiplication factor for negative deltas (fdelta)
    
    input_noise = false; % Determines whether noise should be added to input
    noise_sigma = 0.1; % Standard deviation of Gaussian input noise
                       % (if input_noise is set to true)
                      
    controller = 'max-boltzmann'; % The controller type to do action selection
    exploit_prob = .975; % The probability of a greedy action
    
    limit_delta = false; % Whether to limit the size of the TD-errors
                        % Too large errors (esp. at the beginning of
                        % learning) can make the weights explode.
    delta_limit = 2; % constrain delta to range [-delta_limit, delta_limit]
    
    % Determines whether Q-neuron activations are restricted to >= 0;
    % false: not restricted
    constrain_q_acts = false;
    
    % Determines the number of significant digits for Q-neuron activations
    % This helps discarding irrelevant distinctions (below modeling accuracy) 
    % between activation values;
    prec_q_acts = 1e4;
                                          
    %% Architecture:
    n_inputs = 4;
    
    nx = 15; % Number of input layer neurons;
    
    ny_normal = 3; % Number of standard hidden layer neurons
    ny_memory = 4; % Number of memory hidden layer neurons
    ny; % Total number of hidden neurons
    
    nz = 3; % Number of motor output neurons
    
    
    % Hidden transformation functions:
    mem_transform_fn = 'shifted-sigmoid';
    mem_transform_tau = 1; % sets shift
    hd_transform_normal = '';
    hd_transform_normal_deriv = '';
    
    
    instant_transform_fn = 'shifted-sigmoid';
    instant_transform_tau = 2.5; % sets shift
    hd_transform_memory = '';
    hd_transform_memory_deriv = '';
    
    %% Network parameters (dynamic)
    
    weights_xy; % Weights from input to hidden layer
    weights_yz; % Weights from hidden to output layer
    weights_yx; % Weights from input to hidden layer

    weights_xy_handle; % Handles for drawing
    weights_yz_handle; % Handles for drawing
    
    wxy_traces;  % Eligibility traces input synapses
    wxy_traces_now; % Current change in eligibility due to network activations?
    wyx_traces;  % Eligibility traces input synapses
    
    wyz_traces;  % Eligibility traces hidden synapses
   
    
    limit_traces = false;
        
    X; % Current input layer activations
    Y; % Current hidden layer activations
    
    Y_ma_total;   % Total non-transformed activations of memory neurons
    Y_ma_current; % Current non-transformed activations of memory neurons
%     
    Z; % Current output layer activations
    
    old_X;      % used only for plotting
    old_Y;
    old_Z;
    
    old_qas;
   
    delta = 0;  % Current TD-error
    fdelta = 0; % Current scaled TD-error
    udelta = 0; % Current uncorrected TD-error
    previous_critic_val = 0; % Expectation critic for previous timestep
    
    mem_input; % Stores inputs calculated for memory hiddens 
               % (without sustained inputs).
    sum_t_xd;
    
    % Determines the input to the memory neurons
    input_method = 'modulcells_on_memo';
    
    noiseless_input; % Stores current noiseless input to network
    current_input; % Stores the current input to the network
    prev_input; % Stores previous input to network
    prev_action_probs; % Stores Action probabilities for previous state 
    prev_action_prob;  % Action probability for action selected in prev. state
    prev_action;       % Selected action in prev. state.
    prev_motor_output; % Selected motor output in prev. state.      
    previous_qa =NaN;
    qas; % Q(A,S) values predicted by output layer
    
    % flag to indicate whether architectural parameters were changed.
    % In this case, the init_network function needs to be called before
    % execution
    network_changed = true; 
    
    ep_begin = true;
    
    % Experimental:
    % Perform naive Q(\lambda) learning?
    naiveQ = false;
    
          
  end
    
  methods (Static)
      [winner] = calc_SoftWTA(probabilities);
  end
  
  methods % Public methods
     
    %% Declarations (methods defined in separate files):  
    
    [action] = doStep(obj, input, reward,reset_traces );
    calc_Hiddens(obj);
    calc_MemoryHiddens(obj);
    
    [ critic_estimate, maxcritic_estimate ] = calc_Critic(obj);
    [ fdelta ] = calc_fdelta(obj);
    calc_Input(obj);
    
    calc_Output(obj);
    show_NetworkActivity(obj,h2,a2,draw_connections);
    [winner] = calc_maxQ(obj);
    update_traces(obj);
    
    % end of declarations for externally defined methods
    
    
    function resetTraces(obj)
      % Reset all weight traces, and memory neurons.
      
      % Reset weight traces (all zero)
      obj.wxy_traces = zeros(obj.nx + obj.bias_input, obj.ny);
      obj.wxy_traces_now = zeros(obj.nx + obj.bias_input, obj.ny);
      obj.wyz_traces = zeros(obj.ny + obj.bias_hidden, obj.nz);
      obj.wyx_traces = zeros(obj.ny + obj.bias_input, obj.nx);
     
      
      % TECHNICALLY, this is not a trace...
      obj.Y_ma_total = zeros(1, obj.ny_memory);
      obj.sum_t_xd = zeros(1, obj.n_inputs);
      
      obj.prev_input = zeros(1,obj.n_inputs);
      obj.previous_qa = 0;
            
    end
    
    function init_network(obj) 
      
      % Initializer builds initial network

     
      
      if (strcmp(obj.input_method, 'modulcells_on_memo'))
        % Set dummy activations:
        obj.nx = obj.n_inputs * 3;
         % Set total hidden units:
        obj.ny = (obj.ny_normal+ obj.ny_memory);
      else
        % Set dummy activations:
        error('input method not recognized')
      end
      

      obj.X = zeros(1,obj.nx);
      obj.Y = zeros(1,obj.ny);
      obj.Z = zeros(1,obj.nz); 
      
      obj.old_X = -ones(1,obj.nx);
      obj.old_Y = -ones(1,obj.ny);
      obj.old_Z = -ones(1,obj.nz); 
      
      obj.old_qas = -ones(1,obj.nz); 

      obj.weights_xy_handle = -ones(obj.nx+1,obj.ny); % Handles for drawing
      obj.weights_yz_handle = -ones(obj.ny+1,obj.nz); % Handles for drawing
            
%       obj.Y_ma_total = zeros(1, obj.ny_memory);
%       obj.Y_ma_current = zeros(1, obj.ny_memory);
      
      % Set the hidden unit transformations:
      obj.setInstantTransform(obj.instant_transform_fn, obj.instant_transform_tau);
      obj.setMemoryTransform(obj.mem_transform_fn, obj.mem_transform_tau);
 
      % Initialize eligibility traces, and set all to 0;
      obj.resetTraces();
      
      % Set initial weights:
      obj.init_weights();
      
      if (obj.population_decay) % Default: off
        obj.init_population_decays();
      else
        if (strcmp(obj.input_method, 'posnegcells'))
          obj.lambda_mem_arr = obj.lambda_mem * ones(obj.n_inputs * 2, obj.ny_memory);
          obj.mem_decays = ones(1,obj.ny_memory) * obj.lambda_mem; 
        elseif (strcmp(obj.input_method, 'old'))||(strcmp(obj.input_method, 'modulcells_on_memo'))
          obj.lambda_mem_arr = obj.lambda_mem * ones(obj.n_inputs * 1, obj.ny_memory);
          obj.mem_decays = ones(1,obj.ny_memory) * obj.lambda_mem;
        end
      end
     
      % Set dummy info on previous action:
      obj.current_input = zeros(1,obj.n_inputs);
      obj.prev_input = zeros(1,obj.n_inputs);
      obj.prev_action_probs = ones(1,obj.nz) / obj.nz;
      obj.prev_action_prob = obj.prev_action_probs(1);
      obj.prev_action = 1;
      obj.prev_motor_output = obj.Z;   obj.prev_motor_output(randi(obj.nz))=1;
      
      % Mark network as ready for execution:
      obj.network_changed  = false;
      obj.limit_traces = true;
    end
    
    % Set the controller that converts q-values into action probabilities
    function setController(obj, type)
      switch lower(type)
        case 'max'
          obj.controller = 'max';
        case 'boltzmann'
          obj.controller = 'boltzmann';
        case  'max-boltzmann'
          obj.controller = 'max-boltzmann';
        otherwise
          warning('Unknown controller type passed, setting to Max')
          obj.controller = 'max';
      end
    end
    
    
    function setInstantTransform(obj,type, varargin)
      % Set transformations for normal hidden units.
      switch lower(type)
       case 'normal-sigmoid'
         obj.hd_transform_normal = @(in) 1 ./ (1  + exp(-in));
         obj.hd_transform_normal_deriv =  @(acts) acts .* (1 - acts);
       case 'tanh'
         obj.hd_transform_normal =  @(in) (2 ./ (1 + exp(-in) )) - 1;
         obj.hd_transform_normal_deriv = @(acts) .5 - .5 * (acts.^2);
         
       case 'rectified-linear'  
         obj.hd_transform_normal = @(in) 0.02*log(1+exp(50*in));
         obj.hd_transform_normal_deriv = @(acts) 1-exp(-50*acts);%1 ./ (1  + exp(-invsoftplus(50*acts)));%50
       case 'shifted-sigmoid'
         tau = 2;
         optargin = size(varargin,2);
         if (optargin == 1 )
           %varargin
           if ( isnumeric( varargin{1} ) )
             tau = varargin{1};  
      
           else
             ex=MException('SNetwork:setInstantTransform','Non-numeric argument passed as threshold parameter.');
             throw(ex)
           end
         end
         
         obj.hd_transform_normal = @(in) 1 ./ (1  + exp(tau - in));
         obj.hd_transform_normal_deriv =  @(acts) acts .* (1 - acts);
        
      end
      
    end
    
    function showNormalTransform(obj)
      % print transformations for memory hidden units to screen
      obj.hd_transform_normal
      obj.hd_transform_normal_deriv
    end
    
    function setMemoryTransform(obj,type, varargin)
      % Set transformations for memory hidden units.
      switch lower(type)
       case 'normal-sigmoid'
         obj.hd_transform_memory = @(in) 1 ./ (1  + exp(-in));
         obj.hd_transform_memory_deriv =  @(acts) acts .* (1 - acts);
       case 'tanh'
         obj.hd_transform_memory =  @(in) (2 ./ (1 + exp(-in) )) - 1;
         obj.hd_transform_memory_deriv = @(acts) .5 - .5 * (acts.^2);
       case 'shifted-sigmoid'
         tau = 2;
         optargin = size(varargin,2);
         if (optargin == 1 )
           %varargin
           if ( isnumeric( varargin{1} ) )
             tau = varargin{1};  
      
           else
             ex=MException('SNetwork:setMemoryTransform','Non-numeric argument passed as threshold parameter.');
             throw(ex)
           end
         end
         
         obj.hd_transform_memory = @(in) 1 ./ (1  + exp(tau - in));
         obj.hd_transform_memory_deriv =  @(acts) acts .* (1 - acts);
     end
    end
    
    function showMemoryTransform(obj)
      % print transformations for memory hidden units to screen
      obj.hd_transform_memory
      obj.hd_transform_memory_deriv
    end
    
    

  end % Methods
  
  methods (Access=protected) % Protected methods
   
    % This is *very* experimental
    function init_population_decays(obj)
      % Generate pareto-distributed random decays (normalized between 0-1)
      obj.mem_decays =  gprnd(0,1,0,[1,obj.ny_memory]);
      obj.mem_decays = obj.mem_decays / max(obj.mem_decays);
      obj.mem_decays = obj.mem_decays - 10^-3;
      obj.lambda_mem_arr = repmat(obj.mem_decays, obj.n_inputs * 2, 1);
      
    end
    
    function init_weights(obj) % Initialize weights
      
      % Set weights for Input->Hidden
      obj.weights_xy = obj.xy_weight_range* ...
        (rand(obj.nx + obj.bias_input, obj.ny))- 0.5*obj.xy_weight_range;
%       obj.weights_xy(obj.n_inputs*2+obj.bias_input+1:end,1:obj.ny_normal) = .5*obj.xy_weight_range* ...
%         (rand(obj.n_inputs, obj.ny_normal))- obj.xy_weight_range;

      % Set weights for Hidden->Output
      obj.weights_yz = obj.yz_weight_range*(rand(obj.ny + obj.bias_hidden, obj.nz))- 0.5*obj.yz_weight_range;%obj.yz_weight_range* ...
     
      
      % For visualization: put all weights in input->hidden that are not
      % used to 0;
      obj.weights_xy(:, obj.ny_normal+obj.ny_memory+1:end) = 0; 
      obj.weights_xy(1:obj.bias_input+obj.n_inputs, obj.ny_normal+1:obj.ny_normal+obj.ny_memory) = 0; 
      obj.weights_xy(obj.bias_input+obj.n_inputs+1:obj.bias_input+obj.n_inputs*2, 1:obj.ny_normal) = 0; 
      obj.weights_xy(obj.bias_input+obj.n_inputs*2+1:obj.bias_input+obj.n_inputs*3, obj.ny_normal+1:obj.ny_normal+obj.ny_memory) = 0; 
%       obj.weights_xy(1, 1:obj.ny_normal) = obj.weights_xy(1, 1:obj.ny_normal) - obj.n_inputs .* log(1+exp(0))*obj.yz_weight_range/6;
%       obj.weights_xy(2+obj.n_inputs:end, 1:obj.ny_normal) = 0;
      
      
      obj.weights_yz(obj.ny_normal+1 +obj.bias_hidden+obj.ny_memory:end, :) = 0; 
     
      obj.weights_yx = zeros(obj.ny + obj.bias_input, obj.nx);
      obj.weights_yx(obj.ny_normal+1 +obj.bias_hidden:end,obj.n_inputs*2+1:end) =  obj.weights_xy(obj.bias_input+obj.n_inputs*2+1:end, obj.ny_normal+1:end)'; 
      obj.weights_yx(1,obj.n_inputs*2+1:end) =  (rand(1, obj.n_inputs))- 0.5*obj.xy_weight_range;
%       obj.weights_xy(obj.bias_input+obj.n_inputs*2-1:obj.bias_input+obj.n_inputs*2,obj.ny_normal+1:obj.ny_normal+obj.ny_memory)=0;
    end    
  end
 
end
