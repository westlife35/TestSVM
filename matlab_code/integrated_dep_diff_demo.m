function integrated_dep_diff_demo(file_path, label_path)

    run('vlfeat-0.9.20/toolbox/vl_setup.m');
    file_name = dir([file_path '/*.mat']);
    for i=1:length(file_name)
        tmp = regexp(file_name(i).name, '\.', 'split');
        data_path = [file_path '/' tmp{1}];
        if (exist(data_path)==7)
            fprintf('Pass %s\n', data_path);
            continue;
        end
        load([file_path '/' file_name(i).name]); % data
        load([label_path '/' file_name(i).name]); % data_label
        depth = data.depth;
        clear data;
        mkdir(data_path);
        avg_dep_diff = calc_avg_dep_diff( depth, data_label, 15, data_path );
    end
    
end

