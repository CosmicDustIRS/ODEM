function [fig, cmap] = Create_Figure( )
% This function creates a matlab figure to draw the animation in.
% Returns the figure handle and a colormap vector

figure (1)
opengl('hardware')
set(gcf,'Renderer','OpenGL')
set(gcf,'Position', [100, 20, 1280, 800])
set(gca,'Position', [0,0,1,1])
set(gca,'FontSize',14)
set(gca, 'color', [0 0 .03]);
set(gca,'LooseInset',get(gca,'TightInset'))
set(gcf, 'color', [0 0 .03]);
cmap = (cool(100));
cmap(:,1) = min(cmap(:,1),.95);  % To make red look not so blurry after applying video codec
axis equal;
axis off;
hold on;
camproj('perspective');
set(gca,'CameraViewAngle',30);
fig = gcf;
fig.InvertHardcopy = 'off';
end

