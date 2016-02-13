function gbody = Plot_Duck( p, v, np, nv)
% This function plots the comet without shadow.

global rot_matrix

for i=1:nv
    v(1:3, i) = rot_matrix * v(1:3,i);
end
X=[v(1,p(1,:)); v(1,p(2,:)); v(1,p(3,:))];
Y=[v(2,p(1,:)); v(2,p(2,:)); v(2,p(3,:))];
Z=[v(3,p(1,:)); v(3,p(2,:)); v(3,p(3,:))];
C = .6*ones(np,1,3);

% Set facet colors:
%hit_index = redepos_mtot > 0;
%C(hit_index,1,1) = 0;
%C(hit_index,1,2:3) = 0;
% size(C(:,1,1))
% jo=redepos_mtot./max(redepos_mtot)*10;
% jo = min(jo,1);
% size(redepos_mtot)
% C(:,1,1) = jo;
% C(:,1,2) = 0;
% C(:,1,3) = 1-jo;

gbody = patch(X,Y,Z,C, 'FaceColor', 'flat',...
    'AmbientStrength', .2, 'DiffuseStrength', .8, 'LineStyle', 'none');

end
