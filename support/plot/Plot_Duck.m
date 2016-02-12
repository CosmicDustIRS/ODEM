function gbody = Plot_Duck( p, v, np, nv)
% This function plots the comet without shadow.

global rot_matrix redepos_mtot

for i=1:nv
    v(1:3, i) = rot_matrix * v(1:3,i);
end
X=[v(1,p(1,:)); v(1,p(2,:)); v(1,p(3,:))];
Y=[v(2,p(1,:)); v(2,p(2,:)); v(2,p(3,:))];
Z=[v(3,p(1,:)); v(3,p(2,:)); v(3,p(3,:))];

% Set facet colors:
hit_index = redepos_mtot > 0;
C = .6.*ones(np,1,3);
%C(hit_index,1,1) = 1;
%C(hit_index,1,2:3) = 0;

gbody = patch(X,Y,Z,C, 'FaceColor', 'flat',...'BackFaceLighting', 'unlit',...
    'AmbientStrength', 0.2, 'DiffuseStrength', .8, 'LineStyle', 'none');

end
