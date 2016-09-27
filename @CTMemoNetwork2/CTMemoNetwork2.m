classdef CTMemoNetwork2 < handle
    %Network with FB on a grid for curve tracing
    
    properties
        %% Network meta-parameters:
        
        beta  = 0.01; % Learning rate synapses
        gamma  = 0.9; % Discounting of future rewards
        %lambda_xy = 0.0; % Decay of eligibility traces (input->hidden)
        %lambda_yz = 0.0; %  Decay of eligibility traces (hidden->output)
        lambda = 0.3; % Decay of non-memory eligibility traces
        lambda_mem = 1.0; % Decay of eligibility traces memory neurons
        
        
        
        xy_weight_range = .050; % Range [-a,a] of initial weights
        yz_weight_range = .10; % Range [-a,a] of initial weights
        
        bias_input = 1; % 1 for a bias unit in input layer, else 0
        bias_hidden = 1; % 1 for a bias unit in hidden layer, else 0
        
        
        controller = 'max-boltzmann'; % The controller type to do action selection
        exploit_prob = .9;%75; % The probability of a greedy action
        
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
        %% Architecture:
        
        n_inputs = 47;
        
        nx = 15; % Number of input layer neurons;
        
        ny_normal = 17; % Number of standard hidden layer neurons
        ny_memory = 17; % Number of memory hidden layer neurons
        ny; % Total number of hidden neurons
        
        nz = 17; % Number of motor output neurons
        %     nzs = 3; % Number of sensory output neurons
        
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
        
        weights_xiyj; % Weights from input to hidden layer
        weights_xkyj;
        weights_xonym;
        weights_xoffym;
        weights_xkonym;
        weights_xkoffym;
        weights_ymxk; % Weights from input to hidden layer
        weights_yjz; % Weights from hidden to output layer
        weights_ymz; % Weights from hidden to output layer
        
        %     weights_yzs;
        %     weights_zzs;
        wxiyj_class; % with constant input
        wxy_class;
        wyjxk_class; % with cst input
        wymxk_class;
        wyjz_class;
        wymz_class;
        
        wxiyj_traces;  % Eligibility traces input synapses
        wxkyj_traces;
        wxonym_traces;
        wxoffym_traces;
        wxkonym_traces;
        wxkoffym_traces;
        
        wymxk_traces; % Eligibility traces Hidden to input synapses
        
        dinpm_dwmk_trace;
        
        
        wyjz_traces;  % Eligibility traces hidden to output synapses
        wymz_traces;
        %     wyzs_traces;
        %     wzzs_traces;
        limit_traces = false;
        
        Xi; % Current input layer activations
        Xk;
        Xon;
        Xoff;
        Xkon;
        Xkoff;
        
        Yj; % Current hidden layer activations
        Ym;
        
        prev_ym;
        prev_xi;
        prev_dsigk;
        
        Y_ma_total;   % Total non-transformed activations of memory neurons
        Y_ma_current; % Current non-transformed activations of memory neurons
        %
        Z; % Current output layer activations
        %     ZS;
        
        
        delta = 0;  % Current TD-error
        fdelta = 0; % Current scaled TD-error
        udelta = 0; % Current uncorrected TD-error
        previous_critic_val = 0; % Expectation critic for previous timestep
        
        sum_t_xon;
        sum_t_xoff;
        sum_t_xkon;
        sum_t_xkoff;
        
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
        prev_input_mod; % keeps track of input to modulated units for differentiation
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
            obj.wxiyj_traces = zeros(obj.n_inputs + obj.bias_input, obj.ny_normal);  % Eligibility traces input synapses
            obj.wxkyj_traces= zeros(obj.n_inputs, obj.ny_normal);
            obj.wxonym_traces= zeros(obj.n_inputs , obj.ny_memory);
            obj.wxoffym_traces= zeros(obj.n_inputs , obj.ny_memory);
            obj.wxkonym_traces= zeros(obj.n_inputs , obj.ny_memory);
            obj.wxkoffym_traces= zeros(obj.n_inputs , obj.ny_memory);
            
            obj.wymxk_traces= zeros( obj.ny_memory + obj.bias_input, obj.n_inputs); % Eligibility traces Hidden to input synapses
            
            obj.dinpm_dwmk_trace= zeros(obj.ny_memory +1, obj.n_inputs);
            
            
            obj.wyjz_traces= zeros(obj.ny_normal + obj.bias_input, obj.nz);  % Eligibility traces hidden to output synapses
            obj.wymz_traces= zeros(obj.ny_memory, obj.nz);
            
            
            
            
            % TECHNICALLY, this is not a trace...
            obj.Y_ma_total = zeros(1, obj.ny_memory);
            obj.sum_t_xon = zeros(1, obj.n_inputs);
            obj.sum_t_xoff = zeros(1, obj.n_inputs);
            obj.sum_t_xkon = zeros(1, obj.n_inputs);
            obj.sum_t_xkoff = zeros(1, obj.n_inputs);
            obj.prev_ym = zeros(2, obj.ny_memory);
            obj.prev_xi = zeros(1, obj.n_inputs);
            obj.prev_dsigk = zeros(1, obj.n_inputs);
            
            obj.previous_qa = 0;
            
        end
        
        function init_network(obj)
            
            % Initializer builds initial network
            
            
            
            %       if (strcmp(obj.input_method, 'modulcells_on_reg'))
            %         % Set dummy activations:
            %         obj.nx = obj.n_inputs * 2;
            %          % Set total hidden units:
            %         obj.ny = obj.ny_normal*2;%(obj.ny_normal+ obj.ny_memory)*2;
            %       else
            %         % Set dummy activations:
            %         error('input method not recognized')
            %       end
            
            
            obj.Xi = zeros(1,obj.n_inputs);
            obj.Xk = zeros(1,obj.n_inputs);
            obj.Xon = zeros(1,obj.n_inputs);
            obj.Xoff = zeros(1,obj.n_inputs);
            obj.Xkon = zeros(1,obj.n_inputs);
            obj.Xkoff = zeros(1,obj.n_inputs);
            
            obj.Yj = zeros(1,obj.ny_normal);
            obj.Ym = zeros(1,obj.ny_memory);
            
            obj.Z = zeros(1,obj.nz);
            %       obj.ZS = zeros(1,obj.nzs);
            
            
            obj.Y_ma_total = zeros(1, obj.ny_memory);
            obj.Y_ma_current = zeros(1, obj.ny_memory);
            
            % Set the hidden unit transformations:
            obj.setInstantTransform(obj.instant_transform_fn, obj.instant_transform_tau);
            obj.setMemoryTransform(obj.mem_transform_fn, obj.mem_transform_tau);
            
            % Initialize eligibility traces, and set all to 0;
            obj.resetTraces();
            
            % Set initial weights:
            obj.init_weights();
            
            %       if (obj.population_decay) % Default: off
            %         obj.init_population_decays();
            %       else
            %         if (strcmp(obj.input_method, 'posnegcells'))
            %           obj.lambda_mem_arr = obj.lambda_mem * ones(obj.n_inputs * 2, obj.ny_memory);
            %           obj.mem_decays = ones(1,obj.ny_memory) * obj.lambda_mem;
            %         elseif (strcmp(obj.input_method, 'old'))||(strcmp(obj.input_method, 'modulcells_on_memo'))
            %           obj.lambda_mem_arr = obj.lambda_mem * ones(obj.n_inputs * 1, obj.ny_memory);
            %           obj.mem_decays = ones(1,obj.ny_memory) * obj.lambda_mem;
            %         end
            %       end
            %
            % Set dummy info on previous action:
            obj.current_input = zeros(1,obj.n_inputs);
            obj.prev_input = zeros(1,obj.n_inputs);
            obj.prev_action_probs = ones(1,obj.nz) / obj.nz;
            obj.prev_action_prob = obj.prev_action_probs(1);
            obj.prev_action = 1;
            
            obj.prev_input_mod = zeros(1,obj.n_inputs);
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
        
        
        function init_weights(obj) % Initialize weights
            [X,Y] = meshgrid(1:obj.grid_size);
            X = reshape(X,[1,obj.grid_size^2]);
            Y = reshape(Y,[1,obj.grid_size^2]);
            W = sqrt(min(abs(ones(obj.grid_size^2,1) *X - X'*ones(1,obj.grid_size^2)),obj.grid_size-abs(ones(obj.grid_size^2,1) *X - X'*ones(1,obj.grid_size^2)) ).^2 +...
                min(abs(ones(obj.grid_size^2,1) *Y - Y'*ones(1,obj.grid_size^2)),obj.grid_size-abs(ones(obj.grid_size^2,1) *Y - Y'*ones(1,obj.grid_size^2)) ).^2);
            class_connection =0*W;
            
            class_connection(abs(W)<1.01) = 2;
            class_connection(abs(W)<0.01) = 1;
            W = abs(W)<1.001;
            
            
            
            Conn_pattern = repmat(W,3,1);
            
            
            
            % Set weights for Input->Hidden
            
            obj.weights_xiyj    = obj.xy_weight_range * (rand(obj.n_inputs+1, obj.ny_normal)); % Weights from input to hidden layer
            obj.weights_xiyj(3:end,2:end)   =  obj.weights_xiyj(3:end,2:end).*Conn_pattern +.02*Conn_pattern;
            obj.weights_xiyj(2,2:end) = 0;
            obj.weights_xiyj(3:end,1) = 0;
            
            obj.weights_xkyj    = obj.xy_weight_range * (rand(obj.n_inputs, obj.ny_normal));
            obj.weights_xkyj(2:end,2:end)   =  obj.weights_xkyj(2:end,2:end).*Conn_pattern +.02*Conn_pattern;
            obj.weights_xkyj(1,2:end) = 0;
            obj.weights_xkyj(2:end,1) = 0;
            
            
            obj.weights_xonym   = (abs(obj.weights_xkyj)>0) .* obj.xy_weight_range.*(rand(obj.n_inputs, obj.ny_normal));
            obj.weights_xoffym	= (abs(obj.weights_xkyj)>0) .* obj.xy_weight_range.*(rand(obj.n_inputs, obj.ny_normal));
            obj.weights_xkonym	= (abs(obj.weights_xkyj)>0) .* obj.xy_weight_range.*(rand(obj.n_inputs, obj.ny_normal));
            obj.weights_xkoffym = (abs(obj.weights_xkyj)>0) .* obj.xy_weight_range.*(rand(obj.n_inputs, obj.ny_normal));
            
            obj.weights_ymxk    = obj.xy_weight_range *(rand(obj.ny_memory+1, obj.n_inputs));  % weights from hidden to input
            obj.weights_ymxk(3:end,2:end) = obj.weights_ymxk(3:end,2:end).*Conn_pattern' +.02*Conn_pattern';
            obj.weights_ymxk(3:end,1) = 0;
            obj.weights_ymxk(2,2:end) = 0;
            obj.weights_ymxk(1,1:end) = 0;
            
            
            obj.weights_yjz     = zeros(obj.ny_normal + obj.bias_hidden, obj.nz); % Weights from hidden to output layer
            obj.weights_yjz(3:end,2:end) = obj.yz_weight_range.*rand(obj.grid_size^2,obj.grid_size^2) .* W;%diag(ones(1,obj.nz));
            obj.weights_yjz(1,:) = obj.yz_weight_range.*rand(1,obj.nz);
            obj.weights_yjz(2,1) = obj.yz_weight_range.*rand;
            
            
            obj.weights_ymz     = zeros(obj.ny_memory, obj.nz); %
            obj.weights_ymz(2:end,2:end)   = obj.yz_weight_range.*rand(obj.grid_size^2,obj.grid_size^2) .* W;%diag(ones(1,obj.nz));
            obj.weights_ymz(1,1) = obj.yz_weight_range*rand;
            % creates classes of connections.
            
            wxiyj_class = 0*obj.weights_xiyj; % with constant input
            wxy_class   = 0*obj.weights_xkyj;
            wymxk_class = 0*obj.weights_ymxk; % with cst input
            wyjz_class  = 0*obj.weights_yjz;  % with cst input
            wymz_class  = 0*obj.weights_ymz;
            
            
            for col = 1:3
                wxiyj_class(3+(col-1)*obj.grid_size^2:2+col*obj.grid_size^2,2:end) = W *2*(col-1)+class_connection;
                wxy_class( 2+(col-1)*obj.grid_size^2:1+col*obj.grid_size^2,2:end)  = W *2*(col-1)+class_connection;
            end
            wxiyj_class(1,2:end) = 13;
            wymxk_class(2:end,:) = wxy_class';
            wymxk_class(1,2:end) = 13;
%             a = diag(ones(1,obj.grid_size^2));
            wyjz_class(3:end,2:end) = class_connection;
            wyjz_class(1,2:end) = 13;
            wymz_class(2:end,2:end) = class_connection;
            
            
            for conn_type = 1:13
                obj.wxiyj_class{conn_type} = find(wxiyj_class==conn_type);
                obj.wxy_class{conn_type} = find(wxy_class==conn_type);
                obj.wymxk_class{conn_type} = find(wymxk_class==conn_type);
                obj.wyjz_class{conn_type} = find(wyjz_class==conn_type);
                obj.wymz_class{conn_type} = find(wymz_class==conn_type);
            end
            
            
            % averages the weights over the connection classes
            if obj.use_class_connections
                for conn_type = 1:13
                    obj.weights_xiyj(obj.wxiyj_class{conn_type})  = rand*obj.xy_weight_range+0.04*mod(conn_type,2); % Weights from input to hidden layer
                    obj.weights_xkyj(obj.wxy_class{conn_type}) 	= rand*obj.xy_weight_range+0.04*mod(conn_type,2);
                    obj.weights_xonym(obj.wxy_class{conn_type}) 	= rand*obj.xy_weight_range+0.04*mod(conn_type,2);
                    obj.weights_xoffym(obj.wxy_class{conn_type}) 	= rand*obj.xy_weight_range+0.04*mod(conn_type,2);
                    obj.weights_xkonym(obj.wxy_class{conn_type}) 	= rand*obj.xy_weight_range+0.04*mod(conn_type,2);
                    obj.weights_xkoffym(obj.wxy_class{conn_type})	= rand*obj.xy_weight_range+0.04*mod(conn_type,2);
                    
                    obj.weights_ymxk(obj.wymxk_class{conn_type})	= 2*rand*obj.xy_weight_range;%+0.02*mod(conn_type,2);  % Weights from input to hidden layer
                    
                    obj.weights_yjz(obj.wyjz_class{conn_type})	= rand*obj.yz_weight_range+0.04*mod(conn_type,2); % Weights from hidden to output layer
                    obj.weights_ymz(obj.wymz_class{conn_type})	= rand*obj.yz_weight_range+0.04*mod(conn_type,2); % Weights from hidden to output layer
                    
                end
            end
            
            
%           keyboard
           
        end
    end
    
end

