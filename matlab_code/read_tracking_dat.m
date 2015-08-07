function [ tracking_dat, cam2floor, floor2cam ] = read_tracking_dat( data_name )

%     cam2floor.r = [-0.99979234, -0.018359246, 0.0088331271; 8.2617407e-05, 0.42989978, 0.9028765; -0.02037338, 0.90268975, -0.42980909];
%     cam2floor.t = [0.1318779; -0.04429245; 2346.1162];
%     floor2cam.r = [-0.99979252, 8.2602593e-05, -0.020373497; -0.018359141, 0.42989993, 0.90269005; 0.0088330926, 0.90287662, -0.42980912];
%     floor2cam.t = [47.930447; -2117.7942; 1008.421];
    %% vio_wh data
    cam2floor.r = [-0.99573517, 0.079922311, -0.046084013; 9.6325894e-05, 0.50041866, 0.86578345; 0.092256881, 0.86208665, -0.49829221];
    cam2floor.t = [0.036659241; -0.010784149; 2570.9084];
    floor2cam.r = [-0.99573529, 9.6252406e-05, 0.09225674; 0.079922497, 0.50041878, 0.86208677; -0.046084035, 0.86578357, -0.49829227];
    floor2cam.t = [-237.14713; -2216.3438; 1281.0748];
    
    tracking_raw = importdata([data_name '.dat']);
    tracking_dat = {};
    for r_id = 1:length(tracking_raw)-1
        if (mod(r_id,2) == 1)
            tmp = sscanf(tracking_raw{r_id},'%d:%d');
            f_num = tmp(1);
            p_num = tmp(2);
        else
            tracking_dat{f_num} = zeros(p_num, 4);
            tmp = regexp(tracking_raw{r_id}, '] [', 'split');
            for c_id = 1:length(tmp)
                if isempty(tmp{c_id})
                    continue;
                end
                if c_id == 1
                    tmp{c_id} = strrep(tmp{c_id}, '[', '');
                end
                if c_id == length(tmp)
                    tmp{c_id} = strrep(tmp{c_id}, ']', '');
                end
                tmp2 = sscanf(tmp{c_id},'%f %f,%f,%f');
                tmp2(2:4) = floor2cam.r*tmp2(2:4) + floor2cam.t;
                tmp2(2:4) = convert3Dto2D(tmp2(2:4));
                tracking_dat{f_num}(c_id,:) = tmp2';
            end
        end
    end

end

