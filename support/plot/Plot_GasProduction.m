function gGasP = Plot_GasProduction( nodes_pos, nodes_norm )
% This function plots the gas production, represented by white lines,
% length according to node activity.

production = nodes_norm(:,4).^1.5;
U = nodes_norm(:,1) .* production;
V = nodes_norm(:,2) .* production;
W = nodes_norm(:,3) .* production;
gGasP = quiver3(nodes_pos(:,1), nodes_pos(:,2), nodes_pos(:,3),...
    U, V, W, 8, 'ShowArrowHead', 'off');
gGasP.Color = 'white';

end

