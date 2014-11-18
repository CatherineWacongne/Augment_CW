function d=PropagateCase(d,i,currentcase)
%% identifies NPs with a certain case, and propagates the labels to the
%% underlying det, adj and nouns

if ~ismember(d.node{i},{'_P_P2','_N_R_ADJUNCT','_N_COMP','of_P','to_P'})  %%% these nodes block case propagation
    d.labels{i} = union(d.labels{i}, currentcase );
    for inode=1:d.nchildren{i}
        d=PropagateCase(d,d.children{i}(inode),currentcase);
    end    
end

