function show_DisplayPos(obj,h3,a3,n,new_input,reward,trialno)
%show_Display Show the stimulus display

figure(h3);
axes(a3);
tarx = [5 5+2*cos(pi/4) 7 5+2*cos(pi/4) 5 5-2*cos(pi/4) 2 5-2*cos(pi/4)];
tary = [7 5+2*cos(pi/4) 5 5-2*cos(pi/4) 2 5-2*cos(pi/4) 5 5+2*cos(pi/4)];
% fixation point
if n.current_input(25)    % plot fixation point if it is there
    if ~obj.fp_on
        FCol=[0 0 0];        
        plot_circle(a3,5.0,5.0,0.1,FCol,0);
        obj.fp_on=1;
    end
else
    if obj.fp_on
        plot_circle(a3,5.0,5.0,0.12,[1 1 1],0);    % clear fixation point
        obj.fp_on=0;
    end
end

% targets
for posi = 1:8
  plot_circle(a3,tarx(posi),tary(posi),0.2,[1 1 1],0);     
end
if any(n.current_input(1:24))   
    tar = find(n.current_input(1:24));
    tar_pos = mod(tar, 8);
    if tar_pos==0; tar_pos = 8;end
    tar_col = floor((tar-1)/8)+1;
    col_tar = [0 0 0];
    col_tar(tar_col) = 1;
    
    plot_circle(a3,tarx(tar_pos),tary(tar_pos),0.2,col_tar,0);
end

% % draw fixation position
% if n.Z(4)
%     fixpos=1;
% 
% else
%     fixpos=2;
% end
% if fixpos ~= obj.old_fixpos
%     rectx=[2 3 3 2 2];
%     recty=[4.5 4.5 5.5 5.5 4.5];
%     plot(a3,rectx+obj.old_fixpos*2.5,recty,'Color',[1 1 1]);  % erase previous fixpos
%     plot(a3,rectx+fixpos*2.5,recty,'Color',[0 0 0]);
%     obj.old_fixpos=fixpos;
% end

% display reward, if any
if reward ~= obj.old_reward
    plot_circle(a3,1.0,1.0,0.5,[1 1 1],0);    % clear fixation point
    if reward == obj.fin_reward
        text(1,1,'R');
    elseif reward == obj.fix_reward
        text(1,1,'F');
    end
    obj.old_reward=reward;
end
plot_circle(a3,9.0,9.0,1,[1 1 1],0);    % clear fixation point
text(9,9,num2str(trialno));

end