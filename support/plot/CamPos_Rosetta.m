function CamPos_Rosetta( etime, sun_dir ,max_distance )
% This function finds Rosetta's position relative to the comet and
% calculates a appropriate view angle based on the comet's distance.

global f nucls_rad

Rosetta_pos = cspice_spkpos('-226', etime, 'ECLIPJ2000', 'none', '1000012');
Rosetta_pos = Rosetta_pos * 1000;
campos(Rosetta_pos);
viewangle = atand(max_distance/norm(Rosetta_pos));
camva(viewangle);
camtarget([sun_dir(1)*2*nucls_rad, sun_dir(2)*2*nucls_rad, sun_dir(3)*2*nucls_rad]);
if f == 0
    fprintf('Rosetta''s distance to CG [km]:      %.1f\n', norm(Rosetta_pos)/1000);
end

