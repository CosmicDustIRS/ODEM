function [r, v] = RK4( r, v, dt , nodes_pos, nodes_norm)
% This is the RungeKutta4 integration routine.

global rot_vector rad_per_sec
if size(r,1) == 0
    return
end

dt1 = repmat([dt,dt,dt,0],size(r,1),1);
dt2 = dt1./2;
rot_nodes_halfstep = cspice_axisar(rot_vector, dt/2*rad_per_sec);

%- Perform RK4 step ------------------------------------------------%
k_vel_1 = v;                                                        %
k_acc_1 = calc_accel(r, nodes_pos, nodes_norm);                     % Step 1
%--------------------------------------------------------------------------------------------
for i=1:size(nodes_pos,1)                                           % Apply small rotation to
    nodes_pos(i,1:3) = rot_nodes_halfstep * nodes_pos(i,1:3).';     % the nodes to account for 
    nodes_norm(i,1:3) = rot_nodes_halfstep * nodes_norm(i,1:3).';   % comet rotation between
end                                                                 % RK step 1 and 2/3
r2 = r + k_vel_1 .* dt2;                                            % 
k_vel_2 = v + k_acc_1 .* dt2;                                       %
k_acc_2 = calc_accel(r2, nodes_pos, nodes_norm);                    % Step 2
%--------------------------------------------------------------------------------------------
r2 = r + k_vel_2 .* dt2;                                            %
k_vel_3 = v + k_acc_2 .* dt2;                                       %
k_acc_3 = calc_accel (r2, nodes_pos, nodes_norm);                   % Step 3
%--------------------------------------------------------------------------------------------
for i=1:size(nodes_pos,1)                                           % Apply small rotation to
    nodes_pos(i,1:3) = rot_nodes_halfstep * nodes_pos(i,1:3).';     % the nodes to account for
    nodes_norm(i,1:3) = rot_nodes_halfstep * nodes_norm(i,1:3).';   % comet rotation between 
end                                                                 % RK step 2/3 and 4
r2 = r + k_vel_3 .* dt1;                                             %
k_vel_4 = v + k_acc_3 .* dt1;                                        %
k_acc_4 = calc_accel(r2, nodes_pos, nodes_norm);                    % Step 4
%--------------------------------------------------------------------------------------------
%- Update Solution -------------------------------------------------%
r = r + dt1 .* (k_vel_1 + 2.*k_vel_2 + 2.*k_vel_3 + k_vel_4) ./ 6;
v = v + dt1 .* (k_acc_1 + 2.*k_acc_2 + 2.*k_acc_3 + k_acc_4) ./ 6;
end





function accel = calc_accel( r, nodes_pos, nodes_norm)
% Calculates acceleration for every particle based on their positions
n = size(r,1);

% Gravity:
accel = Gravity_Duck(r,n);

% Gas drag:
for i=1:size(nodes_pos, 1)
    b = [ r(:,1) - nodes_pos(i,1), r(:,2) - nodes_pos(i,2), r(:,3) - nodes_pos(i,3)];
    b_abs_2 = b(:,1).*b(:,1) + b(:,2).*b(:,2) + b(:,3).*b(:,3);
    b_abs = sqrt(b_abs_2);
    dot_prod = b(:,1).*nodes_norm(i,1) + b(:,2).*nodes_norm(i,2) + b(:,3).*nodes_norm(i,3);
    dot_prod = dot_prod./b_abs;
    dot_prod(isnan(dot_prod)) = 1;
    dot_prod = max(dot_prod, 0);
    close_index = b_abs < sqrt(nodes_pos(i,4));
    dot_prod(close_index) = 1;
    b_abs_2(close_index) = nodes_pos(i,4);
    b(close_index,1) = nodes_norm(i,1);
    b(close_index,2) = nodes_norm(i,2);
    b(close_index,3) = nodes_norm(i,3);
    b_abs(close_index) = 1;
    
    geom_factor = nodes_pos(i,4) ./ b_abs_2 .* dot_prod  ./ b_abs;
    gas_drag_0 = r(:,4) .* nodes_norm(i,4);
    gas_drag = gas_drag_0 .* geom_factor;
    accel = accel + [gas_drag .* b(:,1), gas_drag .* b(:,2), gas_drag .* b(:,3),  zeros(n,1)];
end
end

function g = Gravity_Duck(r, n)
global rot_matrix

% Big body:
b = rot_matrix * [-0.42; 0.26; -0.06] *1000;        % mass center coordinates of big body
GMb = 7.43e12 * 6.674e-11;                          % GM of big body
rb = r - repmat([b;0]',n,1);
absr = sqrt(rb(:,1).*rb(:,1) + rb(:,2).*rb(:,2) + rb(:,3).*rb(:,3));
r3 = absr.*absr.*absr;
GMr3 = -GMb ./ r3;
accel_1 = [ rb(:,1) .* GMr3,  rb(:,2) .* GMr3,  rb(:,3) .* GMr3, zeros(n,1)];

% Small body:
s = rot_matrix * [1.48; -0.34; -0.25] *1000;        % mass center coordinates of small body
GMs = 2.68e12 * 6.674e-11;                          % GM of small body
rs = r - repmat([s;0]',n,1);
absr = sqrt(rs(:,1).*rs(:,1) + rs(:,2).*rs(:,2) + rs(:,3).*rs(:,3));
r3 = absr.*absr.*absr;
r3 = max(r3, 1e9);
GMr3 = -GMs ./ r3;
accel_2 = [ rs(:,1) .* GMr3,  rs(:,2) .* GMr3,  rs(:,3) .* GMr3, zeros(n,1)];

% Sum
g = accel_1 + accel_2;

end

function g = Gravity_Sphere(r, n)
global GM
% Gravity:
absr = sqrt(r(:,1).*r(:,1) + r(:,2).*r(:,2) + r(:,3).*r(:,3));
r3 = absr.*absr.*absr;
r3 = max(r3, 8e9);
GMr3 = -GM ./ r3;
g = [ r(:,1) .* GMr3,  r(:,2) .* GMr3,  r(:,3) .* GMr3, zeros(n,1)];

end









