function [d,i]=FindAndSub(d,istart,nodetype,nodelabels,nodesub,node2sub);
%%% search for a node matching the variable nodetype, and whose labels
%%% match the variable nodelabels
%%% substitute it, creating a new node on the fly
%%% Return the new structure and the substituted node

totnode = length(d.node);

for i = FindInChildren(d,istart,[],nodetype)
    n1=length(intersect(nodelabels,d.labels{i}));
    n2=length(nodelabels);
    if n1==n2 %%% all required labels
        %% do the substitution
        d.node{i}=nodesub;
        if ~strcmp(nodesub(1),'_')
            d.terminalword{i} = nodesub;
        end
        d.nchildren{i}=length(node2sub);
        d.children{i} = [];
        for ii=1:d.nchildren{i}
            totnode = totnode +1;
            d.children{i}= [ d.children{i} totnode ];
            d.node{totnode}=node2sub{ii};
            d.terminalword{totnode}=node2sub{ii};
            d.nchildren{totnode}=0;
            d.labels{totnode}=d.labels{i};
        end
        break; %% do it only once
    else
        i = []; %%%% return i=empty to signal that no adequate node was found
    end
end
