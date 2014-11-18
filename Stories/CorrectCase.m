function d=CorrectCase(d,i)
%% identifies NPs with a certain case, and propagates the labels to the
%% underlying det, adj and nouns

caselabels = {'$NOMINATIVE','$ACCUSATIVE','$GENITIVE'};

%%% check if case has been assigned to an NP2 structure, in which case we
%%% need sto apply it to some of its children nodes
if strmatch(d.node{i},'_N_P2') 
    currentcase = intersect(caselabels,d.labels{i});
    if ~isempty(currentcase)
        d=PropagateCase(d,i,currentcase);
    end
end

%%% recursively call the function
for inode=1:d.nchildren{i}
    d=CorrectCase(d,d.children{i}(inode));
end


