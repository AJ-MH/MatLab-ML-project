clc
clf
close all
clear all
%%
% Parameter Tuning
% Hyperparameter Optimization: Optimize SVM parameters such as the BoxConstraint, KernelScale, or PolynomialOrder (for polynomial kernels). MATLAB’s bayesopt function can help with Bayesian optimization.
% Load the cardiac disease dataset
time_data = readmatrix('All_Spectral_Features'); % Assuming your data is stored as table
X1 =time_data(:,1:end-1) ; %% or freq_dat or frequency data
Y = time_data(:,end);
% X1 = normalize(X1);
[rankedIdx, weights] = relieff(X1, Y, 5); % 5 nearest neighbors

% Select the top 10 features
top10Features = rankedIdx(1:10);
X_top10 = X1(:, top10Features);
%%
% % Normalize the features for better performance
X=X_top10;

% % Normalize the features for better performance
%X = normalize(X);

% % Split the data into training and testing sets (80% train, 20% test)
cv = cvpartition(Y, 'HoldOut', 0.2);
X_train = X(training(cv), :);
Y_train = Y(training(cv), :);
X_test = X(test(cv), :);
Y_test = Y(test(cv), :);
% Perform PCA for dimensionality reduction
% [coeff, X_pca, ~] = pca(X);
% 
% % Split the data
% cv = cvpartition(Y, 'HoldOut', 0.2);
% X_train = X_pca(training(cv), :);
% Y_train = Y(training(cv), :);
% X_test = X_pca(test(cv), :);
% Y_test = Y(test(cv), :);
% % 

% Define kernel functions
% kernels = {'linear', 'rbf', 'polynomial'};
kernels = {'rbf'};
numKernels = length(kernels);

% Initialize metrics
metrics = struct('Kernel', [], 'Class', [], 'Accuracy', [], 'Recall', [], ...
    'Specificity', [], 'Precision', [], 'F_Score', []);

metricIndex = 1;
tic %
% Train and test SVM with each kernel
for i = 1:numKernels
    kernelFunction = kernels{i};
   
% Perform Bayesian optimization for multiclass SVM using ECOC
svmOpts = struct('AcquisitionFunctionName', 'expected-improvement-plus');

mdl = fitcecoc(X_train, Y_train, ...
               'Learners', templateSVM('KernelFunction', kernelFunction), ...
               'OptimizeHyperparameters', {'BoxConstraint', 'KernelScale'}, ...
               'HyperparameterOptimizationOptions', svmOpts);

% Evaluate the model
predictions = predict(mdl, X_test);
 figure(3)
   % Create confusion matrix
ConfMat = confusionchart(Y_test, predictions);

    % Get unique class labels
    classes = unique(Y);
    numClasses = length(classes);
    
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
        metrics(metricIndex).Kernel = kernelFunction;
        metrics(metricIndex).Class = classLabel;
        metrics(metricIndex).Accuracy = Accuracy;
        metrics(metricIndex).Recall = Recall;
        metrics(metricIndex).Specificity = Specificity;
        metrics(metricIndex).Precision = Precision;
        metrics(metricIndex).F_Score = F_Score;
        
        metricIndex = metricIndex + 1;
    end
end
toc %
% Display results
fprintf('Results for each kernel and class label:\n');
for i = 1:length(metrics)
    fprintf('Kernel: %s, Class: %d, Accuracy: %.4f%%, Recall: %.4f, Specificity: %.4f, Precision: %.4f, F-Score: %.4f\n', ...
    metrics(i).Kernel, metrics(i).Class, metrics(i).Accuracy * 100, metrics(i).Recall, metrics(i).Specificity, metrics(i).Precision, metrics(i).F_Score);
para(i,:)=[metrics(i).Accuracy , metrics(i).Recall, metrics(i).Specificity, metrics(i).Precision, metrics(i).F_Score];
end

% Save the top 10 feature values to an Excel file
writematrix(X_top10, 'Top10_Feature_Values_BOSVM_Using_Relieff.xlsx');

% Convert metrics struct to a cell array for writing to Excel
headers = {'Class', 'Accuracy', 'Recall', 'Specificity', 'Precision', 'F-Score'};
metrics_data = cell(length(metrics), 6);

for i = 1:length(metrics)
    metrics_data{i, 1} = metrics(i).Class;
    metrics_data{i, 2} = metrics(i).Accuracy;
    metrics_data{i, 3} = metrics(i).Recall;
    metrics_data{i, 4} = metrics(i).Specificity;
    metrics_data{i, 5} = metrics(i).Precision;
    metrics_data{i, 6} = metrics(i).F_Score;
end

% Combine headers and data
final_metrics_data = [headers; metrics_data];

% Save to Excel
writecell(final_metrics_data, 'BOSVM_Metrics_By_RelieffRanking.xlsx');

disp('Metrics successfully saved to BOSVM_Metrics_By_RelieffRanking.xlsx');