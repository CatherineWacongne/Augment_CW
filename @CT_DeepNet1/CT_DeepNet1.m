classdef CT_DeepNet1 < handle
    %Network with FB on a grid for curve tracing - with weight sharing and
    %multiple feature layers in the hidden layer. No memory units
    
    properties
        %% Network meta-parameters:
        
        beta  = 0.01; % Learning rate synapses
        gamma  = 0.9; % Discounting of future rewards
        lambda = 0.3; % Decay of non-memory eligibility traces
        lambda_mem = 1.0; % Decay of eligibility traces memory neurons
        lambda_mem_arr = 0; % For population of different decays.
        n_hidden_features = 3;
        check_derivatives = 0;
        
        % Very experimental: population of memory-decays:
        %         population_decay = false;
        %         mem_decays = 1.0; % Dummy variable for population decay matrix
        %
        xy_weight_range = .1; % Range [-a,a] of initial weights
        yz_weight_range = .2; % Range [-a,a] of initial weights
        
        bias_input = 1; % 1 for a bias unit in input layer, else 0
        bias_hidden = 1; % 1 for a bias unit in hidden layer, else 0
        
        input_noise = false; % Determines whether noise should be added to input
        noise_sigma = 0.1; % Standard deviation of Gaussian input noise
        % (if input_noise is set to true)
        
        controller = 'max-boltzmann'; % The controller type to do action selection
        exploit_prob = .975; % The probability of a greedy action
        
        limit_delta = false; % Whether to limit the size of the TD-errors
        % Too large errors (esp. at the beginning of
        % learning) can make the weights explode.
        delta_limit = 2; % constrain delta to range [-delta_limit, delta_limit]
        use_class_connections = 1;
        
        % Determines whether Q-neuron activations are restricted to >= 0;
        % false: not restricted
        constrain_q_acts = false;
        
        % Determines the number of significant digits for Q-neuron activations
        % This helps discarding irrelevant distinctions (below modeling accuracy)
        % between activation values;
        prec_q_acts = 1e4;
        grid_size = 5;
        new_traces = cell(1,3);
        %% Architecture:
        
        n_inputs = 47;
        
        nx = 15; % Number of input layer neurons;
        ny_normal = 17; % Number of standard hidden layer neurons
        ny; % Total number of hidden neurons
        nz = 17; % Number of motor output neurons
        
        
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
        
        v1; % Weights from input to hidden layer1
        t1; % Weights from modul input to hidden layer 1
        u1; % Weights from hidden layer 1 to modul input
        u1mod;% Weights from modul hidden 1 to modul input
        v2; % Weights from hidden layer 1 to hidden layer 2
        t2; % Weights from modul hidden1 to hidden layer 2
        u2;% Weights from hidden layer 2 to modul hidden layer 1
        w; % Weights from hidden2 to output layer
        
        % connection classes
        v1_class;
        t1_class;
        u1_class;
        v2_class;
        t2_class;
        u2_class;
        w_class;
        
        % Egibility traces
        v1_traces;
        t1_traces;
        u1_traces;
        u1mod_traces;
        v2_traces;
        t2_traces;
        u2_traces;
        w_traces;
        
        limit_traces = false;
        
        % populations activations
        X; % Current input layer activations
        Xmod;
        
        Y1; % Current hidden layer activations
        Y1mod;
        
        Y2;
        Z;
        
        % store last value 
        prev_x;
        prev_xmod;
        
        prev_y1;
        prev_y1mod;
        prev_y2;
        
        old_qas;
        
        delta = 0;  % Current TD-error
        fdelta = 0; % Current scaled TD-error
        udelta = 0; % Current uncorrected TD-error
        previous_critic_val = 0; % Expectation critic for previous timestep
        
        %         mem_input; % Stores inputs calculated for memory hiddens
        % (without sustained inputs).
        %     sum_t_xd;
        
        % Determines the input to the memory neurons
        input_method = 'modulcells_on_reg';
        
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
        check_traces(obj,new_traces, qas, action);
        [new] = copy(obj);
        
        % end of declarations for externally defined methods
        
        
        function resetTraces(obj)
            % Reset all weight traces
            
            % Reset weight traces (all zero)
            for f1 = 1:obj.n_hidden_features
                obj.v1_traces{f1} = zeros(obj.nx + obj.bias_input, obj.ny);
                obj.t1_traces{f1} = zeros(obj.nx, obj.ny);
                obj.u1_traces{f1} = zeros(obj.ny, obj.nx);
                obj.u1mod_traces{f1} = zeros(obj.ny, obj.nx);
                for f2 = 1:obj.n_hidden_features
                    obj.v2_traces{f1}{f2} = zeros(obj.ny + obj.bias_input, obj.ny);
                    obj.t2_traces{f1}{f2} = zeros(obj.ny, obj.ny);
                    obj.u2_traces{f2}{f1} = zeros(obj.ny, obj.ny);
                end
                obj.w_traces{f1} = zeros(obj.ny + obj.bias_hidden, obj.nz);
                
                
                
            end
            
            obj.prev_input = zeros(1,obj.n_inputs);
            obj.previous_qa = 0;
            
        end
        
        function init_network(obj)
            
            % Initializer builds initial network
            
            if (strcmp(obj.input_method, 'modulcells_on_reg'))
                % Set dummy activations:
                obj.nx = obj.n_inputs;
                % Set total hidden units:
                obj.ny = obj.ny_normal;%(obj.ny_normal+ obj.ny_memory)*2;
            else
                % Set dummy activations:
                error('input method not recognized')
            end
            
            
            obj.X = zeros(1,obj.nx);
            obj.Xmod = zeros(1,obj.nx);
            for f = 1:obj.n_hidden_features
                obj.Y1{f} = zeros(1,obj.ny);
                obj.Y1mod{f} = zeros(1,obj.ny);
                obj.Y2{f} = zeros(1,obj.ny);
            end
            obj.Z = zeros(1,obj.nz);
            
            %             obj.old_X = -ones(1,obj.nx);
            %             obj.old_Y = -ones(1,obj.ny);
            %             obj.old_Z = -ones(1,obj.nz);
            obj.old_qas = -ones(1,obj.nz);
            
            %
            
            % Set the hidden unit transformations:
            obj.setInstantTransform(obj.instant_transform_fn, obj.instant_transform_tau);
            obj.setMemoryTransform(obj.mem_transform_fn, obj.mem_transform_tau);
            
            % Initialize eligibility traces, and set all to 0;
            obj.resetTraces();
            
            % Set initial weights:
            obj.init_weights();
            
%             if (obj.population_decay) % Default: off
%                 obj.init_population_decays();
%             else
                if (strcmp(obj.input_method, 'posnegcells'))
                    obj.lambda_mem_arr = obj.lambda_mem * ones(obj.n_inputs * 2, obj.ny_memory);
                    obj.mem_decays = ones(1,obj.ny_memory) * obj.lambda_mem;
                elseif (strcmp(obj.input_method, 'old'))||(strcmp(obj.input_method, 'modulcells_on_memo'))
                    obj.lambda_mem_arr = obj.lambda_mem * ones(obj.n_inputs * 1, obj.ny_memory);
                    obj.mem_decays = ones(1,obj.ny_memory) * obj.lambda_mem;
                end
%             end
            
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
        %         function init_population_decays(obj)
        %             % Generate pareto-distributed random decays (normalized between 0-1)
        %             obj.mem_decays =  gprnd(0,1,0,[1,obj.ny_memory]);
        %             obj.mem_decays = obj.mem_decays / max(obj.mem_decays);
        %             obj.mem_decays = obj.mem_decays - 10^-3;
        %             obj.lambda_mem_arr = repmat(obj.mem_decays, obj.n_inputs * 2, 1);
        %
        %         end
        
        function init_weights(obj) % Initialize weights
            
            % creates the nearest neighbours connection matrix W
            [X,Y] = meshgrid(1:obj.grid_size);
            X = reshape(X,[1,obj.grid_size^2]);
            Y = reshape(Y,[1,obj.grid_size^2]);
            W = sqrt(min(abs(ones(obj.grid_size^2,1) *X - X'*ones(1,obj.grid_size^2)),obj.grid_size-abs(ones(obj.grid_size^2,1) *X - X'*ones(1,obj.grid_size^2)) ).^2 +...
                min(abs(ones(obj.grid_size^2,1) *Y - Y'*ones(1,obj.grid_size^2)),obj.grid_size-abs(ones(obj.grid_size^2,1) *Y - Y'*ones(1,obj.grid_size^2)) ).^2);
            class_connection =0*W;
            
            class_connection(abs(W)<1.01) = 2;
            class_connection(abs(W)<0.01) = 1;
            W = abs(W)<1.001;
            
            
            % creates connection classes
            obj.v1_class = zeros(obj.nx+1,obj.ny);
            obj.t1_class = zeros(obj.nx,obj.ny);
            obj.u1_class = zeros(obj.ny,obj.nx);
            obj.v2_class = zeros(obj.ny+1,obj.ny);
            obj.t2_class = zeros(obj.ny,obj.ny);
            obj.u2_class = zeros(obj.ny,obj.ny);
            obj.w_class  = zeros(obj.ny+1,obj.nz);
            
            for col = 1:3
                
                obj.v1_class( 3+(col-1)*obj.grid_size^2:2+col*obj.grid_size^2,2:end) = W *2*(col-1)+class_connection;
                obj.t1_class( 2+(col-1)*obj.grid_size^2:1+col*obj.grid_size^2,2:end) = W *2*(col-1)+class_connection;
            end
            obj.v1(1,2:end) = 7;
            obj.u1_class = obj.t1_class';
            
            obj.v2_class(3:end, 2:end) = class_connection;
            obj.v2(1,2:end) = 7;
            obj.t2_class(2:end, 2:end) = class_connection;
            obj.u2_class = obj.t2_class';
            obj.w_class(3:end,2:end)  = diag(ones(1,obj.ny-1));
            obj.w_class(1,2:end) = 7;
            
            
            % set up the weights
            for f1 = 1:obj.n_hidden_features
                obj.v1{f1} = zeros(obj.nx + obj.bias_input, obj.ny);
                obj.t1{f1} = zeros(obj.nx, obj.ny);
                obj.u1{f1} = obj.t1{f1}';
                obj.u1mod{f1} = obj.t1{f1}';
                
                for conn_type = 1:12
                    obj.v1{f1}(obj.v1_class==conn_type) = rand * obj.xy_weight_range;%mean(obj.weights_xy{f}(obj.wxy_class==conn_type));
                    obj.t1{f1}(obj.t1_class==conn_type) = rand * obj.xy_weight_range;
                    obj.u1{f1}(obj.u1_class==conn_type) = rand * obj.xy_weight_range;
                    obj.u1mod{f1}(obj.u1_class==conn_type) = rand * obj.xy_weight_range;
                end
                
                obj.v1{f1}(2,1) = rand * obj.xy_weight_range;
                obj.v1{f1}(1,1) = rand * obj.xy_weight_range;
                obj.t1{f1}(1,1) = rand * obj.xy_weight_range;
                obj.u1{f1}(1,1) = rand * obj.xy_weight_range;
                obj.u1mod{f1}(1,1) = rand * obj.xy_weight_range;
                
                
                for f2 = 1:obj.n_hidden_features
                    obj.v2{f1}{f2} = zeros(obj.ny + obj.bias_input, obj.nz);
                    obj.t2{f1}{f2} = zeros(obj.ny, obj.nz);
                    obj.u2{f2}{f1} = zeros(obj.nz, obj.ny);
                    for conn_type = 1:12
                        obj.v2{f1}{f2}(obj.v2_class==conn_type) = rand * obj.yz_weight_range;
                        obj.t2{f1}{f2}(obj.t2_class==conn_type) = rand * obj.yz_weight_range;
                        obj.u2{f1}{f2}(obj.u2_class==conn_type) = rand * obj.yz_weight_range;
                    end
                    obj.v2{f1}{f2}(2,1) = rand * obj.yz_weight_range;
                    obj.v2{f1}{f2}(1,1) = rand * obj.yz_weight_range;
                    obj.t2{f1}{f2}(1,1) = rand * obj.yz_weight_range;
                    obj.u2{f1}{f2}(1,1) = rand * obj.yz_weight_range;
                    
                end
                obj.w{f1} = zeros(obj.ny + obj.bias_hidden, obj.nz);
                for conn_type = 1:12
                    obj.w{f1}(obj.w_class==conn_type) = rand * obj.yz_weight_range;
                end
                obj.w{f1}(2,1) = rand * obj.xy_weight_range;
                obj.w{f1}(2,2:end) = rand * obj.xy_weight_range;
            end
        end
    end
end



