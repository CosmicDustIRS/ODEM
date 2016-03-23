function [ r, v ] = Spawn_Particles_MC( r_old, v_old, nodes_pos, Zd_bin, dt_spawn )
% This function spawns particles using a mass distribution with spawn
% probability according to node activity and particles mass (Monte Carlo approach)

global f F_cum_Nadj m_sampling_points F_cum_Nadj_mmin ...
    MF_function Bin_frac_Nadj avg_m_MF Bin_avg_M particle_production_rate bulk_density
n_nodes = size(nodes_pos,1);


P_spawn = Zd_bin .* nodes_pos(:,4) .* (pi * dt_spawn / avg_m_MF);  %Probability of every node to spawn a particle
spawn_rate = mean(P_spawn) * n_nodes / dt_spawn * 3600;
if f == 1                                                   % Adjust particle production rate
    sr_adj = particle_production_rate / spawn_rate;
    avg_m_MF = avg_m_MF ./ sr_adj;
    P_spawn = Zd_bin .* nodes_pos(:,4) .* (pi * dt_spawn / avg_m_MF);
    spawn_rate = mean(P_spawn) * n_nodes / dt_spawn * 3600;
    fprintf('Particle spawn rate [1/h]:          %.0f\n', spawn_rate);
end

%% Adjust multiplication factor (only necessary once at the beginning of the simulation)
if f==1
    M_rel = zeros(100,1);
    for i=1:100
        P_spawn = Zd_bin .* nodes_pos(:,4) .* (pi * dt_spawn / avg_m_MF);
        rnd_num_spawn = rand(n_nodes, 1);
        spawn_index = rnd_num_spawn < P_spawn;
        spawn_number = sum(spawn_index);
        rnd_num_mass = rand(spawn_number,1);
        m_dust = interp1(F_cum_Nadj, m_sampling_points, F_cum_Nadj_mmin-rnd_num_mass.*Bin_frac_Nadj);
        MF_dust = interp1(m_sampling_points, MF_function, m_dust);
        M_soll = sum(Zd_bin .* nodes_pos(:,4)) * ( Bin_avg_M *pi * dt_spawn);
        M_ist = sum(m_dust .* MF_dust);
        M_rel(i) = M_ist/M_soll;
    end
    MF_function = MF_function / mean(M_rel);
    %disp('rel. diff.:');
    %mean(M_rel)
end

%% Warnings
if max(P_spawn) > 1
    fprintf('Propability for particle creation exceeds 1 (P = %f)\n',max(P_spawn));
    fprintf('Consider increasing N_factor or decreasing mass-bin range\n');
end
if spawn_rate < 100
    fprintf('Expected particle creation rate is less than 100/hour.\n');
    fprintf('Consider decreasing N_factor or increasing mass-bin range\n');
end
if spawn_rate > 3000
    fprintf('Expected particle creation rate is over 3000/hour.\n');
    fprintf('Consider increasing N_factor or decreasing mass-bin range\n');
end
%%

rnd_num_spawn = rand(n_nodes, 1);
spawn_index = rnd_num_spawn < P_spawn;		% returns rowvector(n_nodes) with either 0 or 1 values
spawn_number = sum(spawn_index);
if spawn_number == 0     % Return without spawning new particles.
    r = r_old;
    v = v_old;
    return
end

rnd_num_mass = rand(spawn_number,1);
m_dust = interp1(F_cum_Nadj, m_sampling_points, F_cum_Nadj_mmin-rnd_num_mass.*Bin_frac_Nadj);
MF_dust = interp1(m_sampling_points, MF_function, m_dust);

%M_soll = sum(Zd_bin .* nodes_pos(:,4)) * ( Bin_avg_M *pi * dt_spawn);
%M_ist = sum(m_dust .* MF_dust);
%diff = M_ist/M_soll

s = (m_dust ./ (bulk_density*pi*4/3)).^(1/3);
cstmr = (3/(4 * bulk_density))./ s;
r = [nodes_pos(spawn_index, 1:3), cstmr]; 

v = Initial_Velocity(r, spawn_number);
v(:,4) = MF_dust;

r = [r_old ; r];
v = [v_old ; v];

end

function v = Initial_Velocity(r, n)
% This function calculates the rotational velocity for each spawned particle
global rot_vector
w = repmat(rot_vector.', n, 1);
v = zeros(n, 4);
v(:,1:3) = cross(w, r(:,1:3));
end
