function d=MoveWords(d)

global language
if language==2 % French
    for i=FindInChildren(d,1,[],'_T_P1')
        tp0 = FindInChildren(d,i,[],'_T_P0');
        tp0 = tp0(1);
        tense = d.children{tp0}(1);
        
        if length(intersect(d.labels{tense},{'#present','#past','#future','#inf'}))>0  %%% this is one of the empty tenses:
            % the conjugated verb must move here, in order to respect the correct order of adverb and verb in French
            
            vp0 = FindInChildren(d,i,[],'_V_P0');
            vp0 = vp0(1);
            verb = d.children{vp0}(1);
            if ~strcmp(d.terminalword{verb}(1),'#') %%% check if the verb is not already empty, i.e. it hasn't already been moved
                
                %%% do the move operation
                d.terminalword{tense}=d.terminalword{verb};
                d.node{tense}=d.node{verb};  
                d.labels{tense}=union(d.labels{tense},d.labels{verb});
                
                d.terminalword{verb}='#movedverb';
            end
        end        
    end
end

if language==3 %Dutch
    %%%% move subject (Tree) from T_SPEC to C_SPEC
    csp = FindInChildren(d,1,[],'_C_SPEC'); % works because there is only one per sentence...
    tsp = FindInChildren(d,1,[],'_T_SPEC'); % works because there is only one per sentence...
 
    % copy (pointer) children of tsp onto csp 
    d.children{csp} = d.children{tsp};
    d.nchildren{csp} = d.nchildren{tsp};
    %d.terminalword{csp} = d.terminalword{tsp};
    d.labels{csp} = union(d.labels{csp},d.labels{tsp});
    % delete tsp leaving a #movesdnp trace
    d=DeleteNodeLeavingTrace(d, tsp, 1, '#movednp'); 
    
    %%% move VP0 to CP0
    cp0 = FindInChildren(d,1,[],'_C_P0'); % works because there is only one per sentence...
    cp0 = cp0(1);
    cpnode = d.children{cp0}(1);
    tp0 = FindInChildren(d,1,[],'_T_P0'); % works because there is only one per sentence...
    tp0 = tp0(1);
    tense = d.children{tp0}(1);
    if length(intersect(d.labels{tense},{'#present','#past','#inf'}))>0  %%% this is one of the empty tenses:
        %%% the rule in Dutch is to move the VP0 to CP0
        % the conjugated verb must move here, in order to respect the correct order of adverb and verb in French
        vp0 = FindInChildren(d,1,[],'_V_P0'); % works because there is only one per sentence...
        vp0 = vp0(1);
        verb = d.children{vp0}(1);
        if ~strcmp(d.terminalword{verb}(1),'#') %%% check if the verb is not already empty, i.e. it hasn't already been moved            
            %%% do the move operation
            d.terminalword{cpnode}=d.terminalword{verb};
            d.node{cpnode}=d.node{verb};
            d.labels{cpnode}=union(d.labels{cpnode},d.labels{verb});
            
            d.terminalword{verb}='#movedverb';
        end
    else  %% the tense node is already occupied; the rule in dutch is then to only move the TP0 to CP0 position
        %%% do the move operation
        d.terminalword{cpnode}=d.terminalword{tense};
        d.node{cpnode}=d.node{tense};
        d.labels{cpnode}=union(d.labels{tense},d.labels{cpnode});
        
        d.terminalword{tense}='#movedaux';
    end
    
    %%%% if there is an object NP inside the _VT_COMP, move it by grafting it next to the TP2
    vtc = FindInChildren(d,1,[],'_VT_COMP'); % works because there is only one per sentence...
    if length(vtc)>0
        vtc = vtc(1);
        np2 = d.children{vtc}(1);
        parents = FindParents(d,vtc,[]);
        for k=1:length(parents)
            if strfind(d.node{parents(k)},'_T_P2')  %%% find the closest parent tense phrase
                tp2 = parents(k);
                break;
            end
        end
        d=GraftNode(d,tp2,2,np2);  %(d,i,childnumber,graftednode)
        d=DeleteNodeLeavingTrace(d,vtc, 1, '#movednp');
    end
end