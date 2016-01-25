function Update_RotMatrix( etime )
% This function finds the rotation matrix that transforms a vector from
% body fixed coordinates to ECLIPJ2000 coordinates.

global rot_matrix rot_vector rad_per_sec

rot_matrix = cspice_pxform( '67P/C-G_CK', 'ECLIPJ2000', etime );
%[ cmat, av, clkout, found ] = cspice_ckgpav( 1000012, sclkdp, tol, '67P/C-G_CK')

pckROT = cspice_bodvrd( '1000012', 'PM', 3);
w = [0; 0; (pckROT(2)*pi/180) / (24*3600)];      % Rotation vector in bodfix frame (w(3) is rad/s)
rot_vector = rot_matrix * w;
rad_per_sec = norm(rot_vector);
end

