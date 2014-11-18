function [wordsequence,nodenumbers] = GenerateWordSequence(s,i,wordsequence,nodenumbers)
%%%% this is a recursively called function that computes only true terminal
%%%% nodes

if (s.nchildren{i}==0)
    if ~strcmp(s.node{i}(1),'_')   %% definition of a terminal node
        if ~strcmp(s.terminalword{i}(1),'#')
            wordsequence{end+1} = s.terminalword{i};
            nodenumbers{end+1} = i;
        end
    end
else
    for inode = s.children{i}
        [wordsequence,nodenumbers] = GenerateWordSequence(s,inode,wordsequence,nodenumbers);
    end
end