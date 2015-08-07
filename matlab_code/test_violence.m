function test_violence(  )
    %% set path
    data_path = 'haoquan_test';
    addpath('test_data');
    addpath('libsvm-3.20/matlab');
    addpath('liblinear-1.96/matlab');
    run('vlfeat-0.9.20/toolbox/vl_setup.m');
    %%set parameters
    time_int = 15;
    check_time_span = 100;
    last_time_thr = 70;
    %% load model and testing data
    load('action_dataset_15/svm_model.mat');
    load(sprintf('%s_%d', data_path, 1));
    depth = data.depth;
    clear data;
    %% initializing
    tot_dep_diff = zeros(size(depth{1}));
    n = length(depth);
    depth{1}(depth{1}~=0) = depth{1}(depth{1}~=0)-2600;
    prev_mass_cen = calc_mass_cen_2D( depth{1} );
    prev_dep_diff = zeros(time_int,size(depth{1},1),size(depth{1},2));
    for i=2:time_int+1
        depth{i}(depth{i}~=0) = depth{i}(depth{i}~=0)-2600;
        cur_mass_cen = calc_mass_cen_2D( depth{i} );
        prev_dep_diff(i-1,:,:) = get_centralized_dep_diff(depth{i}, depth{i-1}, cur_mass_cen, prev_mass_cen);
        tot_dep_diff = tot_dep_diff + squeeze(prev_dep_diff(i-1,:,:));
        prev_mass_cen = cur_mass_cen;
    end
    %% test each video clips
    action_conf = zeros(3, check_time_span);
    for clip_idx = 1:10
        if (clip_idx == 1)
            st = time_int+2;
        else
            st = 2;
        end
        for i=st:n
            depth{i}(depth{i}~=0) = depth{i}(depth{i}~=0)-2600;
            cur_mass_cen = calc_mass_cen_2D( depth{i} );
            cur_dep_diff = get_centralized_dep_diff(depth{i}, depth{i-1}, cur_mass_cen, prev_mass_cen);
            tot_dep_diff = tot_dep_diff + cur_dep_diff - squeeze(prev_dep_diff(1,:,:));
            avg_dep_diff = tot_dep_diff / time_int;
            prev_dep_diff(1:end-1,:,:) = prev_dep_diff(2:end,:,:);
            prev_dep_diff(end,:,:) = cur_dep_diff;
            prev_mass_cen = cur_mass_cen;
            hog_feat = extract_HOG( avg_dep_diff );
            hog_feat = hog_feat';
            [predict_class, ~] = SVM_predict(hog_feat, best_svm_model);
            action_conf(:,1:end-1) = action_conf(:,2:end);
            action_conf(:,end) = 0;
            action_conf(predict_class,end) = 1;
            action = (sum(action_conf')>last_time_thr);
            out_dep = depth{i};
            out_dep(out_dep~=0) = out_dep(out_dep~=0)+2600;
            if (sum(action)>0)
                idx = find(action>0);
                if (idx==1)
    %                 fprintf('Normal~\n');
                    out_dep(end-50:end,1:200) = 3700;
                elseif (idx==2)
    %                 fprintf('Violence!!!\n');
                    mid = size(out_dep,2)/2;
                    out_dep(end-50:end,mid-100:mid+100) = 3700;
                else
    %                 fprintf('Wave Hand~\n');
                    out_dep(end-50:end,end-200:end) = 3700;
                end
            end
            show_dep( out_dep, '', 0 );
            show_dep_diff( avg_dep_diff, 0.01, '', '' );
            fprintf('%d/%d\n', i, n);
        end
        %% jump to next video clip
        if (clip_idx < 10)
            load(sprintf('%s_%d', data_path, clip_idx));
            depth = data.depth;
            clear data;
        end
    end

end
