function [Accuracy, specificity, recall, fscore] = computeMetrics(Y_true, Y_pred, num_classes)
    confMat = confusionmat(Y_true, Y_pred);
    
    % Initialize metrics
   
    specificity = 0;
    recall = 0;
    fscore = 0;
    Accuracy=0;
    for i = 1:num_classes
        TP = confMat(i, i);
        FP = sum(confMat(:, i)) - TP;
        FN = sum(confMat(i, :)) - TP;
        TN = sum(confMat(:)) - (TP + FP + FN);
        specificity = specificity + TN / (TN + FP + eps);
        recall = recall + TP / (TP + FN + eps);
        fscore = fscore + 2 * TP / (2 * TP + FP + FN + eps);
        Accuracy= Accuracy+ (TP+TN )/ (TP + FP + FN + TN +eps);
    end

    Accuracy  = Accuracy/num_classes;
    specificity = specificity / num_classes;
    recall = recall / num_classes;
    fscore = fscore / num_classes;

end
