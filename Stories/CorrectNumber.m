function d=CorrectNumber(d,i)
%% identifies NPs, check their number based on DETS or ProperNouns, and propagate to the
%% underlying det, adj and nouns

%%% check if case has been assigned to an NP2 structure, in which case we
%%% need to apply it to some of its children nodes
if strmatch(d.node{i},'_N_P2')
    %%%% need to find the number status
    currentnumber = {};
    d=PropagateNumber(d,i,currentnumber);
end

%%% recursively call the function
for inode=1:d.nchildren{i}
    d=CorrectNumber(d,d.children{i}(inode));
end


