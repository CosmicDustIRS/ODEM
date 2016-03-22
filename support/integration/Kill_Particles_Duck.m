function [r, v, SPI, redepos_mtot] = Kill_Particles_Duck( r, v, SPI, plcenter, plnorm, plarea, max_distance, et_start_sav, etime, size_discrete, redepos_mtot)
% This function deletes all particles from the pool that are INSIDE THE
% SHAPE MODEL, or are further away than 'max_distance'
% Also moves particles from r2,v2 to r,v if they were lifted at all

global rot_matrix bulk_density

%% Do collision check for all particles (r,v).
if size(r,1) ~= 0 
    plrad = sqrt(plarea./3.14); %radius the plates would have if they were circles
    max_elevation = max(plcenter(:,4)); %Maximum elevation of comet
    absr = sqrt(r(:,1).*r(:,1) + r(:,2).*r(:,2) + r(:,3).*r(:,3)); %particle distance
    greater_than_maxD = absr > max_distance;              %These particles are further away than maxD and will be killed
    coll_check = absr < max_elevation; % Do collision check for particles with distance < max_elevation
    r_cc   =   r(coll_check,:);
    v_cc   =   v(coll_check,:);
    SPI_cc = SPI(coll_check);
    dotp = zeros(size(r_cc,1),1);   %Contains dot product of position vector of particle relative to plcenter and plnorm
    cc_facetindex = zeros(size(r_cc,1),1); %Stores the index of the facet hit for redeposit monitoring
    for k=1:size(r_cc,1)
        r_bfix = rot_matrix.' * r_cc(k,1:3).';
        b = [ r_bfix(1) - plcenter(:,1), r_bfix(2) - plcenter(:,2), r_bfix(3) - plcenter(:,3)];
        b_abs = sqrt(b(:,1).*b(:,1) + b(:,2).*b(:,2) + b(:,3).*b(:,3));
        [~, i] = min(b_abs);
        dotp(k) = dot( b(i,1:3), plnorm(i,1:3));
        if dotp(k) < 0 
            b_rel = b_abs./plrad;
            [~, j] = min(b_rel);
            dotp(k) = dot( b(j,1:3), plnorm(j,1:3));
            cc_facetindex(k) = j;
        end
    end
    collided = dotp < 0;
    maintain = and(not(greater_than_maxD),not(coll_check));       %These particles will stay in the pool
    
    %% Add redeposit
    if size(r_cc,1) ~= 0 && any(collided) && etime > et_start_sav
        redepos_radi= (3/(4*bulk_density)) ./ r_cc(collided,4);
        redepos_mass = (bulk_density*4/3*3.14) .* redepos_radi.^3;
        redepos_MF   = v_cc(collided,4);
        cc_facetindex = cc_facetindex(collided);
        for i=1:size(cc_facetindex,1)
            if size_discrete == 0
                m_add = redepos_mass(i)*redepos_MF(i);
            else
                m_add = 1;
            end
            redepos_mtot(cc_facetindex(i)) = redepos_mtot(cc_facetindex(i)) + m_add;
        end
    end
    
    %% Update r, v, PSI
    r = [r(maintain,:) ; r_cc(not(collided),:)];
    v = [v(maintain,:) ; v_cc(not(collided),:)];
    SPI=[SPI(maintain) ; SPI_cc(not(collided))]; 
end