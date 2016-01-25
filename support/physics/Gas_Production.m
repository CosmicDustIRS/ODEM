function Z = Gas_Production( T )
% This function finds the gas production rate after
% Delsemme (1982)   [molec./(m^2*s)]

global m_h2o Kb

%Calculate vapor pressure first (after Murphy and Koop (2005)) [Pa]
P = exp(9.550426 - 5723.265 ./ T + 3.53068 .* log(T) - 0.00728332 .* T);

Z = P ./ sqrt((2 * pi * m_h2o  * Kb) .* T);

