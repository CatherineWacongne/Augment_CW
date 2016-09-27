function update_traces( obj  )
%UPDATE_TRACES Calculates the updated Eligibility Traces



%% Decays the traces

obj.wxiyj_traces    = obj.wxiyj_traces      * obj.gamma * obj.lambda;  % Eligibility traces input synapses
obj.wxkyj_traces    = obj.wxkyj_traces      * obj.gamma * obj.lambda;
obj.wxonym_traces   = obj.wxonym_traces     * obj.gamma * obj.lambda;
obj.wxoffym_traces  = obj.wxoffym_traces    * obj.gamma * obj.lambda;
obj.wxkonym_traces  = obj.wxkonym_traces    * obj.gamma * obj.lambda;
obj.wxkoffym_traces = obj.wxkoffym_traces   * obj.gamma * obj.lambda;
obj.wymxk_traces    = obj.wymxk_traces      * obj.gamma * obj.lambda; % Eligibility traces Hidden to input synapses
obj.wyjz_traces     = obj.wyjz_traces       * obj.gamma * obj.lambda;  % Eligibility traces hidden to output synapses
obj.wymz_traces     = obj.wymz_traces       * obj.gamma * obj.lambda;


%% Now, update the traces:
% If set (default: off) limit eligibility traces.


% useful weights
w_ja = obj.weights_yjz(2:end,obj.prev_action);
w_ma = obj.weights_ymz(:,obj.prev_action);

% Compute all the activ derivatives :
dsig_j = obj.hd_transform_normal_deriv(obj.Yj);
dsig_k = obj.hd_transform_normal_deriv(obj.Xk);
dsig_m = obj.hd_transform_normal_deriv(obj.Ym);

DmemoUnits = (dsig_m .*  w_ma');
DhiddenUnits = (dsig_j .*  w_ja');
%% Do the actual update

% YZ traces

obj.wyjz_traces(:, obj.prev_action) =  [obj.bias_hidden obj.Yj]';
obj.wyjz_traces(obj.weights_yjz==0)=0;
obj.wymz_traces(:, obj.prev_action) =   obj.Ym';
obj.wymz_traces(obj.weights_ymz==0)=0;

% XYj traces

dPdwij = [1; obj.Xi'] * DhiddenUnits;
obj.wxiyj_traces = obj.wxiyj_traces + dPdwij;
obj.wxiyj_traces(obj.weights_xiyj==0)=0;

dPdwkj =  obj.Xk' * (dsig_j .*   w_ja');
obj.wxkyj_traces = obj.wxkyj_traces + dPdwkj;
obj.wxkyj_traces(obj.weights_xkyj==0)=0;

% XYm traces

dPdwdm1 = obj.sum_t_xon' * DmemoUnits;
obj.wxonym_traces = obj.wxonym_traces + dPdwdm1;
obj.wxonym_traces(obj.weights_xonym==0)=0;


dPdwdm1 = obj.sum_t_xoff' * DmemoUnits;
obj.wxoffym_traces = obj.wxoffym_traces + dPdwdm1;
obj.wxoffym_traces(obj.weights_xoffym==0)=0;

dPdwdm1 = obj.sum_t_xkon' * DmemoUnits;
obj.wxkonym_traces = obj.wxkonym_traces + dPdwdm1;
obj.wxkonym_traces(obj.weights_xkonym==0)=0;

dPdwdm1 = obj.sum_t_xkoff' * DmemoUnits;
obj.wxkoffym_traces = obj.wxkoffym_traces + dPdwdm1;
obj.wxkoffym_traces(obj.weights_xkoffym==0)=0;



%% YmXk trace

%d_impj/d_wmk

dP1 = [1 obj.prev_ym(1,:)]' * ((DhiddenUnits* obj.weights_xkyj').*dsig_k.*obj.Xi);


% d_impm/d_wmk
dinpkdwmk = ([1 obj.prev_ym(1,:)]'*(obj.Xi.*dsig_k)) - ([1 obj.prev_ym(2,:)]'*(obj.prev_xi.*obj.prev_dsigk)) ;
Aon = (ones(1,obj.ny_memory) *obj.weights_xkonym')*(obj.Xkon>0)';
Aoff = (ones(1,obj.ny_memory) *obj.weights_xkoffym')*(obj.Xkoff>0)';
obj.dinpm_dwmk_trace = obj.dinpm_dwmk_trace + Aon.*dinpkdwmk - Aoff.*dinpkdwmk;
A2 = dsig_m * w_ma;
dP2 = A2 .* obj.dinpm_dwmk_trace;

obj.wymxk_traces = obj.wymxk_traces + dP1 + dP2;
obj.wymxk_traces(obj.weights_ymxk==0)=0;


%% Average over connection classes
for conn_type = 1:13
    obj.wxiyj_traces(obj.wxiyj_class{conn_type})  = mean(obj.wxiyj_traces(obj.wxiyj_class{conn_type})); % Weights from input to hidden layer
    obj.wxkyj_traces(obj.wxy_class{conn_type}) 	= mean(obj.wxkyj_traces(obj.wxy_class{conn_type}));
    obj.wxonym_traces(obj.wxy_class{conn_type}) 	= mean(obj.wxonym_traces(obj.wxy_class{conn_type}));
    obj.wxoffym_traces(obj.wxy_class{conn_type}) 	= mean(obj.wxoffym_traces(obj.wxy_class{conn_type}));
    obj.wxkonym_traces(obj.wxy_class{conn_type}) 	= mean(obj.wxkonym_traces(obj.wxy_class{conn_type}));
    obj.wxkoffym_traces(obj.wxy_class{conn_type})	= mean(obj.wxkoffym_traces(obj.wxy_class{conn_type}));
    
    obj.wymxk_traces(obj.wymxk_class{conn_type})	= mean(obj.wymxk_traces(obj.wymxk_class{conn_type}));  % Weights from input to hidden layer
    
    obj.wyjz_traces(obj.wyjz_class{conn_type})	= mean(obj.wyjz_traces(obj.wyjz_class{conn_type})); % Weights from hidden to output layer
    obj.wymz_traces(obj.wymz_class{conn_type})	= mean(obj.wymz_traces(obj.wymz_class{conn_type})); % Weights from hidden to output layer
    
end
%
obj.prev_dsigk = dsig_k;




%%
obj.limit_traces = 0;
traces_limit = 0.5;
if (obj.limit_traces)
    
    wxiyj_idces     = find(abs(obj.wxiyj_traces) > traces_limit);
    wxkyj_idces     = find(abs(obj.wxkyj_traces) > traces_limit);
    wxonym_idces    = find(abs(obj.wxonym_traces) > traces_limit);
    wxoffym_idces   = find(abs(obj.wxoffym_traces) > traces_limit);
    wxkonym_idces   = find(abs(obj.wxkonym_traces) > traces_limit);
    wxkoffym_idces  = find(abs(obj.wxkoffym_traces) > traces_limit);
    
    wyjz_idces = find(abs(obj.wyjz_traces) > traces_limit);
    wymz_idces = find(abs(obj.wymz_traces) > traces_limit);
    
    wymxk_idces = find(abs(obj.wymxk_traces) > traces_limit);
    
    
    obj.wxiyj_traces( wxiyj_idces ) = sign(obj.wxiyj_traces( wxiyj_idces ) ) *traces_limit;
    obj.wxkyj_traces( wxkyj_idces ) = sign(obj.wxkyj_traces( wxkyj_idces )) *traces_limit;
    obj.wxonym_traces( wxonym_idces ) = sign(obj.wxonym_traces( wxonym_idces ) ) *traces_limit;
    obj.wxoffym_traces( wxoffym_idces ) = sign(obj.wxoffym_traces( wxoffym_idces )) *traces_limit;
    obj.wxkonym_traces( wxkonym_idces ) = sign(obj.wxkonym_traces( wxkonym_idces ) ) *traces_limit;
    obj.wxkoffym_traces( wxkoffym_idces ) = sign(obj.wxkoffym_traces( wxkoffym_idces)) *traces_limit;
    
    obj.wyjz_traces( wyjz_idces ) = sign(obj.wyjz_traces( wyjz_idces ) ) *traces_limit;
    obj.wymz_traces( wymz_idces ) = sign(obj.wymz_traces( wymz_idces ) ) *traces_limit;
    
    obj.wymxk_traces( wymxk_idces ) = sign(obj.wymxk_traces( wymxk_idces ) ) *traces_limit;
    
end
end





