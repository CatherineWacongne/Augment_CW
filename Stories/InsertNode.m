function d= InsertNode(d,i,childnumber,insertednode,insertedlabels)
%%%% inserts a new node at node i, replacing the child marked by
%%%% childnumber

totnode = length(d.node);

inserted1 = totnode +1;
inserted2 = totnode +2;

d.node{inserted1}='#insertednode';
d.nchildren{inserted1}=2;
d.children{inserted1} = [ inserted2 d.children{i}(childnumber) ];
d.labels{inserted1} =  {};

d.node{inserted2}=insertednode;
kk=strfind(insertednode,'_');
if ~isempty(kk)
  insertednode = insertednode(1:kk(1)-1);
end 
d.terminalword{inserted2}=insertednode;
d.nchildren{inserted2}=0;
d.labels{inserted2} = insertedlabels;

d.children{i}(childnumber)= [ inserted1 ];
