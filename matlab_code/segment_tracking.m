function [tracking_label_id] = segment_tracking(depth, label, tracking_dat)
    %% find segmentation head location
    tracking_label_id = [];
    label_num = max(max(label));
    if (label_num==0)
        return;
    end
    real_head_loc_2D = zeros(label_num, 3);
    real_head_loc_3D = zeros(label_num, 3);
    for label_idx = 1:label_num
        [pr, pc] = find(label == label_idx);
        pr_idx = find(pc == floor(mean(pc)));
        min_r_id = pr_idx(floor(length(pr_idx)/2));
        real_head_loc_2D(label_idx, :) = [pc(min_r_id), pr(min_r_id), depth(pr(min_r_id), pc(min_r_id))];
        real_head_loc_3D(label_idx, :) = convert2Dto3D(real_head_loc_2D(label_idx, :));
    end
    %% find the nearest segmentation head location as the tracking segmentation
    for id_idx = 1:size(tracking_dat,1)
        id = tracking_dat(id_idx,1);
        head_loc_2D = tracking_dat(id_idx,2:4);
        head_loc_3D = convert2Dto3D(head_loc_2D);
        dis_3D = sqrt(sum((real_head_loc_3D(:,[1 3]) - repmat(head_loc_3D([1 3]), label_num, 1))'.^2));
        [min_dis_3D, tracking_label_id(id)] = min(dis_3D);
        if (min_dis_3D > 600)
            continue;
        end
    end
end
