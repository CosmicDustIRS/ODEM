function gjetPlate = Plot_JetPlate( p, v, nv, jetPlateID)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

global rot_matrix

X = [];
Y = [];
Z = [];
np = size(jetPlateID,1);

for i=1:nv
    v(1:3, i) = rot_matrix * v(1:3, i);
end

for j=1:np

    X = [X [v(1,p(1,jetPlateID(j))); v(1,p(2,jetPlateID(j))); v(1,p(3,jetPlateID(j)))]];
    Y = [Y [v(2,p(1,jetPlateID(j))); v(2,p(2,jetPlateID(j))); v(2,p(3,jetPlateID(j)))]];
    Z = [Z [v(3,p(1,jetPlateID(j))); v(3,p(2,jetPlateID(j))); v(3,p(3,jetPlateID(j)))]];
    
end
C = .6*ones(np,1,3);

gjetPlate = patch(X,Y,Z,C, 'FaceColor', 'yellow',...
    'AmbientStrength', 0.2, 'DiffuseStrength', .8, 'LineStyle', 'none');
end

