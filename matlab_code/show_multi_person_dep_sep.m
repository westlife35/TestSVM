function show_multi_person_dep_sep( sub_dep, depth, tracking_dat, wait_sec )
    figure(1);
    imagesc(uint16(depth));
    hold on;
    if size(tracking_dat,1)>0
        for idx = 1:size(tracking_dat,1)
            alpha=0:pi/50:2*pi;
            x=10*cos(alpha)+tracking_dat(idx,2); 
            y=10*sin(alpha)+tracking_dat(idx,3); 
            plot(x,y,'Color','green','LineWidth',2);
        end
    end
    hold off;
    for idx = 1:size(sub_dep,1)
        figure(idx+1);
        imagesc(uint16(squeeze(sub_dep(idx,:,:))));
    end
    pause(wait_sec);
end

