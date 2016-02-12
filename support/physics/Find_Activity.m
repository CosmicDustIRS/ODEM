function [nodes_norm, Zd_bin] = Find_Activity( nodes_norm, dt, etime)
% This function finds every active node's activity based on its surface
% temperature. 

global m_h2o Bin_frac_M Bin_avg_M gasProd_total dust_to_gas_ratio

T = nodes_norm(:,4);
Z = Gas_Production(T) * GP_observation_factor(etime);
Vg = Gas_Velocity(T);
nodes_norm(:,4) = Z .* Vg .* m_h2o;

%max_lift_particle = (GM / nucls_rad^2) ./ ( Z .* Vg);       % max. cross section to mass ratio
Zd_total_m = Z .* (m_h2o * dust_to_gas_ratio);
Zd_bin_m = Zd_total_m .* Bin_frac_M;
Zd_bin = Zd_bin_m / Bin_avg_M;

gasProd_total = gasProd_total + sum(Z) * m_h2o * dt;

end