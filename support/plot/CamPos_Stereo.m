function CamPos_Stereo(etime)
% This function calculates an appropriate position for the second view of
% the 3D scene and moves the camera to that position. (is always on the
% right side of Rosetta (right in the sense of being upright in the 
% ECLIPJ2000 system looking at the comet.

global rosetta_init_distance

first_view_CP = campos;

%% Move view to the right
cam_distance = (0.065 / 1) * rosetta_init_distance;

c = cam_distance;
a = first_view_CP;
b(2) = (2*a(1)^2*a(2) - c*a(2) + 2*a(2)^3 + sqrt(4*a(1)^4*c - a(1)^2*c^2 + 4*a(1)^2*c*a(2)^2))...
        /(2*(a(1)^2+a(2)^2));
b(1) = sqrt(a(1)^2 + a(2)^2 - b(2)^2);
b(3) = a(3);
if a(1) < 0 
    b(1) = -b(1);
    Rosetta_pos = cspice_spkpos('-226', etime, 'ECLIPJ2000', 'none', '1000012');
    Rosetta_pos = Rosetta_pos * 1000;
    beta = asind(c/2 / norm(Rosetta_pos));
    campos(b);
    camorbit(beta,0);
else
    campos(b);
end