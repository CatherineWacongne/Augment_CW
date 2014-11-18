function [x,y,xlim,ylim]=DisplayTree(d,i,x,y,step,xlim,ylim);

figure(31);
if i==1
    clf;
    x=1;
    y=1;
    step=1;
    xlim = [ x x ];
    ylim = [ y y ];
end

if (d.nchildren{i}==0)
    w='WRONG';col='red'; %%% this should never appear, if the tree is OK
    if ~strcmp(d.node{i}(1),'_')   %% definition of a terminal node
        w = d.terminalword{i};
        if strcmp(d.terminalword{i}(1),'#')
            col = 'blue';
        else
            col = 'yellow';
        end
    end
else
    w = d.node{i};
    col = 'green';
end

xlim(1) = min(xlim(1),x);
ylim(1) = min(ylim(1),y);
xlim(2) = max(xlim(2),x);
ylim(2) = max(ylim(2),y);

%%% recursively call the function
for inode=1:d.nchildren{i}
    if d.nchildren{i} ==1
        newx = x;
    else
        newx = x+(inode-1.5)*0.4*step;
    end
    newy = y-0.2;
    line([ x newx],[y newy],'Color','Blue');
    [x,y,xlim,ylim]=DisplayTree(d,d.children{i}(inode),newx,newy,step*0.8,xlim,ylim);
end

h=text(x,y,w);
set(h,'BackgroundColor',col,'HorizontalAlignment','center','Interpreter','none');

if (i==1) %% execute only at the very end
    axis off;
    set(gca,'XLim',xlim,'YLim',ylim);
end
