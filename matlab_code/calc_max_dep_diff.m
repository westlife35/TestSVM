function [ max_dep_diff ] = calc_max_dep_diff( depth, time_int )

    max_dep_diff = {};
    n = length(depth);
    depth{1}(depth{1}~=0) = depth{1}(depth{1}~=0)-2600;
    prev_mass_cen = calc_mass_cen_2D( depth{1} );
    prev_dep_diff = zeros(time_int,size(depth{1},1),size(depth{1},2));
    for i=2:time_int+1
        depth{i}(depth{i}~=0) = depth{i}(depth{i}~=0)-2600;
        cur_mass_cen = calc_mass_cen_2D( depth{i} );
        prev_dep_diff(i-1,:,:) = get_centralized_dep_diff(depth{i}, depth{i-1}, cur_mass_cen, prev_mass_cen);
        prev_mass_cen = cur_mass_cen;
    end
    max_dep_diff{1} = squeeze(max(prev_dep_diff));
    for i=time_int+2:n
        depth{i}(depth{i}~=0) = depth{i}(depth{i}~=0)-2600;
        cur_mass_cen = calc_mass_cen_2D( depth{i} );
        cur_dep_diff = get_centralized_dep_diff(depth{i}, depth{i-1}, cur_mass_cen, prev_mass_cen);
        prev_dep_diff(1:end-1,:,:) = prev_dep_diff(2:end,:,:);
        prev_dep_diff(end,:,:) = cur_dep_diff;
        max_dep_diff{i-time_int} = squeeze(max(prev_dep_diff));
        prev_mass_cen = cur_mass_cen;
        show_dep_diff(max_dep_diff{i-time_int}, 0.3);
        [ bin_tot_val, tot_val ] = calc_vio_level( max_dep_diff{i-time_int} );
        fprintf('processing frame %d/%d bin_vio_val = %f vio_val = %f\n', i, n, bin_tot_val, tot_val);
    end

end
