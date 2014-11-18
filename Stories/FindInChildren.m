function indices=FindInChildren(d,i,indices,nodepart);
%%%% finds all nodes containing a certain string (nodepart), starting from
%%%% node i. At the top level, the function MUST be called with null indices []

if strfind(d.node{i},nodepart)
    indices = [ indices i ];
end

%%% recursively call the function
for inode=1:d.nchildren{i}
    indices = FindInChildren(d,d.children{i}(inode),indices,nodepart);
end

