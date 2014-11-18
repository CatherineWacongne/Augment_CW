function countstruct = CountTerminalLabels(s,i,countstruct)
%%%% this is a recursively called function that counts the terminal
%%%% node values and labels

if (s.nchildren{i}==0)
    if (~strcmp(s.node{i}(1),'_'))&&(~strcmp(s.node{i}(1),'#'))   %% definition of a terminal node
        labels = union(s.node{i},s.labels{i});
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
    end
else
    for inode = s.children{i}
        countstruct = CountTerminalLabels(s,inode,countstruct);
    end
end