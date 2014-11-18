function [d,x,y,xlim,ylim,terminalx]=DisplayTree(d,i,x,y,xlim,ylim,terminalx);
%%% this function receives a y coordinates from the mother node
%%% it goes down to the children, assigns the x coordinates there

if i==1 %%% initialize
    clf;
    x=1;
    y=1;
    step=1;
    xlim = [ x x ];
    ylim = [ y y ];
    terminalx = 0;
end

%%% recursively call the function to get the coordinates of the lower nodes
%%% the x coordinate is initially unassigned
clear newx newy
for inode=1:d.nchildren{i}
    [d,newx(inode),newy(inode),xlim,ylim,terminalx]=DisplayTree(d,d.children{i}(inode),x,y-0.2,xlim,ylim,terminalx);
end
if (d.nchildren{i}==0)
    w='WRONG';col='red'; %%% this should never appear, if the tree is OK:
    if ~strcmp(d.node{i}(1),'_')   %% definition of a terminal node
        w = d.terminalword{i};
        terminalx = terminalx +1;
        x = terminalx ;
        
        if strcmp(d.terminalword{i}(1),'#')
            col = 'blue';
        else
            col = 'yellow';
        end
    end
else
    w = d.node{i};
    col = 'green';
    %%% compute new x coordinate
    x = mean(newx);
    
    %%% draw lines to the children
    for inode=1:d.nchildren{i}
        line([ x newx(inode)],[y newy(inode)],'Color','Blue','LineWidth',2);
    end 
end

xlim(1) = min(xlim(1),x);
ylim(1) = min(ylim(1),y);
xlim(2) = max(xlim(2),x);
ylim(2) = max(ylim(2),y);

%%%% drawn the curent node
h=text(x,y,w);
set(h,'BackgroundColor',col,'HorizontalAlignment','center','VerticalAlignment','top','Interpreter','none');

h=text(x+0.1,y+0.03,sprintf('%2d',i),'FontSize',7);


if (i==1) %% execute only at the very end
    axis off;
    set(gca,'XLim',xlim,'YLim',ylim);
    set(gcf,'Color',[1 1 1 ]);
end
