function [ states_jet ] = Save_States_Jet( states_jet, etime, r, v, jet_int)


if size(r,1) == 0
    return
end

time = repmat(etime,size(r,1),1);
states_jet(:,:,jet_int) = [r(:, 1:3), v(:, 1:3), time, r(:,4), v(:,4)];

end
    