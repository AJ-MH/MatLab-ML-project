clc
clf
clear all
close all
fileName = 'All_Named_UnNormalized_SampleEntropy_Features.xlsx'; 
data = readmatrix(fileName, 'NumHeaderLines', 1); 
X = data(:, 1:end-1); 
Y = data(:, end);     
A = X;

% Create data1 to data15
for i = 1:15
    eval(sprintf('data%d = [A(1:700,%d), A(701:1400,%d), A(1401:2100,%d), A(2101:2800,%d), A(2801:3500,%d)];', ...
        i, i, i, i, i, i));
end

% Plot: 2 columns (left: node 0 to 7, right: node 8 to 14)
figure('Position', [100, 100, 1400, 1000]); 

% Define column and row mapping
column_map = [1*ones(1,5), 2*ones(1,5), 3*ones(1,5)]; % Column 1: nodes 0–4, 2: 5–9, 3: 10–14
row_map = [1:5, 1:5, 1:5]; % All rows from top to bottom

for i = 1:15
    row = row_map(i);
    col = column_map(i);
    subplot_idx = (row - 1)*3 + col;

    subplot(5, 3, subplot_idx);
    eval(sprintf('boxplot(data%d,{''HC'',''AMI'', ''ALMI'', ''ASMI'', ''IMI''})', i));
    title(sprintf('Nd-%d-SE', i - 1));
    ylim([0 4.8]);
    grid on;
    box off;
    set(gca, 'FontSize', 10);
end


%% Mean and standard deviation for all 15 features
for i = 1:15
    eval(sprintf('mean_sample(%d,:) = mean(data%d);', i, i));
    eval(sprintf('sd_sample(%d,:) = std(data%d);', i, i));
end

%% Perform Wilcoxon rank-sum test
num_features = 15;  
num_classes = 5;   
p_values = zeros(4, num_features); 

for feature_idx = 1:num_features
    feature_data = X(:, feature_idx); 
    data_level_1 = feature_data(Y == 1);

    for level = 2:5
        data_level_current = feature_data(Y == level);
        p = ranksum(data_level_1, data_level_current);
        p_values(level-1, feature_idx) = p;
    end
end

fprintf('P-values for each feature comparing levels 2, 3, 4, 5 with level 1:\n');
disp(p_values);

% Visualize p-values
figure;
heatmap(p_values, 'XLabel', 'Feature Index', 'YLabel', 'Levels (2-5)', ...
        'Title', 'P-Values for Each Feature (Levels 2-5 vs Level 1)');
colormap('jet');
colorbar;

% Save P-Values
p_values_filename = 'p_values_SampleEn_WPT_15Features.xlsx';
writematrix(p_values, p_values_filename);
fprintf('P-values successfully saved to %s\n', p_values_filename);

% Save Mean and SD
feature_labels = strcat("Nd-", string(0:14));
feature_names = [ ...
    strcat(feature_labels, "_mean_sample"), ...
    strcat(feature_labels, "_sd_sample")];

mean_std_data = [mean_sample; sd_sample];
class_headers = {'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'};
T = array2table(mean_std_data, 'VariableNames', class_headers);
T = addvars(T, feature_names', 'Before', 1, 'NewVariableNames', {'Mean_Std_Features'});

mean_std_filename = 'mean_std_SampleEn_WPT_15Features.xlsx';
writetable(T, mean_std_filename);
fprintf('Mean and standard deviation successfully saved to %s\n', mean_std_filename);
