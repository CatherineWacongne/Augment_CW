
function show_Display(obj,h3,a3,n,new_input,reward)
%show_Display Show the stimulus display

  figure(h3);
  axes(a3);
  if n.current_input(1)     % plot fixation point if it is there
    plot_circle(a3,5.0,5.0,0.1,[1 0 0],0); 
  else
    plot_circle(a3,5.0,5.0,0.12,[1 1 1],0);    % clear fixation point 
  end
  if new_input(2) ~= obj.old_ori
    if obj.stim_handle1 ~= -1
      delete(obj.stim_handle1);
      delete(obj.stim_handle2);
      obj.stim_handle1=-1;
      obj.stim_handle2=-1;
    end
    obj.old_ori = new_input(2); 
  end
  
% next draw an arrow in the direction
  if new_input(2)~=-1
     mx=5.0;
     my=7.0;
     x1=mx+0.25*cos(new_input(2));
     y1=my+0.25*sin(new_input(2));
     x2=mx-0.25*cos(new_input(2));
     y2=my-0.25*sin(new_input(2));
     obj.stim_handle1=plot(a3,[x1 mx],[y1,my],'Color',[0 0 0]);      
     obj.stim_handle2=plot(a3,[x2 mx],[y2,my],'Color',[0 0 0],'LineWidth',3); 
     obj.old_ori=new_input(2);
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
end
