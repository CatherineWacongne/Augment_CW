function wordsequence = DisplaySentenceWithLabels(s,i,wordsequence)
%%%% this is a recursively called function that displays only terminal
%%%% nodes

if (s.nchildren{i}==0)
    if ~strcmp(s.node{i}(1),'_')   %% definition of a terminal node
        %%% now print
        labelstring = '';
        for ii=1:length(s.labels{i})
            labelstring = sprintf('%s %s ',labelstring,cell2mat(s.labels{i}(ii)));
        end
        dispstring = sprintf('%15s   [%15s]: %s',s.terminalword{i},s.node{i},labelstring);
        disp(dispstring);
        
        if ~strcmp(s.terminalword{i}(1),'#')
            wordsequence{end+1} = s.terminalword{i};
        end
    end
else
    for inode = s.children{i}
        wordsequence = DisplaySentenceWithLabels(s,inode,wordsequence);
    end
end