function [ r2, v2, SPI2 ] = Spawn_Particles_discrete( nodes_pos, nodes_int, Zd_bin, dt_spawn, discrete_size, etime )
% This function spawns particles with discrete mass with spawn probability
% according to node activiy.

global f N_factor particle_production_rate bulk_density reverseStr

n_nodes = size(nodes_pos,1);

P_spawn = Zd_bin .* nodes_pos(:,4) .* (pi * dt_spawn / N_factor);
spawn_rate = mean(P_spawn) * n_nodes / dt_spawn * 3600;

if f == 0                   % Adjust particle production rate
    sr_adj = particle_production_rate / spawn_rate;
    N_factor = N_factor / sr_adj;
    P_spawn = Zd_bin .* nodes_pos(:,4) .* (pi * dt_spawn / N_factor);
    spawn_rate = mean(P_spawn) * n_nodes / dt_spawn * 3600;
    fprintf('Particle spawn rate [1/h]:          %.0f\n', spawn_rate);
end

%% Warnings
if max(P_spawn) > 1
    fprintf('Propability for particle creation exceeds 1 (P = %f)\n',max(P_spawn));
    fprintf('Consider using more+smaller nodes or decrease particle production rate.\n');
    reverseStr='';
end
if spawn_rate < 100
    fprintf('Expected particle creation rate is less than 100/hour.\n');
    reverseStr='';
end

%% Roll the dice(s)
RNDS = rand(n_nodes, 1);
spawn_index = RNDS < P_spawn;
spawn_number = sum(spawn_index);
if spawn_number == 0    % Return without spawning new particles.
    r2 = [];
    v2 = [];
    SPI2=[];
    return
end

s = repmat( .5 * discrete_size, spawn_number, 1);
cstmr = (3/(4 * bulk_density))./ s;
r2 = [nodes_pos(spawn_index, 1:3), cstmr]; 
v2 = Initial_Velocity(r2, spawn_number);
v2(:,4) = etime;
SPI2 = nodes_int(spawn_index);

end

function v = Initial_Velocity(r, n)
global rot_vector
w = repmat(rot_vector.', n, 1);
v = zeros(n, 4);
v(:,1:3) = cross(w, r(:,1:3));
end
