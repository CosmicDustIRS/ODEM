function [r, v, SPI, dustProd_total] = Check_if_lifted( r, v, r2, v2, SPI, SPI2, plcenter, plnorm, dustProd_total, et_start_sav, etime)
% Removes particles from the pool that were spawned but not lifed.
% If a particle was spawned but the gas drag was not enough to lift it from
% the surface it (and therefore fell through the surface) it is removed 
% from the particle pool.

global rot_matrix bulk_density

n = size(r2,1);
if n ~= 0
    Update_RotMatrix( etime +5);
    r_bfix = zeros(n,3);
    for k=1:n
        r_bfix(k,:) = rot_matrix.' * r2(k,1:3).';
    end
    b = [ r_bfix(:,1) - plcenter(SPI2,1), r_bfix(:,2) - plcenter(SPI2,2), r_bfix(:,3) - plcenter(SPI2,3)];
    dotp = dot( b(:,1:3), plnorm(SPI2,1:3), 2);
    %These particles were lifted from the surface:
    lifted = dotp >= 0;
    
    % Add lifted particles to total dust production
    if etime > et_start_sav
        particle_radi = (3/(4*bulk_density)) ./r2(lifted,4);
        particle_mass = (bulk_density*4/3*3.14) .* particle_radi.^3;
        dustProd_total = dustProd_total + sum(particle_mass .* v2(lifted,4));
    end
    Update_RotMatrix( etime );
else                    
    lifted = [];    
end


%% Update r, v, PSI
r = [r ; r2(lifted,:)];
v = [v ; v2(lifted,:)];
SPI=[SPI ; SPI2(lifted)]; 