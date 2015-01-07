
function show_NetworkActivity(obj,h2,a2,draw_connections)
%show_NetworkActivity Display network activity

  figure(h2);
  axes(a2);

% Plot the x values
  XSpacing = 9.0/obj.nx;
  Size=0.45*XSpacing;
  for i=1:obj.nx
     if abs(obj.X(i)-obj.old_X(i))>0.01
        if obj.X(i)<0.333
            R=obj.X(i)*3;
            G=0;
            B=0;
        else
            R=1;
            if obj.X(i)<0.667
               G=(obj.X(i)-0.333)*3;
               B=0;
            else
                G=1;
                B=(obj.X(i)-0.667)*3;
            end
        end
        FilCol=[R G B];
        XPos=0.05+i*XSpacing;
        plot_circle(a2,XPos,2.0,Size,FilCol,1);
        obj.old_X(i)=obj.X(i);
     end % end if
  end
  
% Plot the y values
  YSpacing = 9.0/obj.ny;
  Size=0.45*YSpacing;
  if Size>0.2
      Size=0.2;
  end
  for i=1:obj.ny
     if abs(obj.Y(i)-obj.old_Y(i))>0.01
       if obj.Y(i)<0.333
           R=obj.Y(i)*3;
           G=0;
           B=0;
       else
           R=1;
           if obj.Y(i)<0.667
              G=(obj.Y(i)-0.333)*3;
              B=0;
           else
              G=1;
              B=(obj.Y(i)-0.667)*3;
           end
       end
       FilCol=[R G B];
       XPos=0.05+i*YSpacing;
       plot_circle(a2,XPos,5.0,Size,FilCol,1);
       obj.old_Y(i)=obj.Y(i);
     end
  end
  
% Plot the q-values
  ZSpacing = 9.0/obj.nz;
  Size=0.45*ZSpacing;
  if Size>0.2
      Size=0.2;
  end
  for i=1:obj.nz
     if abs(obj.qas(i)-obj.old_qas(i))>0.01
        Val=obj.qas(i)/1.7;   % normalize to the maximally obtainable reward
        if Val < 0
            Val = 0;
        end
        if Val<0.333
            R=Val*3;
            G=0;
            B=0;
        else
            R=1;
            if Val<0.667
               G=(Val-0.333)*3;
               B=0;
            else
               G=1;
               B=(Val-0.667)*3;
            end
        end
        FilCol=[R G B];
        XPos=0.05+i*ZSpacing;
        plot_circle(a2,XPos,7.5,Size,FilCol,1);
        obj.old_qas(i)=obj.qas(i);
     end
  end
  
% Plot the z values
  Spacing = 9.0/obj.nz;
  Size=0.45*Spacing;
  Size=0.15;
  for i=1:obj.nz
     if abs(obj.Z(i)-obj.old_Z(i))>0.01
        Val=obj.Z(i);
        if Val<0.333
            R=Val*3;
            G=0;
            B=0;
        else
            R=1;
            if Val<0.667
               G=(Val-0.333)*3;
               B=0;
            else
                G=1;
                B=(Val-0.667)*3;
            end
        end
        FilCol=[R G B];
        XPos=0.05+i*Spacing;
        plot_circle(a2,XPos,8.5,Size,FilCol,1);
        obj.old_Z(i)=obj.Z(i);
     end
  end
  
  % connections
  if draw_connections
      for Ori=1:obj.nx %+1            % draw connections from layer 1 to layer 2
          for Term=1:obj.ny
              AStrength=abs(obj.weights_xy(Ori,Term));
              LWidth=AStrength*2;
              if AStrength>0.25
                  if obj.weights_xy(Ori,Term)>0
                      PCol=[0 0 1];
                  else
                      PCol=[1 0 0];
                  end
                  X1=0.05+(Ori-1)*XSpacing;
                  X2=0.05+Term*YSpacing;
                  DeltaX=X2-X1;
                  if obj.weights_xy_handle(Ori,Term)~=-1
                      delete(obj.weights_xy_handle(Ori,Term));
                  end
                  obj.weights_xy_handle(Ori,Term)=plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[2.4 4.6],'Color',PCol,'LineWidth',LWidth);
              end
          end
      end
      
      for Ori=1:obj.ny+1            % draw connections from layer 2 to layer 3
          for Term=1:obj.nz
              AStrength=abs(obj.weights_yz(Ori,Term));
              LWidth=AStrength*2;
              if AStrength>0.25
                  if obj.weights_yz(Ori,Term)>0
                      PCol=[0 0 1];
                  else
                      PCol=[1 0 0];
                  end
                  X1=0.05+(Ori-1)*YSpacing;
                  X2=0.05+Term*ZSpacing;
                  DeltaX=X2-X1;
                  if obj.weights_yz_handle(Ori,Term)~=-1
                      delete(obj.weights_yz_handle(Ori,Term));
                  end
                  obj.weights_yz_handle(Ori,Term)=plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[5.4 7.1],'Color',PCol,'LineWidth',LWidth);
              end
          end
      end
    
      
  end
end
