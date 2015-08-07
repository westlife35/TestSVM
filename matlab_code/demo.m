function demo(data_path)
    data_name = dir([data_path '*.mat']);
    for idx = 1:length(data_name)
        load([data_path data_name(idx).name]);
        data = data.depth;
        n = length(data);
        for file_idx = 1:n
            fprintf('%d/%d\n',file_idx,n);
            depth = data{file_idx};
%             point_cloud = data.point_cloud{file_idx};
            point_cloud = [];
            show_dep(depth, point_cloud, 0.033);
        end
        clear data;
    end
    
end