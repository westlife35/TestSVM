addpath('libsvm-3.20/matlab');
addpath('liblinear-1.96/matlab');
load('/home/haoquan/workspace/dataset/vio_wav_action_dataset/mat_train_test_data/VioWH_training_set2.mat');
load('/home/haoquan/workspace/dataset/action_dataset_15/VioWH_testing_set.mat');

max_svm_map = 0;
best_svm_lambda = 0;

for i = -6:1:6
    lambda = 10^i;
    [svm_map, svm_model] = SVM(train_data, train_label, test_data, test_label, lambda);
    svm_map = mean(svm_map);
    if (svm_map>max_svm_map)
        max_svm_map = svm_map;
        best_svm_lambda = lambda;
        best_svm_model = svm_model;
    end
    fprintf('lambda = 10^%d, svm map = %f/%f\n', i, svm_map, max_svm_map);
end
fprintf('lambda = %f max svm map = %f\n', best_svm_lambda, max_svm_map);
save('/home/haoquan/workspace/dataset/vio_wav_action_dataset/train_svm_model2.mat', 'best_svm_model', '-v7.3');
