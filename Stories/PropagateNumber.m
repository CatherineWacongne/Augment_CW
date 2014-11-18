function [d,currentnumber]=PropagateNumber(d,i,currentnumber)

possiblelabels = {'$SINGULAR','$PLURAL','$NEUTER','$UNSPECIFIED','$MASC','$FEMI'};

%%%% if a number is identified (usually on the DET) then memorize it
if ~isempty(intersect(d.labels{i},possiblelabels))
    currentnumber = union(currentnumber,intersect(d.labels{i},possiblelabels));
end
% disp(d.node{i})
if (ismember('$UNSPECIFIED',currentnumber))&&(~isempty(strfind(d.node{i},'_N_P0')))
    currentnumber = union(setdiff(currentnumber,'$UNSPECIFIED'),possiblelabels(unidrnd(2)));  %%% choose singular or plural
end

%%%% apply it to all children
if ~ismember(d.node{i},{'_P_P2','_N_R_ADJUNCT','_N_COMP','of_P','to_P','de_P'})  %%% these nodes block number propagation
    for inode=1:d.nchildren{i}
        [d,currentnumber]=PropagateNumber(d,d.children{i}(inode),currentnumber);
    end    
end

%%% apply it
d.labels{i} = union(d.labels{i},currentnumber);


