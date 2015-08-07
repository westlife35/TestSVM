function segment_tracking_demo( file_id )
    addpath('../dataset/20140714_demo_room/tracking_data/');
    addpath('../dataset/20140714_demo_room/mat_data/'); %mat_data/
    all_data_name = {'testing_group1_abnormal'};
    %% read tracking data
    [ tracking_dat, cam2floor, floor2cam ] = read_tracking_dat(all_data_name{file_id});
    %% test each video clips
    base_idx = 0;
    for file_sub_id = 1:5
        file_name = sprintf('%s_%d.mat', all_data_name{file_id}, file_sub_id);
        if exist(file_name)~=2
            continue;
        end
        load(file_name);      %data
        depth = data.depth;
        label = data.label;
        clear data;
        for f_id = 1:length(depth)
            depth{f_id}(label{f_id}==0) = 0;
            [tracking_label_id] = segment_tracking(depth{f_id}, label{f_id}, tracking_dat{f_id+base_idx});
            sub_dep = segment_depth( depth{f_id}, label{f_id}, tracking_label_id );
            show_multi_person_dep_sep( sub_dep, depth{f_id}, tracking_dat{f_id+base_idx}, 0.01 );
        end
        base_idx = base_idx+length(depth);
    end
end
