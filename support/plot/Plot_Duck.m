function gbody = Plot_Duck( p, v, np, nv )
% This function plots the comet without shadow.

global rot_matrix

for i=1:nv
    v(1:3, i) = rot_matrix * v(1:3,i);
end
X=[v(1,p(1,:)); v(1,p(2,:)); v(1,p(3,:))];
Y=[v(2,p(1,:)); v(2,p(2,:)); v(2,p(3,:))];
Z=[v(3,p(1,:)); v(3,p(2,:)); v(3,p(3,:))];
C = ones(3,np);

gbody = patch(X,Y,Z,C, 'FaceLighting', 'flat', ...'BackFaceLighting', 'unlit',...
    'AmbientStrength', 0.1, 'DiffuseStrength', .9, 'LineStyle', 'none',...
    'FaceColor', [.6 .6 .6]);
end
