function [nodes_norm, Zd_bin] = Find_Activity( nodes_norm)
% This function finds every active node's activity based on its surface
% temperature. 

global m_h2o Bin_frac_M Bin_avg_M

T = nodes_norm(:,4);
Z = Gas_Production(T);
Vg = Gas_Velocity(T);
nodes_norm(:,4) = Z .* Vg .* m_h2o;

%max_lift_particle = (GM / nucls_rad^2) ./ ( Z .* Vg);       % max. cross section to mass ratio
Zd_total_m = Z .* (m_h2o * 4);
Zd_bin_m = Zd_total_m .* Bin_frac_M;
Zd_bin = Zd_bin_m / Bin_avg_M;

end