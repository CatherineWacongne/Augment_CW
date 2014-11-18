function d = Substitute(d);

LoadLexicon;
global language
switch language
    case 1 % English
        maxcases = 20; %%% number of rules in the following program
    case 2 % French
        maxcases = 20; %%% number of rules in the following program
    case 3 % Dutch
        maxcases = 20;
end

requiredsub = 999; %%% desired number of sustitutions
nsub = 0; %%% current number of truly substituted items

%for requiredsub=[ 4 4 4 3 3 3 2 2 2 1 1 1 ] %%% try to find many substitutions
%for requiredsub=[ 1 1 1 ] %%% try to find many substitutions
while nsub < requiredsub;
    requiredsub = unidrnd(3); %%% desired number of sustitutions 1, 2 or 3
%    requiredsub = unidrnd(2)+unidrnd(2)-1; %%% desired number of sustitutions 1, 2 or 3
%    requiredsub = unidrnd(2)+(unidrnd(20)>1); %%% desired number of sustitutions: 2 or 3, very rarely 1
    for p=randperm(maxcases);
        switch p
            case 1
                [d,i]=FindAndSub(d,1,'_N_P2',{'$NOMINATIVE','$SINGULAR','$MASC'},'_PRONOUN_SUB',{pronouns{1}{1}{1}});
            case 2
                [d,i]=FindAndSub(d,1,'_N_P2',{'$NOMINATIVE','$SINGULAR','$FEMI'},'_PRONOUN_SUB',{pronouns{1}{1}{2}});
            case 3
                [d,i]=FindAndSub(d,1,'_N_P2',{'$NOMINATIVE','$PLURAL','$MASC'},'_PRONOUN_SUB',{pronouns{1}{2}{1}});
            case 4
                [d,i]=FindAndSub(d,1,'_N_P2',{'$NOMINATIVE','$PLURAL','$FEMI'},'_PRONOUN_SUB',{pronouns{1}{2}{2}});
            case 5
                [d,i]=FindAndSub(d,1,'_N_P2',{'$ACCUSATIVE','$SINGULAR','$MASC'},'_PRONOUN_SUB',{pronouns{2}{1}{1}});
                d=ReorderPronoun(d,i);
            case 6
                [d,i]=FindAndSub(d,1,'_N_P2',{'$ACCUSATIVE','$SINGULAR','$FEMI'},'_PRONOUN_SUB',{pronouns{2}{1}{2}});
                d=ReorderPronoun(d,i);
            case 7
                [d,i]=FindAndSub(d,1,'_N_P2',{'$ACCUSATIVE','$PLURAL','$MASC'},'_PRONOUN_SUB',{pronouns{2}{2}{1}});
                d=ReorderPronoun(d,i);
            case 8
                [d,i]=FindAndSub(d,1,'_N_P2',{'$ACCUSATIVE','$PLURAL','$FEMI'},'_PRONOUN_SUB',{pronouns{2}{2}{2}});
                d=ReorderPronoun(d,i);
            case 9
                [d,i]=FindAndSub(d,1,'_N_P2',{'$GENITIVE','$SINGULAR','$MASC'},'_PRONOUN_SUB',{pronouns{3}{1}{1}});
            case 10
                [d,i]=FindAndSub(d,1,'_N_P2',{'$GENITIVE','$SINGULAR','$FEMI'},'_PRONOUN_SUB',{pronouns{3}{1}{2}});
            case 11
                [d,i]=FindAndSub(d,1,'_N_P2',{'$GENITIVE','$PLURAL','$MASC'},'_PRONOUN_SUB',{pronouns{3}{2}{1}});
            case 12
                [d,i]=FindAndSub(d,1,'_N_P2',{'$GENITIVE','$PLURAL','$FEMI'},'_PRONOUN_SUB',{pronouns{3}{2}{2}});
            case 13
                [d,i]=FindAndSub(d,1,'_A_P2',{},'_ADJ_SUB',{'#emptyadj'});
                if ~isempty(i)
                    if language == 2 % French: after the verb "être" we cannot just delete the adjective, need to insert "l'"
                        parents = FindParents(d,i,[]);
                        if strcmp(d.node{d.children{parents(1)}(1)},'_BE_V_P0');
                            d=ReorderPronoun(d,i);
                        end
                    end
                end
%             case 15
%                 [d,i]=FindAndSub(d,1,'_INF_T_P2',{},'_INF_SUB',{deictic{2}});                
            case 14
                [d,i]=VerbEllipsis(d);
            case {15,16,17,18,19,20}  %%% to increase the frequency of this substitution
                [d,i]=FindAndSub(d,1,'_P_P2',{},'_DEICTIC_SUB',{deictic{1}});     
        end
        
        nsub = length(FindInChildren(d,1,[],'_SUB'));
        if nsub ==requiredsub
            break;break;
        end
    end
end

d.nsub = nsub;
%disp(sprintf('Number of substitutions = %d',d.nsub));

%%%% final cleanups

%% remove empty branches
d=RemoveEmpty(d,1);

%% phonological cleanup
d=PhonologicalCleanup(d);

%% prepare the additional terminal "labels" for a future analysis of activation induced by each word
d=PrepareAnalysisLabels(d,1,{});
