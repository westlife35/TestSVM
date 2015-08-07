function show_dep_diff( dep_diff, wait_sec, i, data_path )
    dep_diff_feat = extract_HOG( dep_diff )';
    save(sprintf('%s/%06d_1.mat', data_path, i),'dep_diff_feat');
    
%     figure(1);
%     imagesc(uint16(dep_diff));
%     saveas(gcf,sprintf('%s/%06d_1.jpg', data_path, i));
    
    dep_diff = dep_diff(:,end:-1:1);
    dep_diff_feat = extract_HOG( dep_diff )';
    save(sprintf('%s/%06d_2.mat', data_path, i),'dep_diff_feat');
    
%     figure(2);
%     imagesc(uint16(dep_diff));
%     saveas(gcf,sprintf('%s/%06d_2.jpg', data_path, i));
%     
%     pause(wait_sec);
end

