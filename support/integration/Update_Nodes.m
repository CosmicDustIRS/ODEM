function [nodes_pos, nodes_norm, nodes_int] = Update_Nodes( nodes_bfix, d_sun, sun_dir, shape_handle )
% This function finds illuminated nodes for a given time and calculates
% their surface temperatures.

global rot_matrix dladsc
n = size(nodes_bfix,1);
nodes_pos = zeros(n,4);
nodes_norm = zeros(n,4);
cos_theta = zeros(n,1);
illu_index = false(n,1);

for i=1:n
    nodes_norm(i,1:3) = rot_matrix * nodes_bfix(i,4:6).';
end
nodes_pos(:,4) = nodes_bfix(:,7);             % (4) contains node-radius^2
nodes_int = nodes_bfix(:,8);                  % (8) contains shape-model plate index


% Find illumination angle and sort out dark nodes
sun_bfix = rot_matrix.' * sun_dir;
for i=1:n
    if dot(nodes_norm(i,1:3), sun_dir) > 0
        [~,~,found] = cspice_dskx02(shape_handle, dladsc, nodes_bfix(i,1:3).'/1000, sun_bfix);
        if ~found
            illu_index(i) = 1;
            nodes_pos(i,1:3) = rot_matrix * nodes_bfix(i,1:3).';
            cos_theta(i) = dot(nodes_norm(i,1:3),sun_dir);
        end
    end
end
nodes_norm = nodes_norm(illu_index,:);
nodes_pos = nodes_pos(illu_index,:);
nodes_int = nodes_int(illu_index,:);
cos_theta = cos_theta(illu_index);

% Find temperature of illuminated nodes
for i=1:size(nodes_pos,1)
    nodes_norm(i,4) = Find_Temperature(d_sun, cos_theta(i));
end



