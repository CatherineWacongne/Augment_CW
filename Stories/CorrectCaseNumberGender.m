function d=CorrectCaseNumberGender(d)

possiblelabels = {'$SINGULAR','$PLURAL','$MASC','$FEMI','$NOMINATIVE','$ACCUSATIVE','$GENITIVE'};

blocknodes = {'_P_P2','_A_COMP','_N_COMP','of_P','to_P','de_P'};

for i=FindInChildren(d,1,[],'_N_P2') %% find all NPs
    labels = CollectFromChildren(d,i,{},blocknodes);

    if ismember('$UNSPECIFIED',labels)
        labels = union(labels,possiblelabels(unidrnd(2)));
    end
    labels = intersect(labels,possiblelabels);
    
    d=ApplyToChildren(d,i,labels,blocknodes);
end

