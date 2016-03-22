function [ states_leave ] = Save_States_GTMAX( states_leave, etime, r, v, PSI, max_distance)
% This function checks if particles leave the max_distance sphere (e.g.
% 20km) and saves their states.

if size(r,1) == 0
    return
end

absr_2 = r(:,1).*r(:,1) + r(:,2).*r(:,2) + r(:,3).*r(:,3);
max_d_2 = max_distance*max_distance;

farther_than_maxD = absr_2 > max_d_2;
if any(farther_than_maxD)
    r_save = r(farther_than_maxD,:);
    v_save = v(farther_than_maxD,:);
    PSI_save = PSI(farther_than_maxD,:);
    time = repmat(etime,size(r_save,1),1);
    states_leave_new = [r_save(:, 1:3), v_save(:,1:3), time, r_save(:, 4), v_save(:,4), PSI_save];
    states_leave = [states_leave; states_leave_new];
end

