function d= GraftNode(d,i,childnumber,graftednode)
%%%% inserts a new node at node i, in place of the child marked by
%%%% childnumber
%%%% give it a new child, and graft there the existing node 'graftednode'

totnode = length(d.node);

inserted1 = totnode +1;

d.node{inserted1}='#insertednode';
d.nchildren{inserted1}=2;
d.children{inserted1} = [ graftednode d.children{i}(childnumber) ];
d.labels{inserted1} =  {};

d.children{i}(childnumber)= [ inserted1 ];
