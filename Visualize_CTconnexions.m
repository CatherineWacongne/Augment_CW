%% create connectivity plot
scrsz = get(0,'ScreenSize');
h2 = figure('Position',[1+scrsz(3)/2 scrsz(4)/2.4 scrsz(3)/2.8 scrsz(4)/2]);             % this figure is for showing the network state
a2 = axes();
set(a2,'NextPlot','add');
plot(a2,1:10,1:10,'Color',[1,1,1])
XSpacing = 9.0/8;
  
  %% plot the connections
 % from input to hidden 
for cl = 1:12
    isdrawn = 1;
    conn_strength = n.weights_xy(find(n.wxy_class==cl,1));
    cmap = colormap(jet);
    cscale = [-1.5 1.5];
    cunit = (cscale(2)-cscale(1))/size(cmap,1);
    LWidth = abs(conn_strength)*2;
    if LWidth<0.5
        isdrawn = 0;
    end
    conn_strength = max(cscale(1),conn_strength);
    conn_strength = min(cscale(2),conn_strength);
    PCol = cmap( round((conn_strength-cscale(1))/cunit),:);
    ismod = cl>6;
    
    switch cl
        case {1 7}
            X1 = 0.05+ XSpacing + XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2 -XSpacing*ismod;       
           
        case {2 8}
            X1 = 0.05+ XSpacing+ XSpacing*ismod;
            X2 = X1 +2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod;   
            
        case {3 9}
            X1 = 0.05+ 3*XSpacing+ XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X2-X1;   
            if isdrawn;plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[2.4 4.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 5*XSpacing+ XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2-XSpacing*ismod; 
        case {4 10}
            X1 = 0.05+ 3*XSpacing+ XSpacing*ismod;
            X2 = X1 -2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X2-X1;   
            if isdrawn;plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[2.4 4.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 3*XSpacing+ XSpacing*ismod;
            X2 = X1 +2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X2-X1;   
            if isdrawn;plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[2.4 4.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 5*XSpacing+ XSpacing*ismod;
            X2 = X1 -2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X2-X1;   
            if isdrawn;plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[2.4 4.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 5*XSpacing+ XSpacing*ismod;
            X2 = X1 +2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X2-X1;   
            if isdrawn;plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[2.4 4.6],'Color',PCol,'LineWidth',LWidth);end
            
        case {5 11}
            X1 = 0.05+ 7*XSpacing+ XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2-XSpacing*ismod;
            
        case {6 12}
            X1 = 0.05+ 7*XSpacing+ XSpacing*ismod;
            X2 = X1 -2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            
        
    end
     DeltaX=X2-X1;   
     if isdrawn;plot(a2,[X1+0.1*DeltaX X2-0.1*DeltaX],[2.4 4.6],'Color',PCol,'LineWidth',LWidth);end
        
end
% from hidden to input
for cl = 7:12
    isdrawn = 1;
    conn_strength = n.weights_yx(find(n.wyx_class==cl,1));
    cmap = colormap(jet);
    cscale = [-1.5 1.5];
    cunit = (cscale(2)-cscale(1))/size(cmap,1);
    LWidth = abs(conn_strength)*2;
    if LWidth<0.5
        isdrawn = 0;
    end
    conn_strength = max(cscale(1),conn_strength);
    conn_strength = min(cscale(2),conn_strength);
    PCol = cmap( round((conn_strength-cscale(1))/cunit),:);
    ismod =1;
    switch cl
        case {1 7}
            X1 = 0.05+ XSpacing + XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2 -XSpacing*ismod;       
           
        case {2 8}
            X1 = 0.05+ XSpacing+ XSpacing*ismod;
            X2 = X1 +2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod;   
            
        case {3 9}
            X1 = 0.05+ 3*XSpacing+ XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X1-X2;      
            if isdrawn;plot(a2,[X2+0.1*DeltaX X1-0.1*DeltaX],[5.4 7.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 5*XSpacing+ XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2-XSpacing*ismod; 
        case {4 10}
            X1 = 0.05+ 3*XSpacing+ XSpacing*ismod;
            X2 = X1 -2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X1-X2;     
            if isdrawn;plot(a2,[X2+0.1*DeltaX X1-0.1*DeltaX],[5.4 7.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 3*XSpacing+ XSpacing*ismod;
            X2 = X1 +2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X1-X2;   
            if isdrawn;plot(a2,[X2+0.1*DeltaX X1-0.1*DeltaX],[5.4 7.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 5*XSpacing+ XSpacing*ismod;
            X2 = X1 -2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X1-X2;     
            if isdrawn;plot(a2,[X2+0.1*DeltaX X1-0.1*DeltaX],[5.4 7.6],'Color',PCol,'LineWidth',LWidth);end
            
            X1 = 0.05+ 5*XSpacing+ XSpacing*ismod;
            X2 = X1 +2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            DeltaX=X1-X2;    
            if isdrawn;plot(a2,[X2+0.1*DeltaX X1-0.1*DeltaX],[5.4 7.6],'Color',PCol,'LineWidth',LWidth);end
            
        case {5 11}
            X1 = 0.05+ 7*XSpacing+ XSpacing*ismod;
            X2 = X1 + (XSpacing+.05)/2-XSpacing*ismod;
            
        case {6 12}
            X1 = 0.05+ 7*XSpacing+ XSpacing*ismod;
            X2 = X1 -2*XSpacing + (XSpacing+.05)/2-XSpacing*ismod; 
            
        
    end
     DeltaX=X1-X2;   
     if isdrawn;plot(a2,[X2+0.1*DeltaX X1-0.1*DeltaX],[5.4 7.6],'Color',PCol,'LineWidth',LWidth);end
%      pause
    
end


%% Plot the x and y values

  Size_n=0.45*XSpacing;
  Size_m = 0.35*XSpacing;
  for i=1:4
      switch i
          case 1
              FilCol_n = [1 0 0];
              FilCol_m = [1 .5 .5];
          case {2 3}
              FilCol_n = [0 .8 0];
              FilCol_m = [0.5 .8 0.5];
          case 4
              FilCol_n = [0 0 1];
              FilCol_m = [0.5 0.5 1];
      end
      XPos_n=0.05+(2*i-1)*XSpacing;
      XPos_m= (2*i)*XSpacing;
      plot_circle(a2,XPos_n,2.0,Size_n,FilCol_n,1);
      plot_circle(a2,XPos_m,2.0,Size_m,FilCol_m,1);
      plot_circle(a2,XPos_n+(XSpacing+.05)/2,5.0,Size_n,[.7 .7 .7],1);
      plot_circle(a2,XPos_m,8.0,Size_m,FilCol_m,1);
  end % end if  