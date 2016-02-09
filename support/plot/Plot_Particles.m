function gdust = Plot_Particles( r1, v1, r2, v2 )
% Plots all particles. 
% Particles with escape velocity get a different color

global GM cmap
r = [r1 ; r2];
v = [v1 ; v2];

% Color according to mass:
% C_index = int32(((r(:,4)-min(r(:,4)))./(max(r(:,4))-min(r(:,4)))).^.5 .* (length(cmap)-1))+1;
% C = cmap(C_index,:);

% Color indicates escape velocity:
absr = sqrt(r(:,1).*r(:,1) + r(:,2).*r(:,2) + r(:,3).*r(:,3));
absv_2 = v(:,1).*v(:,1) + v(:,2).*v(:,2) + v(:,3).*v(:,3);
energy = absv_2./2 - GM./absr;
C = repmat([0 1 0],size(energy,1),1);
excape_index = energy > 0;
C(excape_index,1) = 1;
C(excape_index,2) = 0;
C(excape_index,3) = 1;

gdust = scatter3(r(:,1),r(:,2),r(:,3),20,'.g');
gdust.CData = C;

end

