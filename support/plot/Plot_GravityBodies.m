function [gGBsmall, gGBbig] = Plot_GravityBodies( )
% This function plots spheres at the center of the two lobes to indicate the underlying gravity.

global rot_matrix


%Small body:
n = 20;
[x,y,z] = sphere(n);
for i=1:n+1
    for j=1:n+1
        vec = rot_matrix * [x(i,j); y(i,j); z(i,j)] .* 1169;
        center = rot_matrix * [1.48; -0.34; -0.25] *1000; 
        x(i,j) = vec(1) + center(1);
        y(i,j) = vec(2) + center(2);
        z(i,j) = vec(3) + center(3);
    end
end
C=ones(n,n,3);
C(:,:,1)=0;
C(:,:,3)=0;
gGBsmall = surf(x,y,z,C, 'FaceColor', 'flat', 'FaceAlpha', .5, 'FaceLighting', 'gouraud',...
    'BackFaceLighting', 'unlit', 'AmbientStrength', 0.4, 'DiffuseStrength', .95, ...
    'LineStyle', '-', 'AlignVertexCenters', 'on' );


%Big body:
n = 30;
[x,y,z] = sphere(n);
for i=1:n+1
    for j=1:n+1
        vec = rot_matrix * [x(i,j); y(i,j); z(i,j)] .* 1643;
        center = rot_matrix * [-0.42; 0.26; -0.06] *1000; 
        x(i,j) = vec(1) + center(1);
        y(i,j) = vec(2) + center(2);
        z(i,j) = vec(3) + center(3);
    end
end
C=ones(n,n,3);
C(:,:,1)=.3;
C(:,:,3)=0;
gGBbig = surf(x,y,z,C,'FaceColor', 'flat', 'FaceAlpha', .4, 'FaceLighting', 'gouraud',...
    'BackFaceLighting', 'unlit', 'AmbientStrength', 0.4, 'DiffuseStrength', .95, ...
    'LineStyle', '-', 'AlignVertexCenters', 'on' );



