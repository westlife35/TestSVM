function test_multi_person_violence( test_fold_id, file_id, is_debug_mode )
	%% set test data fold
    if (test_fold_id == 1)
        test_fold = '/home/haoquan/HardDisk/dataset/20150423_dance_vio_for_valse_demo_use/';
    elseif (test_fold_id == 2)
        test_fold = '/home/haoquan/HardDisk/dataset/20150427_dance_vio_for_valse_demo_use/';
    end
    %% set model path
    svm_model_path = '/home/haoquan/workspace/dataset/vio_wav_action_dataset/train_svm_model2_fine.mat';
    %% set path
    addpath('libsvm-3.20/matlab');
    addpath('liblinear-1.96/matlab');
    run('vlfeat-0.9.20/toolbox/vl_setup.m');
    addpath([test_fold 'xml_data/']);
    addpath([test_fold 'tracking_data/']);
    addpath([test_fold 'mat_data/']);
    tmp = dir([test_fold 'tracking_data/*.dat']);
    all_data_name = cell(1, length(tmp));
    for i = 1:length(tmp)
        tmp2 = regexp(tmp(i).name, '\.', 'split');
        all_data_name{i} = tmp2(1);
    end
    if is_debug_mode
        mkdir([test_fold 'result/']);
        mkdir([test_fold 'result/' all_data_name{file_id}]);
    end
    %% read tracking data
    [tracking_dat, cam2floor, floor2cam] = read_tracking_dat(all_data_name{file_id});
    load(svm_model_path);
    %% test each video clips
    base_idx = 0;
    sub_dep = [];
    pre_depth = [];
    prev_dep_diff = [];
    tot_dep_diff = [];
    prev_mass_cen = [];
    p_id_tot_frm = [];
    action_conf = [];
    for file_sub_id = 1:10
        %% load data
        file_name = sprintf('%s_%d.mat', all_data_name{file_id}, file_sub_id);
        if exist(file_name)~=2
            continue;
        end
        load(file_name);
        depth = data.depth;
        label = data.label;
        clear data;
        %% process each frame
        for f_id = 1:length(depth)
            fprintf('file_id = %d frame_id = %d id_num = %d\n', file_sub_id, f_id, size(sub_dep,1));
            depth{f_id}(label{f_id} == 0) = 0;
            if (f_id+base_idx>length(tracking_dat))
                break;
            end
            % segment and track each person
            [tracking_label_id] = segment_tracking(depth{f_id}, label{f_id}, tracking_dat{f_id+base_idx});
            last_sub_dep_num = size(sub_dep,1);
            sub_dep = segment_depth( depth{f_id}, label{f_id}, tracking_label_id, last_sub_dep_num );
            % process the data of each person
            for p_id = 1:size(sub_dep,1)
                [ action_conf, pre_depth, prev_dep_diff, tot_dep_diff, prev_mass_cen, p_id_tot_frm ] = update_sgl_frm(best_svm_model, squeeze(sub_dep(p_id,:,:)), pre_depth, prev_dep_diff, tot_dep_diff, prev_mass_cen, p_id_tot_frm, p_id, action_conf);
            end
            rgb_img = imread(sprintf('%s/xml_data/%s/%06d.jpg', test_fold, all_data_name{file_id}, f_id+base_idx));
            calc_show_vio(depth{f_id}, rgb_img, tot_dep_diff, sub_dep, action_conf, p_id_tot_frm, 0.01, test_fold, all_data_name{file_id}, f_id+base_idx, cam2floor, floor2cam);
        end
        base_idx = base_idx+length(depth);
    end
end

function [ action_conf, pre_depth, prev_dep_diff, tot_dep_diff, prev_mass_cen, p_id_tot_frm ] = update_sgl_frm(best_svm_model, cur_depth, pre_depth, prev_dep_diff, tot_dep_diff, prev_mass_cen, p_id_tot_frm, p_id, action_conf)
    %% set parameters
    time_int = 15;
    check_time_span = 70;
    tot_p_id = length(p_id_tot_frm);
    is_cur_frm_ava = sum(sum(cur_depth~=0));
    [h, w] = size(cur_depth);
    %% process one frame
    if isempty(p_id_tot_frm) || isempty(prev_mass_cen) || isempty(pre_depth) || isempty(prev_dep_diff) || isempty(tot_dep_diff) || isempty(action_conf)
        p_id_tot_frm = zeros(p_id, 1);
        prev_mass_cen = zeros(p_id, 3);
        if (is_cur_frm_ava>0)
            prev_mass_cen(p_id, :) = calc_mass_cen_2D( cur_depth )';
        end
        pre_depth = zeros(p_id, size(cur_depth,1), size(cur_depth,2));
        prev_dep_diff = zeros(p_id, time_int, h, w);
        tot_dep_diff = zeros(p_id, h, w);
        action_conf = zeros(p_id, 3, check_time_span);
    else
        if (p_id > tot_p_id)
            p_id_tot_frm(p_id) = 0;
            prev_mass_cen(p_id,:) = zeros(1, 3);
            pre_depth(p_id,:,:) = zeros(size(cur_depth));
            size(prev_dep_diff)
            prev_dep_diff(p_id,:,:,:) = zeros(time_int, h, w);
            tot_dep_diff(p_id,:,:) = zeros(h, w);
            action_conf(p_id,:,:) = zeros(3, check_time_span);
        end
        is_pre_frm_ava = sum(sum(squeeze(pre_depth(p_id,:,:))~=0));
        if (is_cur_frm_ava==0) || (is_pre_frm_ava==0)
            prev_dep_diff(p_id,1:end-1,:,:) = prev_dep_diff(p_id,2:end,:,:);
            prev_dep_diff(p_id,end,:,:) = zeros(h,w);
            if (is_cur_frm_ava>0)
                prev_mass_cen(p_id, :) = calc_mass_cen_2D( cur_depth )';
            else
                prev_mass_cen(p_id,:) = zeros(1,3);
            end
            action_conf(p_id,:,1:end-1) = action_conf(p_id,:,2:end);
            action_conf(p_id,:,end) = 0;
            p_id_tot_frm(p_id) = 0;
        elseif (p_id > tot_p_id) || (p_id_tot_frm(p_id) < time_int)
            p_id_tot_frm(p_id) = p_id_tot_frm(p_id)+1;
            cur_mass_cen = calc_mass_cen_2D( cur_depth )';
            prev_dep_diff(p_id,p_id_tot_frm(p_id),:,:) = get_centralized_dep_diff(cur_depth, squeeze(pre_depth(p_id,:,:)), cur_mass_cen, squeeze(prev_mass_cen(p_id,:)));
            tot_dep_diff(p_id,:,:) = squeeze(tot_dep_diff(p_id,:,:)) + squeeze(prev_dep_diff(p_id,p_id_tot_frm(p_id),:,:));
            prev_mass_cen(p_id,:) = cur_mass_cen;
        else
            cur_mass_cen = calc_mass_cen_2D( cur_depth )';
            cur_dep_diff = get_centralized_dep_diff(cur_depth, squeeze(pre_depth(p_id,:,:)), cur_mass_cen, squeeze(prev_mass_cen(p_id,:)));
            tot_dep_diff(p_id,:,:) = squeeze(tot_dep_diff(p_id,:,:)) + cur_dep_diff - squeeze(prev_dep_diff(p_id,1,:,:));
            avg_dep_diff = squeeze(tot_dep_diff(p_id,:,:)) / time_int;
            prev_dep_diff(p_id,1:end-1,:,:) = squeeze(prev_dep_diff(p_id,2:end,:,:));
            prev_dep_diff(p_id,end,:,:) = cur_dep_diff;
            prev_mass_cen(p_id,:) = cur_mass_cen;
            hog_feat = extract_HOG( avg_dep_diff );
            hog_feat = hog_feat';
            [predict_class, ~] = SVM_predict(hog_feat, best_svm_model);
            action_conf(p_id,:,1:end-1) = squeeze(action_conf(p_id,:,2:end));
            action_conf(p_id,:,end) = 0;
            action_conf(p_id,predict_class,end) = 1;
        end
    end
    pre_depth(p_id,:,:) = cur_depth;
end

function calc_show_vio(out_dep, rgb_img, tot_dep_diff, sub_dep, action_conf, p_id_tot_frm, wait_sec, test_fold, data_name, f_id, cam2floor, floor2cam)
    %% set parameters
    time_int = 15;
    last_time_thr = 52;
    %% check whether the vote of one class is larger than threshold
    [h, w] = size(out_dep);
    p_num = size(action_conf, 1);
    avg_dep_diff = zeros(p_num, h, w);
    action_conf = squeeze(sum(action_conf, 3));
    for p_id = 1:p_num
        avg_dep_diff(p_id,:,:) = squeeze(tot_dep_diff(p_id,:,:)) / time_int;
    end
    for p_id = 1:p_num
        action = (action_conf(p_id,:)>last_time_thr);
        if (sum(action)>0)
            action_id = find(action>0);
            for i=1:length(action_id)
                if (action_id(i)==1)
%                     g_img = squeeze(rgb_img(:,:,2));
%                     g_img(sub_dep(p_id,:,:)>0) = g_img(sub_dep(p_id,:,:)>0) + 100;
%                     g_img = min(255,g_img);
%                     rgb_img(:,:,2) = g_img;
%                     [tmp_y, tmp_x] = find(squeeze(sub_dep(p_id,:,:))>0);
%                     tmp_x_base = mean(tmp_x);
%                     [tmp_y, tmp_x] = find(squeeze(sub_dep(p_id,:,tmp_x_base-10:tmp_x_base+10))>0);
%                     tmp_x = tmp_x + tmp_x_base;
%                     rgb_img = draw_tag( rgb_img, 1, [min(tmp_x) min(tmp_y)] );
                    avg_dep_diff(p_id,end-50:end,1:200) = 50;
                elseif (action_id(i)==2)
                    mid = size(out_dep,2)/2;
%                     r_img = squeeze(rgb_img(:,:,1));
%                     r_img(sub_dep(p_id,:,:)>0) = r_img(sub_dep(p_id,:,:)>0) + 100;
%                     r_img = min(255,r_img);
%                     rgb_img(:,:,1) = r_img;
                    [tmp_y, tmp_x] = find(squeeze(sub_dep(p_id,:,:))>0);
                    [~, idx] = min(tmp_y);
                    pnt_2D = [tmp_x(idx) tmp_y(idx) sub_dep(p_id,tmp_y(idx),tmp_x(idx))];
                    if (isempty(pnt_2D))
                        continue;
                    end
                    pnt_3D = convert2Dto3D(pnt_2D);
                    pnt_pln = (cam2floor.r*pnt_3D'+cam2floor.t)';
                    if (pnt_pln(3)<1500)                %do not report if the height is less than 1.5m
                        continue;
                    end
%                     if (action_conf(p_id,i)<last_time_thr+7)
%                         continue;
%                     end
                    tmp_x_base = mean(tmp_x);
                    [tmp_y, tmp_x] = find(squeeze(sub_dep(p_id,:,tmp_x_base-3:tmp_x_base+3))>0);
                    tmp_x = floor(tmp_x + tmp_x_base);
                    [~, idx] = min(tmp_y);
                    pnt_2D = [tmp_x(idx) tmp_y(idx) sub_dep(p_id,tmp_y(idx),tmp_x(idx))];
                    pnt_3D = convert2Dto3D(pnt_2D);
                    pnt_pln = (cam2floor.r*pnt_3D'+cam2floor.t)';
                    pnt_pln(3) = 1800;
                    pnt_3D = (floor2cam.r*pnt_pln'+floor2cam.t)';
                    pnt_2D = convert3Dto2D(pnt_3D);
                    rgb_img = draw_tag( rgb_img, 2, [tmp_x_base pnt_2D(2)] );
                    avg_dep_diff(p_id,end-50:end,mid-100:mid+100) = 50;
                else
%                     b_img = squeeze(rgb_img(:,:,3));
%                     b_img(sub_dep(p_id,:,:)>0) = b_img(sub_dep(p_id,:,:)>0) + 100;
%                     b_img = min(255,b_img);
%                     rgb_img(:,:,3) = b_img;
                    [tmp_y, tmp_x] = find(squeeze(sub_dep(p_id,:,:))>0);
                    tmp_x_base = mean(tmp_x);
                    [tmp_y, tmp_x] = find(squeeze(sub_dep(p_id,:,tmp_x_base-3:tmp_x_base+3))>0);
                    tmp_x = floor(tmp_x + tmp_x_base);
                    [~, idx] = min(tmp_y);
                    pnt_2D = [tmp_x(idx) tmp_y(idx) sub_dep(p_id,tmp_y(idx),tmp_x(idx))];
                    pnt_3D = convert2Dto3D(pnt_2D);
                    pnt_pln = (cam2floor.r*pnt_3D'+cam2floor.t)';
                    pnt_pln(3) = 1800;
                    pnt_3D = (floor2cam.r*pnt_pln'+floor2cam.t)';
                    pnt_2D = convert3Dto2D(pnt_3D);
                    rgb_img = draw_tag( rgb_img, 3, [tmp_x_base pnt_2D(2)] );
                    avg_dep_diff(p_id,end-50:end,end-200:end) = 50;
                end
            end
        end
    end
%     figure(1);
%     imagesc(uint16(out_dep));
    tot_active_p = sum(p_id_tot_frm>0);
    h_ = floor(sqrt(tot_active_p));
    w_ = ceil(sqrt(tot_active_p));
    all_diff_img = zeros(h_*240,w_*320);
    all_dep_img = zeros(h_*240,w_*320);
    i=0;
    for p_id = 1:p_num
        if (p_id_tot_frm(p_id)>0)
            r = ceil((i+1)/w_);
            r = (r-1)*240+1;
            c = mod(i,w_)+1;
            c = (c-1)*320+1;
            all_diff_img(r:r+240-1,c:c+320-1) = imresize_old(squeeze(avg_dep_diff(p_id,:,:)), [240, 320]);
            all_dep_img(r:r+240-1,c:c+320-1) = imresize_old(squeeze(sub_dep(p_id,:,:)), [240, 320]);
            i=i+1;
        end
    end
%     figure(2);
%     imagesc(uint16(all_diff_img));
%     figure(3);
%     imagesc(uint16(all_dep_img));
%     figure(4);
%     imshow(rgb_img);
%     pause(wait_sec);
    imwrite(rgb_img, sprintf('%s/result/%s/%06d.jpg', test_fold, data_name, f_id));
end
