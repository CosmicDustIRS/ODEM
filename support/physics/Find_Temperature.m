function T = Find_Temperature( r, cos_theta )
% This function finds the temperature of a surface area depending on the
% comet's distance to the Sun (r) and the angle between Sun direction and
% surface normal (theta), after Delsemme (1982)
global A_0 Sb
F_0 = 1360;

lhs = F_0 * (1 - A_0) /(r*r) * cos_theta;
T = 180;
epsilon = (1 - A_0) * Sb;
error =2;
while error > 1 
    rhs_try_1 = epsilon*T^4      + Gas_Production(T)    * Latent_Heat(T);
    rhs_try_2 = epsilon*(T+10)^4 + Gas_Production(T+10) * Latent_Heat(T+10);
    rhs_gradient = (rhs_try_2 - rhs_try_1) / 10;
    error = lhs - rhs_try_1;
    T = T + error / rhs_gradient;
end

function L = Latent_Heat( T )
% This function returns the latent heat of sublimation of ice after Murphy
% and Koop (2005)
L = 46782.5 + 35.8925*T - 0.07414*T*T + 541.5 * exp( -(T/123.75)^2);
L = L / 6.02214e23;              % from J/mol to J/molec.


