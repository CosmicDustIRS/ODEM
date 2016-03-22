function [nodes_norm, Zd_bin, gasProd_total] = Find_Activity(nodes_pos, nodes_norm, dt, etime, dust_to_gas_ratio, gasProd_total, et_start_sav)
% This function finds every node's activity based on its surface temperature. 

global m_h2o Bin_frac_M Bin_avg_M

T = nodes_norm(:,4);
Z = Gas_Production(T) * GP_observation_factor(etime);
Vg = Gas_Velocity(T);
nodes_norm(:,4) = Z .* Vg .* m_h2o;

Zd_total_m = Z .* (m_h2o * dust_to_gas_ratio);
Zd_bin_m = Zd_total_m .* Bin_frac_M;
Zd_bin = Zd_bin_m / Bin_avg_M;

% Add produced gas to total gas production
if etime > et_start_sav
    nodes_area = nodes_pos(:,4) * 3.14;
    gasProd_total = gasProd_total + sum(Z.*nodes_area) * m_h2o * dt;
end
