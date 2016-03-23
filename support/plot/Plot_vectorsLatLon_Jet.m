function gLatLonVert_Jet = Plot_vectorsLatLon_Jet( dirRay )
% This function plots direction rays from the origin point to 
% longitude/latitude positions of the jet area

oPoints = zeros(size(dirRay,1) , size(dirRay,2));
dirRay = -1000*dirRay;

gLatLonVert_Jet = quiver3(oPoints(1,:), oPoints(2,:), oPoints(3,:), ...
    dirRay(1,:), dirRay(2,:), dirRay(3,:), '.y', 'LineWidth', 0.05);

end