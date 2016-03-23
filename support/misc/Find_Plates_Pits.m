function [ nodes_bfixPit , pitPlateID , dirRay_latlon ] = Find_Plates_Pits( active_pits , dirRay_latlon, plates, vertices, plcenter, plnorm, shape_handle ,plot_vecLatLonJet)
% Find active pit plates on shape model by lat/lon and create ice tiles
% with given radius.
% Sort out jetPlates, that are already in nodes_bfix due to randomly
% placement
% Add directionRays of lon/lat-vector to dirRay_latlon
% Add jetPlates to nodes_bfix

pitPlateID = [];
nodes_bfixPit = [];

for i=1:size(active_pits,1)
    
    [ plateID , dirRay ] = ...
        findFacet_by_LatLon( active_pits(i,1), active_pits(i,1), ...
            active_pits(i,2), active_pits(i,2), shape_handle, plot_vecLatLonJet);
    pitPlateID = [ pitPlateID ; plateID ];
    dirRay_latlon = [dirRay_latlon dirRay];
    nodes_bfixPit = ...
        [nodes_bfixPit ; Create_Nodes_Jet( pitPlateID(i), plates, ...
            vertices, plcenter, plnorm, active_pits(i,3) ) ];
    
end
end
