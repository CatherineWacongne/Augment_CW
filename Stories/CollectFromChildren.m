function labels = CollectFromChildren(d,i,labels,blocknodes)
%%% collect the labels from all the children 

if ~ismember(d.node{i},blocknodes)  %%% these nodes block number propagation
    for inode=1:d.nchildren{i}
        labels = CollectFromChildren(d,d.children{i}(inode),labels,blocknodes);
    end    
end

labels = union(d.labels{i},labels);


