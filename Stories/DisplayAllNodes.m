function DisplayAllNodes(s,i)
%%%% this is a recursively called function that displays all nodes

disp(s.node{i})
for inode=1:s.nchildren{i}
    DisplayAllNodes(s,s.children{i}(inode));
end
