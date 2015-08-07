function sub_dep = segment_depth( depth, label, tracking_label_id, last_sub_dep_num )
    [h, w] = size(depth);
    id_num = length(tracking_label_id);
    sub_dep = zeros(max(last_sub_dep_num, id_num), h, w);
    for idx = 1:id_num
        tmp = depth;
        tmp(label~=tracking_label_id(idx)) = 0;
        sub_dep(idx, :, :) = tmp;
    end
end
