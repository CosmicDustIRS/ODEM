function gbody = Plot_Duck_Shadow_ST( p, v, np, nv, plcenter, plnorm, shape_handle, sun_dir )
% This function plots the comet with shadow. (single threaded, therefore
% slower)

global rot_matrix dladsc

sun_bfix = rot_matrix.' * sun_dir;
for i=1:np
    plnorm(i,1:3) = rot_matrix * plnorm(i,1:3).';
    if dot(plnorm(i,1:3), sun_dir) > 0
        [~,~,found] = cspice_dskx02(shape_handle, dladsc, plcenter(i,1:3).'/1000, sun_bfix);
        if found
            plnorm(i,1:3) = -sun_dir;
        end
    end
end

for i=1:nv
    v(1:3, i) = rot_matrix * v(1:3,i);
end
X=[v(1,p(1,:)); v(1,p(2,:)); v(1,p(3,:))];
Y=[v(2,p(1,:)); v(2,p(2,:)); v(2,p(3,:))];
Z=[v(3,p(1,:)); v(3,p(2,:)); v(3,p(3,:))];
C = ones(3,np); 

gbody = patch(X,Y,Z,C, 'FaceLighting', 'flat', ...'BackFaceLighting', 'unlit',...
    'AmbientStrength', 0.1, 'DiffuseStrength', .9, 'LineStyle', 'none',...
    'FaceNormals', -plnorm,  'FaceColor', [.6 .6 .6]);
end
