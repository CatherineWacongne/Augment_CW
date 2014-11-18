function d=ApplyToChildren(d,i,addlabel,blocknodes)
%%% add the label 

%%%% apply it to all children
if ~ismember(d.node{i},blocknodes)  %%% these nodes block number propagation
    for inode=1:d.nchildren{i}
        d=ApplyToChildren(d,d.children{i}(inode),addlabel,blocknodes);
    end    
    
    %%% apply it
    d.labels{i} = union(d.labels{i},addlabel);
end



