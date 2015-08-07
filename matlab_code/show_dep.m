function show_dep( depth, point_cloud, wait_sec )
%     depth(depth>4000) = 0;
    depth(depth~=0) = depth(depth~=0)-2600;
%     fg_idxs = find(point_cloud(:,3)<4000);
%     point_cloud = point_cloud(fg_idxs,:);
    figure(1);
    imagesc(uint16(depth));
    
%     if (~isempty(point_cloud))
%         point_cloud = x_rotate(point_cloud,40);
%         point_cloud = y_rotate(point_cloud,45);
%         figure(2);
%         scatter3(point_cloud(:,1), point_cloud(:,3), point_cloud(:,2), 'fill', 'LineWidth', 1);
%     end

    pause(wait_sec);
end
