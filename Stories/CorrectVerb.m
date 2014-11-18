function d=CorrectVerb(d)

numberlabels = {'$SINGULAR','$PLURAL','$UNSPECIFIED'};
genderlabels = {'$MASC','$FEMI'};

for i=FindInChildren(d,1,[],'_V_P2')
    p = FindParents(d,i,[]);
    ii=1;
    while ~strcmp(d.node(p(ii)),'_T_P2')
        ii=ii+1;
    end
    np2=FindInChildren(d,p(ii),[],'_N_P2'); %%% find the subject
    currentnumber = intersect(d.labels{np2(1)},numberlabels);
    currentgender = intersect(d.labels{np2(1)},genderlabels);
    
    tp0=FindInChildren(d,p(ii),[],'_T_P0');
    d=ApplyToChildren(d,tp0(1),currentnumber,'');

    vp1=FindInChildren(d,i,[],'_V_P1');
    blocknodes = {'_VT_COMP','_VM_COMP','_V_R_ADJUNCT','_V_L_ADJUNCT','_EMOTION_A_P2','_PHYSICAL_A_P2'};
    d=ApplyToChildren(d,vp1(1),currentnumber,blocknodes);
    
    %%% special case of the verb TO BE: the adjective must agree with the
    %%% subject
    vp0=FindInChildren(d,i,[],'_V_P0');
    vp0 = vp0(1);
    if strcmp(d.node{vp0},'_BE_V_P0');
        blocknodes = {'_P_P2','_A_SPEC','_A_COMP','_N_COMP','of_P','to_P','de_P'};
        ap2=FindInChildren(d,i,[],'_A_P2');
        d=ApplyToChildren(d,ap2(1),union(currentnumber,currentgender),blocknodes);
    end
end

%%% infinitives
% for i=FindInChildren(d,1,[],'_V_P1')
%     if ismember(d.labels{i},'$INFINITIVE');
%         b=FindInChildren(d,i,[],'_V_P0');
%         d=ApplyToChildren(d,b(1),'$INFINITIVE','');
%     end
% end
