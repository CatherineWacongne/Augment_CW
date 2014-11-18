function d= ReorderPronoun(d,i)
%%%% Specifically for French, reorder the accusative pronoun and the verb

global language;
if language == 2 % French
    if ~isempty(i)
        if d.nchildren{i}>0
            ip = d.children{i}(1); %%% this is the actual node for the pronoun
        else
            ip=i;
        end
        pronoun = d.node{ip};
        labels = d.labels{ip};
        if strcmp(d.terminalword{ip}(1),'#')
            newnode = sprintf('le_%s',d.terminalword{ip});
        else
            newnode = sprintf('%s_PRONOUN_MOV',pronoun);
            d.terminalword{ip} = '#emptypronoun';
        end
        
        parents = FindParents(d,i,[]);
        for k=1:length(parents)
            if strfind(d.node{parents(k)},'_T_P1')  %%% find the parent tense phrase
                tp1 = parents(k);
                break;
            end

        end
        if ~isempty( [ FindInChildren(d,tp1,[],'#might') FindInChildren(d,tp1,[],'#should') ])
            for k=1:length(parents)
                if strfind(d.node{parents(k)},'_V_P1')  %%% find the first parent VP1
                    vp1 = parents(k);
                    break;
                end
            end
            childnumber = find( d.children{parents(k+1)} == vp1);
            d=InsertNode(d,parents(k+1),childnumber,newnode,labels);
        else
            tp2=parents(k+1);
            d=InsertNode(d,tp2,2,newnode,labels);
            
            %%%% very special case of French past participle: need to
            %%%% agreement with the pronoun preceding it!
            if ~isempty(intersect(d.labels{tp1},'#perfect'))
                numberlabels = {'$SINGULAR','$PLURAL'};
                genderlabels = {'$MASC','$FEMI'};
                possiblelabels = union(numberlabels,genderlabels);
                %%% begin by removing any existing labels on the past
                %%% participle
                pp = FindInChildren(d,tp1,[],'_V_P0');
                if ~strcmp(d.node{pp},'_BE_V_P0')  %%% "�t�" ne s'accord pas
                    pp = d.children{pp(1)}(1); %% this is the node of the past participle
                    oldlabels = d.labels{pp};
                    newlabels = intersect(oldlabels,setxor(oldlabels,possiblelabels));
                    %% then add the labels of the pronoun
                    newlabels = union(newlabels, intersect(labels,possiblelabels));
                    d.labels{pp} = newlabels;
                    %%% then compute the proper agreement of the past
                    %%% participle
                    currentgender=intersect(newlabels,genderlabels);
                    ii = strmatch(currentgender,genderlabels);
                    if ii==2 % feminine
                        d.terminalword{pp}= [ d.terminalword{pp} 'e' ];
                    end
                    currentnumber=intersect(newlabels,numberlabels);
                    ii = strmatch(currentnumber,numberlabels);
                    if ii==2 % plural
                        d.terminalword{pp}= [ d.terminalword{pp} 's' ];
                    end
                end
            end
        end
    end
end
