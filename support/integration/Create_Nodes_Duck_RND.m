function nodes_bfix = Create_Nodes_Duck_RND( n_nodes , area, plcenter, plnorm, plarea )
% This function randomly places nodes (ice tiles) around the comet. 
% It uses the center positions of the shape model triangular plates.
% Ice tiles are only placed on plates that have at least twice the area
% of the tile.

np = size(plnorm,1);
rp = randperm(np);

nodes_bfix = zeros(n_nodes,8);
i=1;
j=1;
while i <= np
    k = rp(i);
    if plarea(k) < 2*area                   % plate has to have at least twice the area as the ice tile
        i=i+1;
        continue;
    end
    nodes_bfix(j,1:3) = plcenter(k,1:3);    % (1-3) contains bfix coordinates of plate centre
    nodes_bfix(j,4:6) = plnorm(k,1:3);      % (4-6) conatins normal vector of plate
    nodes_bfix(j,8)   = k;                  % (8) conatins shape model index of plate
    j=j+1;
    i=i+1;
    if j == n_nodes+1
        break;
    end
end
nodes_bfix(:,7) = area./pi;                 % (7) conatins node-radius squared [m2]

