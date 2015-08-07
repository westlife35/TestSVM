function cen_dep_diff = get_centralized_dep_diff(depth_, depth, mass_cen_, mass_cen)
    cen_dep_ = get_centralized_dep(depth_, mass_cen_);
    cen_dep = get_centralized_dep(depth, mass_cen);
    cen_dep_diff = abs(cen_dep_ - cen_dep);
end

function cen_dep = get_centralized_dep(depth, mass_cen)
    [h, w] = size(depth);
    cen_dep = zeros(h, w);
    h_2 = floor(min(mass_cen(2)-1, (h - mass_cen(2))));
    w_2 = floor(min(mass_cen(1)-1, (w - mass_cen(1))));
    if (h_2<1 || w_2<1 || h_2>480 || w_2>640)
        return;
    end
    idx = (depth~=0);
    depth(idx) =  depth(idx)- mass_cen(3);
%     fprintf('%d %d %d %d %d %d %f %f\n', size(depth,1), size(depth,2), h,w, h_2,w_2, mass_cen(1),mass_cen(2));
    cen_dep(floor(h/2)-h_2:floor(h/2)+h_2,floor(w/2)-w_2:floor(w/2)+w_2) = depth(mass_cen(2)-h_2:mass_cen(2)+h_2,mass_cen(1)-w_2:mass_cen(1)+w_2);
end