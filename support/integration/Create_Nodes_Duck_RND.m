function nodes_bfix = Create_Nodes_Duck_RND( n_nodes , area, plcenter, plnorm )
% This function randomly places nodes (ice tiles) around the comet using
% the center positions of the shape model triangular plates.

np = size(plnorm,1);
rp = randperm(np);
rnd_index = rp(1:n_nodes);

nodes_bfix = zeros(n_nodes,8);
for i=1:n_nodes
    k = rnd_index(i);
    nodes_bfix(i,1:3) = plcenter(k,1:3);
    nodes_bfix(i,4:6) = plnorm(k,1:3);
    nodes_bfix(i,8) = k;
end

nodes_bfix(:,7) = area./pi;                  % (7) conatins node-radius squared [m2]

