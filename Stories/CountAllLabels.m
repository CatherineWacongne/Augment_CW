function countstruct = CountAllLabels(s,i,countstruct)
%%%% this is a recursively called function that counts the terminal
%%%% node values and labels

if ~isempty(s.labels{i})
    labels = union(s.node{i},s.labels{i});
else
    labels = { s.node{i} };
end

for j = 1:length(labels)
    nlab = length(countstruct.labelname);
    foundit = nlab+1;
    for k = 1:nlab
        if strcmp(countstruct.labelname{k},labels{j})
            foundit = k;
        end
    end
    if foundit <= nlab
        countstruct.labelname{foundit}=labels{j};
        countstruct.count(foundit)=countstruct.count(foundit)+1;
    else
        countstruct.labelname{foundit}=labels{j};
        countstruct.count(foundit)=1;
    end
end

if s.nchildren{i}>0
    for inode = s.children{i}
        countstruct = CountAllLabels(s,inode,countstruct);
    end
end
