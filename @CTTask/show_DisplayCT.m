
function show_DisplayGGSA(obj,h3,a3,n,new_input,reward,trialno)
%show_Display Show the stimulus display

  figure(h3);
  axes(a3);

% fixation point
  if n.current_input(1) | n.current_input(2)    % plot fixation point if it is there
    if ~obj.fp_on
        if obj.fp_type==1
            FCol=[0 1 0];    % pro-saccade is green
        else 
            FCol=[1 0 0];    % anti-saccade is red
        end
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
  if n.current_input(3) | n.current_input(4)    % plot fixation point if it is there
    if ~obj.tar_on
        if n.current_input(3)
          plot_circle(a3,2.5,5.0,0.2,[0 0 0],0); 
          obj.left_on=1;
        else
          plot_circle(a3,7.5,5.0,0.2,[0 0 0],0); 
          obj.left_on=0;
        end
        obj.tar_on=1;
    end
  else
    if obj.tar_on
        if obj.left_on
          plot_circle(a3,2.5,5.0,0.25,[1 1 1],0);    % clear fixation point 
        else
          plot_circle(a3,7.5,5.0,0.25,[1 1 1],0);    % clear fixation point 
        end
        obj.tar_on=0;
    end
  end

% draw fixation position
  if n.Z(1)
    fixpos=1;
  elseif n.Z(2) 
    fixpos=0;
  else 
    fixpos=2;
  end
  if fixpos ~= obj.old_fixpos
    rectx=[2 3 3 2 2];
    recty=[4.5 4.5 5.5 5.5 4.5];
    plot(a3,rectx+obj.old_fixpos*2.5,recty,'Color',[1 1 1]);  % erase previous fixpos   
    plot(a3,rectx+fixpos*2.5,recty,'Color',[0 0 0]);   
    obj.old_fixpos=fixpos;
  end
  
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
