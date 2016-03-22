function [gGBsmall, gGBbig] = Plot_GravityBodies( )
% This function plots spheres at the center of the two lobes to indicate the underlying gravity.

global rot_matrix

%Big body:
n = 30;
[x,y,z] = sphere(n);
for i=1:n+1
    for j=1:n+1
        vec = rot_matrix * [x(i,j); y(i,j); z(i,j)] .* 1579;
        center = rot_matrix * [-0.673; 0.161; -0.040] *1000; 
        x(i,j) = vec(1) + center(1);
        y(i,j) = vec(2) + center(2);
        z(i,j) = vec(3) + center(3);
    end
end
C=ones(n,n,3);
C(:,:,1)=0;
C(:,:,3)=0;
gGBbig = surf(x,y,z,C,'FaceColor', 'flat', 'FaceAlpha', .4, 'FaceLighting', 'gouraud',...
    'BackFaceLighting', 'unlit', 'AmbientStrength', 0.4, 'DiffuseStrength', .95, ...
    'LineStyle', '-', 'AlignVertexCenters', 'on' );


%Small body:
n = 20;
[x,y,z] = sphere(n);
for i=1:n+1
    for j=1:n+1
        vec = rot_matrix * [x(i,j); y(i,j); z(i,j)] .* 1172;
        center = rot_matrix * [1.523; -0.399; 0.219] *1000; 
        x(i,j) = vec(1) + center(1);
        y(i,j) = vec(2) + center(2);
        z(i,j) = vec(3) + center(3);
    end
end
C=ones(n,n,3);
C(:,:,1)=0;
C(:,:,3)=0;
gGBsmall = surf(x,y,z,C, 'FaceColor', 'flat', 'FaceAlpha', .4, 'FaceLighting', 'gouraud',...
    'BackFaceLighting', 'unlit', 'AmbientStrength', 0.4, 'DiffuseStrength', .95, ...
    'LineStyle', '-', 'AlignVertexCenters', 'on' );



