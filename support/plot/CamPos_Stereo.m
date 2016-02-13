function CamPos_Stereo(viewer_distance, pan)
% This function calculates an appropriate position for the second view of
% the 3D scene and moves the camera to that position. (is always on the
% right side of Rosetta (right in the sense of being upright in the 
% ECLIPJ2000 system looking at the comet.

c = 6.5/viewer_distance;           % 6.5cm is the human eye distance
target_distance = norm(campos);
camdolly(c,0,0,'fixtarget');
target_distance_new = norm(campos);
dz = target_distance/target_distance_new;
camdolly(0,0,1-dz,'fixtarget');
campan(pan,0);
