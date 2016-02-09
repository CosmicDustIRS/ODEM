function [r, v, r2, v2] = Kill_Particles_Duck( r, v, r2, v2, plcenter, plnorm)
% This function deletes all particles from the pool that are INSIDE THE
% SHAPE MODEL, or are further away than 'max_distance'
% Also moves particles between r,v and r2,v2 (far space and nearby space)

global max_distance substep_distance rot_matrix bulk_density redepos_mtot
r2_cc = [];
v2_cc = [];
max_elevation = max(plcenter(:,4));                                 % maximum elevation of comet
absr2 = sqrt(r2(:,1).*r2(:,1) + r2(:,2).*r2(:,2) + r2(:,3).*r2(:,3));% particle distance (nearby)

%% Far space
if size(r,1) ~= 0 
    absr = sqrt(r(:,1).*r(:,1) + r(:,2).*r(:,2) + r(:,3).*r(:,3));      % particle distance
    greater_than_maxD = absr > max_distance;                    % These particles are further away than maxD and will be killed
    move_to_nearby = absr < substep_distance;                   % These particles will be moved to the nearby space arrays (r2, v2)
    no_kill_far = and(not(greater_than_maxD), not(move_to_nearby));%ese particles remain in far space
else
    move_to_nearby = [];
    no_kill_far = [];
end

%% Nearby space
cc_facetindex = zeros(size(r2_cc,1),1);
if size(r2,1) ~= 0
    % Do collision check for particles with distance < max_elevation
    coll_check = absr2 < max_elevation;
    r2_cc = r2(coll_check,:);
    v2_cc = v2(coll_check,:);
    dotp = zeros(size(r2_cc,1),1);
    for k=1:size(r2_cc,1)
        r_bfix = rot_matrix.' * r2_cc(k,1:3).';
        b = [ r_bfix(1) - plcenter(:,1), r_bfix(2) - plcenter(:,2), r_bfix(3) - plcenter(:,3)];
        b_abs = sqrt(b(:,1).*b(:,1) + b(:,2).*b(:,2) + b(:,3).*b(:,3));
        [~, i] = min(b_abs);
        dotp(k) = dot( b(i,1:3), plnorm(i,1:3));   
        cc_facetindex(k) = i; % This vector stores the index of the nearest facet for redepositiong studies
    end
    outside_shape = dotp > 0;                                   % These particles are below max_elev. but not inside the comet
    move_to_far = absr2 > substep_distance;                     % These particles will be moved to the far space arrays (r, v)
    no_kill_nearby = and(not(coll_check), not(move_to_far));    % These particles are above max_elev. but below substep_distance
else
    outside_shape = [];
    move_to_far = [];
    no_kill_nearby = [];
end

%% Update r, v, r2, v2
r2_move_to_far = r2(move_to_far,:); 
v2_move_to_far = v2(move_to_far,:);

r2 = [r2(no_kill_nearby,:) ; r2_cc(outside_shape,:) ; r(move_to_nearby,:)];
v2 = [v2(no_kill_nearby,:) ; v2_cc(outside_shape,:) ; v(move_to_nearby,:)];

r = [r(no_kill_far,:) ; r2_move_to_far];
v = [v(no_kill_far,:) ; v2_move_to_far];

% Redepositioning study
if size(r2_cc,1) ~= 0 && any(~outside_shape)
    redepos_cstmr= r2_cc(~outside_shape,4);
    redepos_mass = (9*3.14/(16*bulk_density^2)) ./ redepos_cstmr.^3;
    redepos_MF   = v2_cc(~outside_shape,4);
    cc_facetindex = cc_facetindex(~outside_shape);
    for i=1:size(cc_facetindex,2)
        findex = cc_facetindex(i);
        m_add = redepos_mass(i)*redepos_MF(i);
        if m_add == 0 
            if redepos_mass(i) == 0
                display('mass')
                display(redepos_cstmr(i))
            elseif redepos_MF(i) == 0
                display('MF')
            else
                display('hmmm')
            end
        end
        redepos_mtot(findex) = redepos_mtot(findex) + m_add;
    end
end

