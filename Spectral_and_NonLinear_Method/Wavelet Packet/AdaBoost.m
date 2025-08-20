clc;
clear all;
close all;

% % Load the dataset

time_data = readmatrix('All_Normalized_SampleAndBubbleEntropy_Features.xlsx'); % Assuming your data is stored as table
X =time_data(:,1:end-1) ; %% or freq_dat or frequency data
Y = time_data(:,end);

% Normalize the features for better performance (optional)
%X = normalize(X);

% Split the data into training and testing sets (80% train, 20% test)
cv = cvpartition(Y, 'HoldOut', 0.2);
X_train = X(training(cv), :);
Y_train = Y(training(cv), :);
X_test = X(test(cv), :);
Y_test = Y(test(cv), :);

% Train the AdaBoost model (Multi-class with AdaBoostM2)
numWeakLearners = 100; % Number of weak learners
weakLearner = templateTree('MaxNumSplits', 1); % Stump (weak learner)
AdaBoostModel = fitcensemble(X_train, Y_train, 'Method', 'AdaBoostM2', ...
    'Learners', weakLearner, 'NumLearningCycles', numWeakLearners);

% Make predictions
predictions = predict(AdaBoostModel, X_test);

% Initialize metrics
classes = unique(Y);
numClasses = length(classes);
metrics = struct('Class', [], 'Accuracy', [], 'Recall', [], 'Specificity', [], 'Precision', [], 'F_Score', []);
metricIndex = 1;

% Evaluate performance for each class
for j = 1:numClasses
    classLabel = classes(j);

    % Binary classification metrics for the current class (One-vs-All)
    TP = sum((predictions == classLabel) & (Y_test == classLabel)); % True Positives
    FP = sum((predictions == classLabel) & (Y_test ~= classLabel)); % False Positives
    TN = sum((predictions ~= classLabel) & (Y_test ~= classLabel)); % True Negatives
    FN = sum((predictions ~= classLabel) & (Y_test == classLabel)); % False Negatives

    % Metrics calculations
    Recall = TP / (TP + FN); % Sensitivity/Recall
    if isnan(Recall), Recall = 0; end
    Specificity = TN / (TN + FP); % Specificity
    if isnan(Specificity), Specificity = 0; end
    Precision = TP / (TP + FP); % Precision
    if isnan(Precision), Precision = 0; end
    F_Score = 2 * (Precision * Recall) / (Precision + Recall); % F1 Score
    if isnan(F_Score), F_Score = 0; end
    Accuracy = (TP + TN) / (TP + TN + FP + FN); % Accuracy

    % Store results
    metrics(metricIndex).Class = classLabel;
    metrics(metricIndex).Accuracy = Accuracy;
    metrics(metricIndex).Recall = Recall;
    metrics(metricIndex).Specificity = Specificity;
    metrics(metricIndex).Precision = Precision;
    metrics(metricIndex).F_Score = F_Score;

    metricIndex = metricIndex + 1;
end

% Display results
fprintf('Results for AdaBoost and each class label:\n');
for i = 1:length(metrics)
    fprintf('Class: %d, Accuracy: %.4f%%, Recall: %.4f, Specificity: %.4f, Precision: %.4f, F-Score: %.4f\n', ...
        metrics(i).Class, metrics(i).Accuracy * 100, metrics(i).Recall, metrics(i).Specificity, metrics(i).Precision, metrics(i).F_Score);
    para(i, :) = [metrics(i).Accuracy, metrics(i).Recall, metrics(i).Specificity, metrics(i).Precision, metrics(i).F_Score];
end

% Convert metrics struct to table
metrics_table = struct2table(metrics);

% Save metrics to an Excel file
writetable(metrics_table, 'AdaBoost_Metrics_BubbleAndSample.xlsx', 'Sheet', 1);
disp('Metrics saved to AdaBoost_Metrics_BubbleAndSample.xlsx');
