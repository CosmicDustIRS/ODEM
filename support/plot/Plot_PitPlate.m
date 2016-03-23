function gpitPlate = Plot_PitPlate( p, v, nv, pitPlateID )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

global rot_matrix

X = [];
Y = [];
Z = [];
np = size(pitPlateID,1);

for i=1:nv
    v(1:3, i) = rot_matrix * v(1:3, i);
end

for j=1:np

    X = [X [v(1,p(1,pitPlateID(j))); v(1,p(2,pitPlateID(j))); v(1,p(3,pitPlateID(j)))]];
    Y = [Y [v(2,p(1,pitPlateID(j))); v(2,p(2,pitPlateID(j))); v(2,p(3,pitPlateID(j)))]];
    Z = [Z [v(3,p(1,pitPlateID(j))); v(3,p(2,pitPlateID(j))); v(3,p(3,pitPlateID(j)))]];
    
end
C = .6*ones(np,1,3);

gpitPlate = patch(X,Y,Z,C, 'FaceColor', 'green',...
    'AmbientStrength', 0.2, 'DiffuseStrength', .8, 'LineStyle', 'none');
end

