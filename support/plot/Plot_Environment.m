function [gSunDir, gRot, gTerm, gSun] = Plot_Environment( sun_dir)
% This function plots some lines and the terminator plane

global nucls_rad rot_matrix

% Create light source (Also known as 'Sun')
gSun = light('Position', sun_dir, 'Style', 'infinite');
    
% Plot subsolar point
sun_dir = sun_dir * (3*nucls_rad);
gSunDir = plot3([0, sun_dir(1)], [0, sun_dir(2)], [0, sun_dir(3)], 'r', 'LineWidth', 2);

% Plot rotation axis
w = rot_matrix * [0; 0; 3*nucls_rad];
gRot = plot3([-w(1), w(1)], [-w(2), w(2)], [-w(3), w(3)], 'b', 'LineWidth', 2);

% Plot terminator plane
vec1 = [-sun_dir(2) sun_dir(1) 0];
vec2 = [-sun_dir(3)*sun_dir(1)/(sun_dir(1)*sun_dir(1)+sun_dir(2)*sun_dir(2)) ...
        -sun_dir(3)*sun_dir(2)/(sun_dir(1)*sun_dir(1)+sun_dir(2)*sun_dir(2)) ...
        1];
vec1 = vec1/norm(vec1) * (3*nucls_rad);        
vec2 = vec2/norm(vec2) * (3*nucls_rad);
gTerm = patch([-vec1(1)-vec2(1), -vec1(1)+vec2(1), vec1(1)+vec2(1), vec1(1)-vec2(1)],...
              [-vec1(2)-vec2(2), -vec1(2)+vec2(2), vec1(2)+vec2(2), vec1(2)-vec2(2)],...
              [-vec1(3)-vec2(3), -vec1(3)+vec2(3), vec1(3)+vec2(3), vec1(3)-vec2(3)],...
              [.6,.6,.6], 'FaceAlpha', .2, 'EdgeColor', 'none');
