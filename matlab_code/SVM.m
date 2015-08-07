function [map, out_model, predict_score] = SVM(trainD, trainY, testD, testY, lambda)
	class_num=size(trainY,2);
    train_num=size(trainD,1);
	test_num=size(testD,1);
	predict_score=zeros(test_num,class_num);
    out_model = {};
	for class_idx=1:class_num
        trainY(find(trainY(:,class_idx)~=1),class_idx)=-1;
% 		model = svmtrain(trainY(:,class_idx), trainD, ['-s 0 -c ' num2str(lambda) ' -t 0 -q']);
		model = train(trainY(:,class_idx), sparse(trainD), ['-s 11 -c ' num2str(lambda) ' -q']);
        testY(find(testY(:,class_idx)~=1),class_idx)=-1;
% 		[~, ~, one_class_predict_score] = svmpredict(testY(:,class_idx), testD, model,'-q');
		[~, ~, one_class_predict_score] = predict(testY(:,class_idx), sparse(testD), model,'-q');
        predict_score(:,class_idx) = one_class_predict_score;
        out_model{class_idx} = model;
    end
    map = evaluationMAP(testY,predict_score);
end
