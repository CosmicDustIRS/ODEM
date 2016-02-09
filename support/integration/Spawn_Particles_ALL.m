function [r, v] = Spawn_Particles_ALL( s, nodes_pos )
% This function spawns a particle on every node given in 'nodes_pos'

global rot_vector bulk_density

n = size(nodes_pos,1);
r = zeros(n,4);

r(:,1:3) = nodes_pos(1:1:n,1:3);    % particles start at root coords of node
r(:,4) = 3/(4 * bulk_density * s);          % (4) contains cross-section-to-mass-ratios

v = Initial_Velocity(r, n, rot_vector);
end

function v = Initial_Velocity(r, n, rot_vector)
w = repmat(rot_vector.', n, 1);
v = zeros(n, 4);
v(:,1:3) = cross(w, r(:,1:3));
end