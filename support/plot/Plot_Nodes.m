function gNode = Plot_Nodes( nodes_bfix )
% This function plots a dot on every node position.

global rot_matrix
n = size(nodes_bfix,1);
r = zeros(n,4);
for i=1:size(nodes_bfix,1)
    r(i,1:3) = rot_matrix * nodes_bfix(i,1:3).';
end
gNode = scatter3(r(:,1),r(:,2),r(:,3),60,'.', 'MarkerEdgeColor', [.5 .5 1]);

end

