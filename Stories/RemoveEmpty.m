function [d,isempty] = RemoveEmpty(d,i);

if d.nchildren{i}==0
    isempty = strcmp(d.node{i},'#empty');
else
    for inode=1:d.nchildren{i}
        [d,emptychild(inode)] = RemoveEmpty(d,d.children{i}(inode));
    end
    sel = find(~emptychild);
    d.children{i} = d.children{i}(sel);
    d.nchildren{i} = length(d.children{i});
    isempty = all(emptychild);
end

