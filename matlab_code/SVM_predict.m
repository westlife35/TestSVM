function [predict_class, predict_score] = SVM_predict(test_data, model)

	class_num=3;
	test_num=size(test_data,1);
	predict_score=zeros(test_num, class_num);
    test_label=double(zeros(test_num,1));
	for class_idx=1:class_num
% 		[~, ~, one_class_predict_score] = svmpredict(test_label, test_data, model{class_idx},'-q');
		[~, ~, one_class_predict_score] = predict(test_label, sparse(double(test_data)), model{class_idx},'-q');
        predict_score(:,class_idx) = one_class_predict_score;
    end
    predict_class = find(predict_score==max(predict_score));
    
end
