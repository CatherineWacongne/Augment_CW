function [d,i]= VerbEllipsis(d);

global language;

totnode = length(d.node);
candidates = FindInChildren(d,1,[],'_T_P1'); %% find a tense node
j=randperm(length(candidates));
for i =  candidates(j)
    %%%% look at its tense head
    itense = FindInChildren(d,i,[],'_T_P0');
    itense=itense(1);
    itensechild=d.children{itense}(1);
    tense = d.node{itensechild};
    %%%% look at its VP
    ivp1 = FindInChildren(d,i,[],'_V_P1');
    
    if ~isempty(ivp1)
        if language == 1 %% English
            ivp1=ivp1(1);
            nodelabels = d.labels{ivp1};

            ivp0=FindInChildren(d,ivp1,[],'_V_P0');
            ivp0=ivp0(1);
            %%% do the VP1 substitution
            d.node{ivp1}='_SUB_V_P0';
            d.nchildren{ivp1}=1;
            totnode = totnode +1;
            d.children{ivp1}= [ totnode ];
            d.node{totnode}='#emptyverb';
            d.terminalword{totnode}='#emptyverb';
            d.nchildren{totnode}=0;
            d.labels{totnode}=d.labels{ivp1};

            %%% check the special case of the verb TO BE
            if (~isempty(ivp0)) & (strcmp(d.node{ivp0},'_BE_V_P0'))
                d.node{ivp1} = '_BE_SUB';
                j=d.children{ivp1}(1);
                if length(intersect(nodelabels,{'#present','$SINGULAR'}))==2
                    d.node{j}         = 'is';
                    d.terminalword{j} = 'is';
                end
                if length(intersect(nodelabels,{'#inf'}))==1 % was '#infinitive'
                    d.node{j}         = 'be';
                    d.terminalword{j} = 'be';
                end
                if length(intersect(nodelabels,{'#present','$PLURAL'}))==2
                    d.node{j}         = 'are';
                    d.terminalword{j} = 'are';
                end
                if length(intersect(nodelabels,{'#past','$SINGULAR'}))==2
                    d.node{j}         = 'was';
                    d.terminalword{j} = 'was';
                end
                if length(intersect(nodelabels,{'#past','$PLURAL'}))==2
                    d.node{j}         = 'were';
                    d.terminalword{j} = 'were';
                end
            end

            %%%% add "do, does, did"  to avoid empty verb phrases
            if (length(intersect(nodelabels,{'#present','$SINGULAR'}))==2) & (strcmp(d.node{totnode},'#emptyverb'))
                d.node{itensechild}         = 'does';
                d.terminalword{itensechild} = 'does';
            end
            if (length(intersect(nodelabels,{'#present','$PLURAL'}))==2) & (strcmp(d.node{totnode},'#emptyverb'))
                d.node{itensechild}         = 'do';
                d.terminalword{itensechild} = 'do';
            end
            if (length(intersect(nodelabels,{'#past'}))==1) & (strcmp(d.node{totnode},'#emptyverb'))
                d.node{itensechild}         = 'did';
                d.terminalword{itensechild} = 'did';
            end
        end
            
        if language == 2 %% French
            nodelabels = d.labels{ivp1(1)};
            
            ivp0=FindInChildren(d,ivp1(1),[],'_V_P0');
            ivp0=ivp0(1);
            if isempty(FindInChildren(d,1,[],'#insertednode'))
                %% VERIFY THAT no #insertednode is present -- no move
                %% operation prior to the verb ellipsis
                
                %%% only substitute action verbs with "faire"
                if (~isempty(ivp0)) & (strmatch(d.node{ivp0},{'_VI_V_P0','_VT_V_P0'}))
                    [d,newnode]=FindAndSub(d,ivp0,d.node{ivp0},{},'_SUB_V_P0',{'faire'});
                    %%% conjugate the new verb 
                    d=ConjugateVerb(d,i);
                    d=MoveWords(d);
                    %%% add an empty pronoun
                    parents = FindParents(d,ivp0,[]);
                    totnode = length(d.node);
                    totnode = totnode +1;
                    d.nchildren{parents(1)}=2;
                    d.children{parents(1)}(2) = totnode;
                    d.node{totnode}='#emptypronoun';
                    d.terminalword{totnode}='#emptypronoun';
                    d.nchildren{totnode}=0;
                    d.labels{totnode}={'$ACCUSATIVE'};
                    
                    d=ReorderPronoun(d,totnode);
                    
                    %         %%% remove any right adjunct, complements, adverbs etc
                    for ii=1:length(ivp1)
                        k=ivp1(ii);
                        if strcmp(d.node{d.children{k}(1)},'_V_L_ADJUNCT')
                            d.children{k} = d.children{k}(2);
                            d.nchildren{k} = 1;
                        else
                            d.children{k} = d.children{k}(1);
                            d.nchildren{k} = 1;
                        end
                    end
                end
            end
        end
    end
    break; %% do only one TP substitution
end
