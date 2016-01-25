function gbody = Plot_Duck_Shadow( p, v, np, nv, plcenter, plnorm, file_path, sun_dir )
% This function plots the comet with shadow.

global rot_matrix

RotM_par = rot_matrix;
sun_bfix = rot_matrix.' * sun_dir;

spmd
    shape_handle = cspice_dasopr(file_path);
    dladsc_par = cspice_dlabfs(shape_handle);
    plnorm_par = codistributed(plnorm,codistributor1d(1)); % Array spread across the workers
    plnorm_local = getLocalPart( plnorm_par ); % The underlying "local part"
    gI = globalIndices( plnorm_par, 1 ); % Which rows in the global array do we have?
    for i = 1:length( gI )
        plnorm_local(i,:) = RotM_par * plnorm_local(i,:).';
        if dot(plnorm_local(i,:), sun_dir) > 0
        [~,~,found] = cspice_dskx02(shape_handle, dladsc_par, plcenter(gI(i),1:3).'/1000, sun_bfix);
            if found
                plnorm_local(i,:) = -sun_dir;
            end
        end
    end
    % We've modified the local part; we need to put it back together
    plnorm_par = codistributed.build( plnorm_local, getCodistributor( plnorm_par ) );
end


for i=1:nv
    v(1:3, i) = rot_matrix * v(1:3,i);
end
X=[v(1,p(1,:)); v(1,p(2,:)); v(1,p(3,:))];
Y=[v(2,p(1,:)); v(2,p(2,:)); v(2,p(3,:))];
Z=[v(3,p(1,:)); v(3,p(2,:)); v(3,p(3,:))];
C = ones(3,np); 

gbody = patch(X,Y,Z,C, 'FaceLighting', 'flat', ...'BackFaceLighting', 'unlit',...
    'AmbientStrength', 0.1, 'DiffuseStrength', .2, 'LineStyle', 'none',...
    'FaceNormals', -plnorm_par,  'FaceColor', [.6 .6 .6]);
end

%SINGLETHREAD
% sun_bfix = rot_matrix.' * sun_dir;
% for i=1:np
%     plnorm(i,1:3) = rot_matrix * plnorm(i,1:3).';
%     if dot(plnorm(i,1:3), sun_dir) > 0
%         [~,~,found] = cspice_dskx02(shape_handle, dladsc, plcenter(i,1:3).'/1000, sun_bfix);
%         if found
%             plnorm(i,1:3) = -sun_dir;
%         end
%     end
% end
