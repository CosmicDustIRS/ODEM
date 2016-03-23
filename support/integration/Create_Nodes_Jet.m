function nodes_bfixJet = Create_Nodes_Jet( plateID, plates, vertices, plcenter, plnorm, radius )
% This Function returns dataset for jetPlates
%   Detailed explanation goes here
%
% Input:    jetPlateID  - index of jet plates
%           plates      - array with plates vertex numbers
%           vertices    - array with vertices' vectors (m)
%           plcenter    - array with center coordinates
%           plnorm      - array with normal vector of each plate
%
% Output:   nodes_bfixJet - [plcenter_vector(3), plnorm_vector(3), node_r2, plate_index]
%

np = size( plateID,1 );
nodes_bfixJet = zeros(np,8);

for i = 1:np
    k = plateID(i);
    
    vertex1 = vertices(1:3, plates(1,k));
    vertex2 = vertices(1:3, plates(2,k));
    vertex3 = vertices(1:3, plates(3,k));
    
    if (exist( 'radius', 'var'))
        area = pi * radius^2;
    else
        area = 1/2 * norm(cross((vertex2-vertex1),(vertex3-vertex1)));
    end
    
    nodes_bfixJet(i,1:3) = plcenter(k,1:3);
    nodes_bfixJet(i,4:6) = plnorm(k,1:3);
    nodes_bfixJet(i,7) = area/pi;
    nodes_bfixJet(i,8) = k;

end

