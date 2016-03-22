function [ dis_sun, dir_sun ] = Get_Sun_Distance_and_Direction( etime )
% This function determines the comet's distance to the sun and its
% direction using SPICE

global AU f
sun_pos = cspice_spkpos('10', etime, 'ECLIPJ2000', 'none', '1000012');
sun_pos = sun_pos / AU;
dis_sun = norm(sun_pos);
dir_sun = sun_pos / dis_sun;
if f == 0
    fprintf('CG''s distance to the Sun [AU]:      %.1f\n', dis_sun);
end

