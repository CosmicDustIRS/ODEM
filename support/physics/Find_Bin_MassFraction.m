function Find_Bin_MassFraction( mmin, mmax, F_adj_exponent )
% This function finds the mass-bin-fraction of the total ejected mass.

global Bin_frac_M Bin_avg_M F_cum_Nadj m_sampling_points...
    F_cum_Nadj_mmin Bin_frac_Nadj MF_function avg_m_MF

m_sampling_points = 10.^(-20:.1:-2);
F_cum_N = Cum_Num_Fraction(m_sampling_points);
F_diff_N = -gradient(F_cum_N);
F_diff_M = F_diff_N .* m_sampling_points;
F_cum_M = cumsum(F_diff_M);

total_N_unscaled = max(F_cum_N);            % NORMALISE
total_M_unscaled = max(F_cum_M);
F_cum_N_unit = F_cum_N ./ total_N_unscaled;
F_cum_M_unit = F_cum_M ./ total_M_unscaled;

F_cum_M_mmin = interp1(m_sampling_points, F_cum_M_unit, mmin);
F_cum_M_mmax = interp1(m_sampling_points, F_cum_M_unit, mmax);
Bin_frac_M = F_cum_M_mmax - F_cum_M_mmin;
fprintf('Size-bin mass fraction:             %.3f\n', Bin_frac_M);

%% Adjust mass distribution with a variable MutliplicationFactor to decrease steepness
F_cum_Nadj = F_cum_N_unit.^(F_adj_exponent);
F_diff_Nadj = -gradient(F_cum_Nadj);
F_diff_Nadj_mmin = interp1(m_sampling_points, F_diff_Nadj, mmin);
F_diff_Nadj_mmax = interp1(m_sampling_points, F_diff_Nadj, mmax);
F_diff_N_mmin = interp1(m_sampling_points, F_diff_N, mmin);
F_diff_N_mmax = interp1(m_sampling_points, F_diff_N, mmax);
adj_ratio_Nminmax = F_diff_Nadj_mmin / F_diff_Nadj_mmax;
act_ratio_Nminmax = F_diff_N_mmin / F_diff_N_mmax;

fprintf('N_mmin to N_mmax ratio:             %1.1e\n', act_ratio_Nminmax);
fprintf('N_mmin to N_mmax ratio (adjusted):  %.2f\n', adj_ratio_Nminmax);


F_diff_N_unit = -gradient(F_cum_N_unit);
F_cum_Nadj_mmin = interp1(m_sampling_points, F_cum_Nadj, mmin);
F_cum_Nadj_mmax = interp1(m_sampling_points, F_cum_Nadj, mmax);
Bin_frac_Nadj = F_cum_Nadj_mmin - F_cum_Nadj_mmax;
MF_function = F_diff_N_unit ./ F_diff_Nadj;

Bin_avg_M = interp1(F_cum_Nadj, m_sampling_points, F_cum_Nadj_mmin-.5*Bin_frac_Nadj);
avg_m_MF = interp1(m_sampling_points, MF_function, Bin_avg_M);


end

