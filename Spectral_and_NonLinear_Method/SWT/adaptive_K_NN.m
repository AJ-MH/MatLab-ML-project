clc
clf
clear all;
close all;

% Load the cardiac disease dataset
time_data = readmatrix('All_Features_BubbleAndSample_Entropies.xlsx'); % Assuming your data is stored as table
X =time_data(:,1:end-1) ; %% or freq_dat or frequency data
Y = time_data(:,end);

% Normalize features for better performance
% X = normalize(X);

% Split data into training and testing sets (80% train, 20% test)
cv = cvpartition(Y, 'HoldOut', 0.2);
X_train = X(training(cv), :);
Y_train = Y(training(cv), :);
X_test = X(test(cv), :);
Y_test = Y(test(cv), :);

% Define the range of k values to test
k_values = 1:10;
numClasses = numel(unique(Y));

% Initialize variables to store results
best_k = 1;
best_accuracy = 0;
accuracy_list = zeros(length(k_values), 1);

for i = 1:length(k_values)
    k = k_values(i);

    % Train and test the k-NN model
    mdl = fitcknn(X_train, Y_train, 'NumNeighbors', k, 'Standardize', true);
    predictions = predict(mdl, X_test);

    % Calculate accuracy
    accuracy = sum(predictions == Y_test) / numel(Y_test);
    accuracy_list(i) = accuracy;

    % Update best k if this k gives higher accuracy
    if accuracy > best_accuracy
        best_k = k;
        best_accuracy = accuracy;
    end
end

% Train the model with the best k
final_model = fitcknn(X_train, Y_train, 'NumNeighbors', best_k, 'Standardize', true);
final_predictions = predict(final_model, X_test);

% Calculate performance metrics
confMat = confusionmat(Y_test, final_predictions);
TP = diag(confMat); % True Positives for each class
FP = sum(confMat, 1)' - TP; % False Positives for each class
FN = sum(confMat, 2) - TP; % False Negatives for each class
TN = sum(confMat(:)) - (FP + FN + TP); % True Negatives for each class

% Sensitivity (Recall)
Sensitivity = TP ./ (TP + FN);

% Specificity
Specificity = TN ./ (TN + FP);
Accuracy = (TP+TN)./(TP + FN +TN + FP);
% Precision (Positive Predictive Value)
Precision = TP ./ (TP + FP);

% F-score
F_score = 2 * (Precision .* Sensitivity) ./ (Precision + Sensitivity);

% Display metrics
fprintf('Best k: %d\n', best_k);
fprintf('Best Accuracy: %.4f%%\n', best_accuracy * 100);
for class = 1:numClasses
    fprintf('Class %d Metrics:\n', class);
    fprintf('  Sensitivity (Recall): %.4f\n', Sensitivity(class));
    fprintf('  Specificity: %.4f\n', Specificity(class));
    fprintf('  Precision: %.4f\n', Precision(class));
    fprintf('  F-score: %.4f\n', F_score(class));
    fprintf('  Accuracy: %.4f\n', Accuracy(class));
end

% Plot accuracy vs. k
figure(1);
plot(k_values, accuracy_list, '-o');
grid on;
title('k-NN Accuracy for Different k Values');
xlabel('Number of Neighbors (k)');
ylabel('Accuracy');
figure(2);
% Confusion matrix
confusionchart(Y_test, final_predictions);
title('Confusion Matrix');

% Store metrics in an Excel file
metrics_table = table((1:numClasses)', Accuracy, Sensitivity, Specificity, Precision, F_score, ...
    'VariableNames', {'Class', 'Accuracy', 'Sensitivity', 'Specificity', 'Precision', 'F_score'});

writetable(metrics_table, 'AdaptiveKNN_Metrics_BubbleAndSample.xlsx', 'Sheet', 1);
disp('Metrics saved to AdaptiveKNN_Metrics_BubbleAndSample.xlsx');

