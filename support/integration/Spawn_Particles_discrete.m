function [ r, v ] = Spawn_Particles_discrete( r_old, v_old, nodes_pos, nodes_int, Zd_bin, dt_spawn, discrete_size )
% This function spawns particles with discrete mass with spawn probability
% according to node activiy.

global f N_factor particle_production_rate bulk_density

n_nodes = size(nodes_pos,1);

P_spawn = Zd_bin .* nodes_pos(:,4) .* (pi * dt_spawn / N_factor);
spawn_rate = mean(P_spawn) * n_nodes / dt_spawn * 3600;

if f == 1                                                   % Adjust particle production rate
    sr_adj = particle_production_rate / spawn_rate;
    N_factor = N_factor / sr_adj;
    P_spawn = Zd_bin .* nodes_pos(:,4) .* (pi * dt_spawn / N_factor);
    spawn_rate = mean(P_spawn) * n_nodes / dt_spawn * 3600;
    fprintf('Particle spawn rate [1/h]:          %.0f\n', spawn_rate);
end

%% Warnings
if max(P_spawn) > 1
    fprintf('Propability for particle creation exceeds 1 (P = %f)\n',max(P_spawn));
    fprintf('Consider increasing N_factor or decreasing mass-bin range\n');
end
if spawn_rate < 100
    fprintf('Expected particle creation rate is less than 200/hour.\n');
    fprintf('Consider decreasing N_factor or increasing mass-bin range\n');
end
if spawn_rate > 2000
    fprintf('Expected particle creation rate is over 2000/hour.\n');
    fprintf('Consider increasing N_factor or decreasing mass-bin range\n');
end
%%
RNDS = rand(n_nodes, 1);
spawn_index = RNDS < P_spawn;
spawn_number = sum(spawn_index);

if spawn_number == 0
    r = r_old;
    v = v_old;
    return
end

s = repmat( .5 * discrete_size, spawn_number, 1);
cstmr = (3/(4 * bulk_density))./ s;
r = [nodes_pos(spawn_index, 1:3), cstmr]; 

v = Initial_Velocity(r, spawn_number);
v(:,4) = nodes_int(spawn_index);

r = [r_old ; r];
v = [v_old ; v];

end

function v = Initial_Velocity(r, n)
global rot_vector
w = repmat(rot_vector.', n, 1);
v = zeros(n, 4);
v(:,1:3) = cross(w, r(:,1:3));
end
