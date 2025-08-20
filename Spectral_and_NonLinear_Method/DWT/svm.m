clc
clf
close all
clear all
% Load the dataset (Replace 'MULTI_MI_healthy_elderly.xlsx' with your file name)
time_data = readmatrix('All_Normalized_SampleAndBubbleEntropies_Features.xlsx'); % Assuming your data is stored as table
X =time_data(:,1:end-1) ; %% or freq_dat or frequency data
Y = time_data(:,end);
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


% Define kernel functions
kernels = {'linear', 'rbf', 'polynomial'};

numKernels = length(kernels);

% Initialize metrics
metrics = struct('Kernel', [], 'Class', [], 'Accuracy', [], 'Recall', [], ...
    'Specificity', [], 'Precision', [], 'F_Score', []);

metricIndex = 1;

% Train and test SVM with each kernel
for i = 1:numKernels
    kernelFunction = kernels{i};
    
    % Train the SVM model
 SVMModel = fitcecoc(X_train, Y_train, 'Learners', templateSVM('KernelFunction', kernelFunction));


  predictions = predict(SVMModel, X_test);
    
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

% Display results
fprintf('Results for each kernel and class label:\n');
for i = 1:length(metrics)
    fprintf('Kernel: %s, Class: %d, Accuracy: %.4f%%, Recall: %.4f, Specificity: %.4f, Precision: %.4f, F-Score: %.4f\n', ...
    metrics(i).Kernel, metrics(i).Class, metrics(i).Accuracy * 100, metrics(i).Recall, metrics(i).Specificity, metrics(i).Precision, metrics(i).F_Score);
para(i,:)=[metrics(i).Accuracy , metrics(i).Recall, metrics(i).Specificity, metrics(i).Precision, metrics(i).F_Score];
end

% Convert metrics struct to table
metrics_table = struct2table(metrics);

% Save metrics to an Excel file
writetable(metrics_table, 'SVM_Metrics_BubbleAndSample.xlsx', 'Sheet', 1);
disp('Metrics saved to SVM_Metrics_BubbleAndSample.xlsx');
