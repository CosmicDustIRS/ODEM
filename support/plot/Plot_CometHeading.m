function gVel = Plot_CometHeading( etime )
% This function plots some lines and the terminator plane

global nucls_rad

% Plot velocity vector
comet_state = cspice_spkezr('1000012', etime, 'ECLIPJ2000', 'none', '10');
vel = comet_state(4:6)/norm(comet_state(4:6)) * (3*nucls_rad);
gVel = plot3([0, vel(1)], [0, vel(2)], [0, vel(3)], 'Color', [.8 .9 0], 'LineWidth', 2);
end

