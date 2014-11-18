function plot_circle(ahandle,x,y,radius,filcol,line);  %,Color=Color,Erase_It=Erase_It
%Plot_Circle Plot circle with centre (x,y) and radius
  npoints = 2.0 * radius;
  if npoints < 40 
    npoints = 40.0;
  end
  xval = single(npoints+1);
  yval = single(npoints+1);
  for ploop =1:npoints+1
    angle = ploop/single(npoints) * pi * 2.0;
    xval(ploop) = x + cos(angle) * radius;
    yval(ploop) = y + sin(angle) * radius;
  end  % ploop
  filcol(filcol>1)=1;
  filcol(filcol<0)=0;
  fill(xval, yval, filcol); 
  if ~line
    plot(xval, yval, 'Color', filcol);
  end
%  IF KeyWord_Set(Erase_It) THEN PolyFill,XVal,YVal,Color=0 ELSE BEGIN
%    IF Keyword_Set(Color) THEN PolyFill,XVal,YVal,Color=Color(0)
%    OPlot,XVal,YVal