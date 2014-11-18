function d=PrepareTerminalLabels(d,i,currentlabels)
%% identifies NPs with a certain case, and propagates the labels to the
%% underlying det, adj and nouns

%%% identify all ways to parse the right-hand side of the node
parselabels = { d.node{i} };
jj=strfind(d.node{i},'_');
for ii=jj
    parselabels = union(parselabels,d.node{i}(ii:end));
end

%disp(d.node{i});
currentlabels = union(currentlabels,parselabels);

if ~strcmp(d.node{i}(1),'_') %%% this is a terminal
    d.alllabels{i} = union(currentlabels,d.labels{i});
else
    %%% recursively call the function
    for inode=1:d.nchildren{i}
        d=PrepareTerminalLabels(d,d.children{i}(inode),currentlabels);
    end
end


