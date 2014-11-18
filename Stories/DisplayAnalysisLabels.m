function DisplayAnalysisLabels(s,i,wordsequence)
%%%% this is a recursively called function that displays only terminal
%%%% nodes

if (s.nchildren{i}==0)
    if (~strcmp(s.node{i}(1),'_'))&&(~strcmp(s.node{i}(1),'#'))   %% definition of a terminal node
        %%% now print
        labelstring = '';
        for ii=1:length(s.analysis_labels{i})
            labelstring = sprintf('%s %s ',labelstring,cell2mat(s.analysis_labels{i}(ii)));
        end
        dispstring = sprintf('%8s : %s',s.terminalword{i},labelstring);
        disp(dispstring);
        
    end
else
    for inode = s.children{i}
        DisplayAnalysisLabels(s,inode,wordsequence);
    end
end