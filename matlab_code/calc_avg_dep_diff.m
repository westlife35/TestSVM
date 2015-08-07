function [ avg_dep_diff ] = calc_avg_dep_diff( depth, data_label, time_int, data_path )

    avg_dep_diff = {};
    tot_dep_diff = zeros(size(depth{1}));
    n = length(depth);
    depth{1}(depth{1}~=0) = depth{1}(depth{1}~=0)-2600;
    prev_mass_cen = calc_mass_cen_2D( depth{1} );
    prev_dep_diff = zeros(time_int,size(depth{1},1),size(depth{1},2));
    for i=2:time_int+1
        depth{i}(depth{i}~=0) = depth{i}(depth{i}~=0)-2600;
        cur_mass_cen = calc_mass_cen_2D( depth{i} );
        prev_dep_diff(i-1,:,:) = get_centralized_dep_diff(depth{i}, depth{i-1}, cur_mass_cen, prev_mass_cen);
        tot_dep_diff = tot_dep_diff + squeeze(prev_dep_diff(i-1,:,:));
        prev_mass_cen = cur_mass_cen;
    end
    avg_dep_diff{1} = tot_dep_diff / time_int;
    for i=time_int+2:n
        depth{i}(depth{i}~=0) = depth{i}(depth{i}~=0)-2600;
        cur_mass_cen = calc_mass_cen_2D( depth{i} );
        cur_dep_diff = get_centralized_dep_diff(depth{i}, depth{i-1}, cur_mass_cen, prev_mass_cen);
        tot_dep_diff = tot_dep_diff + cur_dep_diff - squeeze(prev_dep_diff(1,:,:));
        avg_dep_diff{i-time_int} = tot_dep_diff / time_int;
        prev_dep_diff(1:end-1,:,:) = prev_dep_diff(2:end,:,:);
        prev_dep_diff(end,:,:) = cur_dep_diff;
        prev_mass_cen = cur_mass_cen;
        if (data_label(i) == true)
            show_dep_diff(avg_dep_diff{i-time_int}, 0.01, i, data_path);
        end
%         [ bin_tot_val, tot_val ] = calc_vio_level( avg_dep_diff{i-time_int} );
%         fprintf('processing frame %d/%d bin_vio_val = %f vio_val = %f\n', i, n, bin_tot_val, tot_val);
        fprintf('processing frame %d/%d\n', i, n);
    end

end
