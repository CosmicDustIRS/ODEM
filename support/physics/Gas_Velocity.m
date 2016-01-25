function Vg = Gas_Velocity( T )
% Thermal gas speed [m/s]

global m_h2o Kb

Vg = sqrt( (3 * Kb / m_h2o) .* T);

