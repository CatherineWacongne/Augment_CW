function indices=FindParents(d,i,indices);
%%%% lists all nodes containing a certain node i as (possibly grand-)children
%%%% At the top level, the function MUST be called with null
%%%% indices []

parent = 0;
for ii=1:length(d.node)
    for jj=1:d.nchildren{ii}
        if i == d.children{ii}(jj)
            parent = ii;
        end
    end
end

if parent>0
  indices = [ parent FindParents(d,parent,indices) ];
end

