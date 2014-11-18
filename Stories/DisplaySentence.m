function DisplaySentence(s,i)
%%%% this is a recursively called function that displays only terminal
%%%% nodes

if (s.nchildren{i}==0)
    if ~strcmp(s.node{i}(1),'_')   %% definition of a terminal node
       disp(s.terminalword{i});
    end
else
   for inode = s.children{i}
       DisplaySentence(s,inode);
   end  
end