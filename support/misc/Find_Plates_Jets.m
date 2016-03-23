function [ nodes_bfixJet , jetPlateID, dirRay_latlon ] = Find_Plates_Jets( jet_areas , dirRay_latlon, plates, vertices, plcenter, plnorm, shape_handle, plot_vecLatLonJet)
% Find active pit plates on shape model by lat/lon and create ice tiles
% with given radius.
% Sort out jetPlates, that are already in nodes_bfix due to randomly
% placement
% Add directionRays of lon/lat-vector to dirRay_latlon
% Add jetPlates to nodes_bfix

jetPlateID = [];
nodes_bfixJet = [];

for i=1:size(jet_areas,1)
    
    [ plateID , dirRay ] = ...
        findFacet_by_LatLon( jet_areas(i,1), jet_areas(i,2), ...
            jet_areas(i,3), jet_areas(i,4), shape_handle, plot_vecLatLonJet );
    jetPlateID = [ jetPlateID ; plateID ];
    dirRay_latlon = [dirRay_latlon dirRay];
    nodes_bfixJet = ...
        [nodes_bfixJet ; Create_Nodes_Jet( jetPlateID(i), plates, ...
            vertices, plcenter, plnorm) ];
    
end

end
