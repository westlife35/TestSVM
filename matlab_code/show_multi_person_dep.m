function show_multi_person_dep( depth, wait_sec, tracking_dat )
    color = {'red', 'blue', 'green', 'yellow', 'black', 'white', 'magenta', 'cyan'};
    figure(1);
    imagesc(uint16(depth));
    hold on;
    if size(tracking_dat,1)>0
        for idx = 1:size(tracking_dat,1)
            color_id = mod(tracking_dat(idx,1),8)+1;
            alpha=0:pi/50:2*pi;
            x=10*cos(alpha)+tracking_dat(idx,2); 
            y=10*sin(alpha)+tracking_dat(idx,3); 
            plot(x,y,'Color',color{color_id},'LineWidth',5);
        end
    end
    hold off;
%     if (~isempty(point_cloud))
%         point_cloud = x_rotate(point_cloud,40);
%         point_cloud = y_rotate(point_cloud,45);
%         figure(2);
%         scatter3(point_cloud(:,1), point_cloud(:,3), point_cloud(:,2), 'fill', 'LineWidth', 1);
%     end
%     pause(wait_sec);
end

