clc
clear all
close all;
% Load cardiac disease dataset
time_data = readmatrix('All_Features_BubbleAndSample_Entropies.xlsx'); % Assuming your data is stored as table
X =time_data(:,1:end-1) ; %% or freq_dat or frequency data
Y = time_data(:,end);

% Normalize the features for better performance (optional)
%X = normalize(X);

%%
% For numeric data only
% data = readmatrix(fileName);
% Parameters
hidden_neurons = [50, 100, 150, 200 250 300];
activation_functions = {"sigmoid", "tanh", "relu", "wavelet", "sine"};

% Performance metrics storage
results = struct();

% Number of folds for k-fold cross-validation
k = 5;

% Loop through each activation function
for act_idx = 1:length(activation_functions)
    act_func = activation_functions{act_idx};
    fprintf('Using activation function: %s\n', act_func);
for hn =1:length(hidden_neurons)
        fprintf('Number of hidden neurons: %d\n', hn);
        
        % Initialize performance metrics
        accuracy_kfold = [];
        specificity_kfold = [];
        recall_kfold = [];
        fscore_kfold = [];

        % K-Fold Cross-Validation
        cv = cvpartition(Y, 'KFold', k);
        for fold = 1:k
            % Train-Test Split
            trainIdx = cv.training(fold);
            testIdx = cv.test(fold);

            X_train = X(trainIdx, :);
            Y_train = Y(trainIdx);
            X_test = X(testIdx, :);
            Y_test = Y(testIdx);
            % Train ELM
            [InputWeight, BiasofHiddenNeurons, OutputWeight] = trainELM(X_train, Y_train, hidden_neurons(hn), act_func);

            % Test ELM
            Y_pred = testELM(X_test, InputWeight, BiasofHiddenNeurons, OutputWeight, act_func);
            Y_pred = Y_pred - 1;
            % Compute performance metrics
            [accuracy, specificity, recall, fscore] = computeMetrics(Y_test, Y_pred, 3);

            accuracy_kfold = [accuracy_kfold, accuracy];
            specificity_kfold = [specificity_kfold, specificity];
            recall_kfold = [recall_kfold, recall];
            fscore_kfold = [fscore_kfold, fscore];
            confMat1 = confusionmat(Y_test, Y_pred);
            TP = diag(confMat1); % True Positives for each class
            FP = sum(confMat1, 1)' - TP; % False Positives for each class
            FN = sum(confMat1, 2) - TP; % False Negatives for each class
            Tn = sum(confMat1(:)) - (FP + FN + TP); % True Negatives for each class

            % Sensitivity (Recall)
            Sensitivity(fold,:) = TP ./ (TP + FN);
            % Specificity
            Specificity(fold,:) = Tn ./ (Tn + FP);

            % Precision (Positive Predictive Value)
            Precision(fold,:) = TP ./ (TP + FP);
             Accuracy_new(fold,:)= (TP+ Tn)./(TP + FP + Tn+ FN);
            % F-score
            F_score(fold,:) = 2 * (Precision(fold,:) .* Sensitivity(fold,:)) ./ (Precision(fold,:) + Sensitivity(fold,:));
  
        end
         Sensitivity1(hn,:)= mean(Sensitivity,1);
         Specificity1(hn,:)=mean(Specificity,1);
         Precision1 (hn,:) = mean(Precision,1);
         Accuracy_new1(hn,:)= mean(Accuracy_new,1);
         F_score1(hn,:) = mean(F_score,1);
        results.(act_func).(sprintf('H%d', hn)).accuracy = mean(accuracy_kfold);
%         results.(act_func).(sprintf('H%d', hn)).sensitivity = mean(sensitivity_kfold);
        results.(act_func).(sprintf('H%d', hn)).specificity = mean(specificity_kfold);
        results.(act_func).(sprintf('H%d', hn)).recall = mean(recall_kfold);
        results.(act_func).(sprintf('H%d', hn)).fscore = mean(fscore_kfold);

        % Display Confusion Matrix for last fold
        confusionchart(Y_test, Y_pred);
        title(sprintf('%s Activation - %d Hidden Neurons', act_func, hn));
end
     Sensitivity_final{act_idx}= Sensitivity1;
     Specificity_final{act_idx} = Specificity1;
     Precision1_final{act_idx} = Precision1;
     Accuracy_final{act_idx}   = Accuracy_new1;
     F_score_final{act_idx} = F_score1;
end
% Sensitivity_global=[Sensitivity_final];
% Acell = num2cell(Sensitivity_global,[2 1]); % put each page of A into a cell
% Acell = reshape(Acell,size(Sensitivity_global,3),1); %make the cell array a vector
% Sensitivity_all = cell2mat(Acell);
% %%
% Specificity_global=[Specificity_final];
% Acell = num2cell(Specificity_global,[2 1]); % put each page of A into a cell
% Acell = reshape(Acell,size(Specificity_global,3),1); %make the cell array a vector
% Specificity_all = cell2mat(Acell);
% %%
% Precision1_global=[Precision1_final];
% Acell = num2cell(Precision1_global,[2 1]); % put each page of A into a cell
% Acell = reshape(Acell,size(Precision1_global,3),1); %make the cell array a vector
% Precision1_all = cell2mat(Acell);
% %%
% Accuracy_global=[Accuracy_final];
% Acell = num2cell(Accuracy_global,[2 1]); % put each page of A into a cell
% Acell = reshape(Acell,size(Accuracy_global,3),1); %make the cell array a vector
% Accuracy_all = cell2mat(Acell);
% %%
% F_score_global=[F_score_final];
% Acell = num2cell(F_score_global,[2 1]); % put each page of A into a cell
% Acell = reshape(Acell,size(F_score_global,3),1); %make the cell array a vector
% F_score_all = cell2mat(Acell);


% % Save the metrics to an Excel file
% excel_filename = 'ELM_Metrics_BubbleEntropy.xlsx';
% 
% % Number of activation functions and hidden neurons
% numActivations = length(activation_functions);
% numHidden = length(hidden_neurons);
% 
% % Prepare the header row
% headers = {'Activation Function', 'Hidden Neurons', 'Accuracy'};
% 
% % Initialize an empty cell array to store the data
% metrics_cell = cell(numActivations * numHidden, length(headers));
% 
% % Fill in the data
% row = 1;
% for act_idx = 1:numActivations
%     for hn = 1:numHidden
%         metrics_cell{row, 1} = activation_functions{act_idx}; % Activation function
%         metrics_cell{row, 2} = hidden_neurons(hn); % Number of hidden neurons
%         metrics_cell{row, 3} = Accuracy_final{act_idx}(hn); % Accuracy
%         %metrics_cell{row, 4} = Sensitivity_final{act_idx}(hn); % Sensitivity
%         %metrics_cell{row, 5} = Specificity_final{act_idx}(hn); % Specificity
%         %metrics_cell{row, 6} = Precision1_final{act_idx}(hn); % Precision
%         %metrics_cell{row, 7} = F_score_final{act_idx}(hn); % F1 Score
%         row = row + 1;
%     end
% end
% 
% % Write headers
% writecell(headers, excel_filename, 'Sheet', 1, 'Range', 'A1');
% 
% % Write the metrics data
% writecell(metrics_cell, excel_filename, 'Sheet', 1, 'Range', 'A2');
% 
% disp('Metrics saved to ELM_Metrics_BubbleEntropy.xlsx');

% Convert results to a table and save to Excel
activation_funcs = fieldnames(results);
excel_filename = 'ELM_Metrics_BubbleAndSample.xlsx';

% Initialize data storage with headers
data = {"Activation Function", "Hidden Neurons", "Accuracy", "Specificity", "Recall", "F-Score"};

for i = 1:length(activation_funcs)
    act_func = activation_funcs{i};
    hidden_layers = fieldnames(results.(act_func));

    for j = 1:length(hidden_layers)
        hl = hidden_layers{j};

        % Extract number of hidden neurons from the main code's hidden_neurons array
        num_hidden_idx = str2double(erase(hl, 'H')); % Get index (1-6)
        
        % Ensure index is within range of hidden_neurons array
        if num_hidden_idx >= 1 && num_hidden_idx <= length(hidden_neurons)
            num_hidden = hidden_neurons(num_hidden_idx); % Use the actual hidden neuron value
        else
            num_hidden = NaN; % Handle unexpected cases
        end

        % Extract metrics
        acc = results.(act_func).(hl).accuracy;
        spec = results.(act_func).(hl).specificity;
        rec = results.(act_func).(hl).recall;
        fsc = results.(act_func).(hl).fscore;

        % Avoid NaN values by replacing them with zero
        if isnan(acc), acc = 0; end
        if isnan(spec), spec = 0; end
        if isnan(rec), rec = 0; end
        if isnan(fsc), fsc = 0; end

        % Store in cell array
        data = [data; {act_func, num_hidden, acc, spec, rec, fsc}];
    end
end

% Write data to Excel
writecell(data, excel_filename);

disp('Metrics successfully saved to ELM_Metrics_BubbleAndSample.xlsx');

