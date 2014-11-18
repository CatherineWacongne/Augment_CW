function DisplayAllNodesWithLabels(s,i)
%%%% this is a recursively called function that displays all nodes

%%% and recursively the function
for inode=1:s.nchildren{i}
    DisplayAllNodesWithLabels(s,s.children{i}(inode));
end

%%% now print
labelstring = '';
for ii=1:length(s.labels{i})
    labelstring = sprintf('%s %s ',labelstring,s.labels{i}{ii});
end
childrenstring = '';
for ii=1:s.nchildren{i}
    childrenstring = [ childrenstring ',' sprintf('%2d',s.children{i}(ii) )];
end
childrenstring = childrenstring(2:end);
dispstring = sprintf('%2d [%5s] %10s [%15s] : %s',i,childrenstring,s.terminalword{i},s.node{i},labelstring);
disp(dispstring);

