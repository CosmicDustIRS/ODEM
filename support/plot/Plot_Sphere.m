function gbody = Plot_Sphere( )
% This function plots a sphere. (now obsolete, comet is plotted using the
% shape model) 

global nucls_rad rot_matrix
n = 20;
[x,y,z] = sphere(n);
for i=1:n+1
    for j=1:n+1
        vec = rot_matrix * [x(i,j); y(i,j); z(i,j)] .* nucls_rad;
        x(i,j) = vec(1);
        y(i,j) = vec(2);
        z(i,j) = vec(3);
    end
end
C = ones(n,n,3)*.5;
gbody = surf(x,y,z,C, 'FaceColor', 'flat', 'FaceAlpha', .8, 'FaceLighting', 'gouraud',...
    'BackFaceLighting', 'unlit', 'AmbientStrength', 0.1, 'DiffuseStrength', .95, ...
    'LineStyle', '-', 'AlignVertexCenters', 'on' );



