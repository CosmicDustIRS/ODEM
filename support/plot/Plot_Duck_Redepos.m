function gbody = Plot_Duck_Redepos( p, v, np, nv, plarea, redepos_mtot)
% This function plots the comet without shadow. Color indicates amount of
% redepositioned mass

global cmap 

X=[v(1,p(1,:)); v(1,p(2,:)); v(1,p(3,:))];
Y=[v(2,p(1,:)); v(2,p(2,:)); v(2,p(3,:))];
Z=[v(3,p(1,:)); v(3,p(2,:)); v(3,p(3,:))];

%A=mean(plarea);
A=plarea;

r = redepos_mtot./A;
maxr=max(r);
C_index = int32(r./maxr .* (length(cmap)-1)+1);
C_index = min(C_index,length(cmap));

C = ones(np,1,3);
C(:,1,1) = cmap(C_index,1);
C(:,1,2) = cmap(C_index,2);
C(:,1,3) = cmap(C_index,3);



gbody = patch(X,Y,Z,C, 'FaceColor', 'flat',...
    'AmbientStrength', .4, 'DiffuseStrength', .6, 'LineStyle', 'none');

colormap jet;
h=colorbar;
h.Color='w';
h.Position=[.1,.05,.03,.8];
h.Ticks=[0,.2,.4,.6,.8,1];
m=maxr/(30.5*3600*24)*3600*1000;
h.TickLabels=[0,.2*m,.4*m,.6*m,.8*m,m];
h.FontSize= 16;
%text(0.1, 0.85,'g/(h*m2)', 'Units','normalized','Color','w');
% for i=1:720
% camorbit(.5,0)
% imwrite(getfield(getframe(gca),'cdata'),strcat(frames_path,int2str(i),'.png'))
% end