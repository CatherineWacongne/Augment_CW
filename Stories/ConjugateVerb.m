function d=ConjugateVerb(d,istart)

LoadLexicon;

numberlabels = {'$SINGULAR','$PLURAL','$NEUTER'};  %%% and $UNSPECIFIED ??
tenselabels = {'#present','#past','#future','#inf','#perfect','#should','#might'};

for i=FindInChildren(d,istart,[],'_T_P1')
    aux=FindInChildren(d,i,[],'_T_P0');
    aux=d.children{aux(1)}(1); %%% this is the tense
    b=FindInChildren(d,i,[],'_V_P0');
    b=d.children{b(1)}(1); %%% this is the infinitive form of the verb
    infinitive = d.terminalword{b};
    
    currentnumber=intersect(numberlabels,d.labels{b});
    numberindex = strmatch(currentnumber,numberlabels);
    
    %%% find the tense, either in the labels, or in the node itself
    currenttense = union(d.labels{aux},d.node{aux});
    currenttense = intersect(tenselabels,currenttense); 
    
    a=intersect(currenttense,'#present');
    if ~isempty(a)
        %%% we need to conjugate the verb in the present tense, with
        %%% agreement with the subject
        
        %%% apply the label
        d=ApplyToChildren(d,i,'#present',{'_VT_COMP','_VM_COMP','_EMOTION_A_P2','_PHYSICAL_A_P2','_V_R_ADJUNCT','that','who'}); % that?, who? TODO
        
        %%% conjugate the verb
        
        %%% table-based conjugation
        iv = strmatch(infinitive,present{1});
        if ~isempty(iv)
            d.terminalword{b} = present{1+numberindex}{iv};
        else
            %%%% language specific rules
            if language == 2 % French
                if strcmp(infinitive(end-1:end),'er');
                    if numberindex == 1 % singular
                        d.terminalword{b}= [ infinitive(1:end-1) ];
                    else
                        d.terminalword{b}= [ infinitive(1:end-1) 'nt' ];
                    end
                end
            end
            if language == 3 % 
                 display(['dont know how to conjugate ' infinitive])
                 stop
                 %if strcmp(infinitive(end-1:end),'er');
                 %   if numberindex == 1 % singular
                 %       d.terminalword{b}= [ infinitive(1:end-1) ];
                 %   else
                 %       d.terminalword{b}= [ infinitive(1:end-1) 'nt' ];
                 %   end
                 %end
            end
               
            if language == 1 % English
                if numberindex==1 % singular
                    if strmatch(infinitive(end),{'h','s'});
                        d.terminalword{b}= [ infinitive, 'es' ];
                    else
                        if strcmp(infinitive(end),'y');
                            d.terminalword{b}= [ infinitive(1:end-1), 'ies' ];
                        else
                            d.terminalword{b}= [ infinitive, 's' ];
                        end
                    end
                end
                if strcmp(infinitive,'be')
                    if numberindex == 1
                        d.terminalword{b}= 'is' ;
                    else
                        d.terminalword{b}= 'are' ;
                    end
                    
                end
            end
        end
    end
    
    a=intersect(currenttense,'#past');
    if ~isempty(a)
        %%% we need to conjugate the verb in the past tense -- no agreement
        
        %%% apply the label
        d=ApplyToChildren(d,i,'#past',{'_VT_COMP','_VM_COMP','_EMOTION_A_P2','_PHYSICAL_A_P2','_V_R_ADJUNCT','that','who'});
        
        %%% table-based conjugation
        iv = strmatch(infinitive,past{1});
        if ~isempty(iv)
            d.terminalword{b} = past{1+numberindex}{iv};
        else
            %%%% language specific rules
            if language == 2 % French
                if strcmp(infinitive(end-1:end),'er');
                    if numberindex == 1 % singular
                        d.terminalword{b}= [ infinitive(1:end-2) 'ait'];
                    else
                        d.terminalword{b}= [ infinitive(1:end-2) 'aient' ];
                    end
                end
            end
            if language == 1 % English
                if strcmp(infinitive(end),'e');
                    d.terminalword{b}= [ infinitive, 'd' ];
                else
                    if strcmp(infinitive(end),'y');
                        d.terminalword{b}= [ infinitive(1:end-1), 'ied' ];
                    else
                        d.terminalword{b}= [ infinitive, 'ed' ];
                    end
                end
            end
            if language == 3 % Dutch
                if strcmp(infinitive(end),'e');
                    d.terminalword{b}= [ infinitive, 'd' ];
                else
                    if strcmp(infinitive(end),'y');
                        d.terminalword{b}= [ infinitive(1:end-1), 'ied' ];
                    else
                        d.terminalword{b}= [ infinitive, 'ed' ];
                    end
                end
            end
        end
    end
    
    a=intersect(currenttense,'#inf');
    if ~isempty(a)
        %%% infinitive -- no agreement
        %%% apply the label
        d=ApplyToChildren(d,i,'#inf',{'_VT_COMP','_VM_COMP','_EMOTION_A_P2','_PHYSICAL_A_P2','_V_R_ADJUNCT','that','who'});
    end
    
    a=intersect(currenttense,'#future');
    if ~isempty(a)
        %%% we need to conjugate the verb in the future -- no agreement
        %%% apply the label
        d=ApplyToChildren(d,i,'#future',{'_VT_COMP','_VM_COMP','_EMOTION_A_P2','_PHYSICAL_A_P2','_V_R_ADJUNCT','that','who'});
        
        %%% table-based conjugation
        iv = strmatch(infinitive,future{1});
        if ~isempty(iv)
            d.terminalword{b} = future{1+numberindex}{iv};
        else
            %%%% language specific rules
            if language == 2 % French
                if strcmp(infinitive(end-1:end),'er');
                    if numberindex == 1 % singular
                        d.terminalword{b}= [ infinitive 'a'];
                    else
                        d.terminalword{b}= [ infinitive 'ont' ];
                    end
                end
            end
            if language == 1 % English
                 d.terminalword{aux} = 'will';
            end
            if language == 3 % Dutch
                 if numberindex == 1 % singular
                        d.terminalword{aux}=  'zal';
                 else
                        d.terminalword{aux} = 'zullen';
                 end
            end
                 
        end
    end
    
    a=intersect(currenttense,'#perfect');
    if ~isempty(a)
        %%% apply the label to the entire VP
        d=ApplyToChildren(d,i,'#perfect',{'_VT_COMP','_VM_COMP','_EMOTION_A_P2','_PHYSICAL_A_P2','_V_R_ADJUNCT','that','who'});
        
        %% conjugate the auxiliary
        
        if language == 1 %English
                auxil = 'have';
        end
        if language == 2 %French
                auxil = 'avoir';
        end
        if language == 3 %Dutch;
            if strcmp(infinitive,'zijn')
                auxil = 'zijn';
            else
                auxil = 'hebben';
            end
        end
        iv = strmatch(auxil,auxiliaries{1});
        if ~isempty(iv)
            d.terminalword{aux} = auxiliaries{1+numberindex}{iv};
        else
            d.terminalword{aux} = auxil;
        end
        
        %%% table-based conjugation
        iv = strmatch(infinitive,pastparticiple{1});
        if ~isempty(iv)
            d.terminalword{b} = pastparticiple{2}{iv};
        else
            %%%% language specific rules
            if language == 2 % French
                if strcmp(infinitive(end-1:end),'er');
                    d.terminalword{b}= [ infinitive(1:end-2) 'é'];
                end
            end
            if language == 1 % English
                if strcmp(infinitive(end),'e');
                    d.terminalword{b}= [ infinitive, 'd' ];
                else
                    if strcmp(infinitive(end),'y');
                        d.terminalword{b}= [ infinitive(1:end-1), 'ied' ];
                    else
                        d.terminalword{b}= [ infinitive, 'ed' ];
                    end
                end
            end
        end
    end

    a=intersect(currenttense,'#should');
    if ~isempty(a)
        %%% apply the label
        d=ApplyToChildren(d,i,'#should',{'_VT_COMP','_VM_COMP','_EMOTION_A_P2','_PHYSICAL_A_P2','_V_R_ADJUNCT','that','who'});

        %% conjugate the auxiliary
        
        if language == 1 %English
                auxil = 'should';
        end
        if language == 2 %French
                auxil = 'devoir';
        end
        if language == 3 %Dutch
                auxil = 'moeten';
        end
        
        iv = strmatch(auxil,auxiliaries{1});
        if ~isempty(iv)
            d.terminalword{aux} = auxiliaries{1+numberindex}{iv};
        else
            d.terminalword{aux} = auxil;
        end
        
        d.terminalword{b}= infinitive;
    
    end
    
    a=intersect(currenttense,'#might');
    if ~isempty(a)
        %%% apply the label to the entire VP
        d=ApplyToChildren(d,i,'#might',{'_VT_COMP','_VM_COMP','_EMOTION_A_P2','_PHYSICAL_A_P2','_V_R_ADJUNCT','that','who'});

        %% conjugate the auxiliary        
        if language == 1 %English
                auxil = 'might';
        end
        if language == 2 %French
                auxil = 'pouvoir';
        end
        if language == 3 % Dutch;
            auxil = 'kunnen'; % TODO
        end
        iv = strmatch(auxil,auxiliaries{1});
        if ~isempty(iv)
            d.terminalword{aux} = auxiliaries{1+numberindex}{iv};
        else
            d.terminalword{aux} = auxil;
        end
        
        d.terminalword{b}= infinitive;
    end
    
end
