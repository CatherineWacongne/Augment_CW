function d= DeleteNodeLeavingTrace(d,i,childnumber,trace)
%%%% Delete the child 'childnumber' of node i, replacing it by the terminal
%%%% 'trace'

totnode = length(d.node);
inserted = totnode +1;
d.node{inserted}=trace; 
d.nchildren{inserted}= 0;
d.terminalword{inserted} = trace;
d.labels{inserted} =  {};

d.children{i}(childnumber)= [ inserted ];
