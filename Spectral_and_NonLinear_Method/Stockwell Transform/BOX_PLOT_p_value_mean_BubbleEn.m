clc
clf
clear all
close all
fileName = 'All_Named_UnNormalized_BubbleEntropy_Features.xlsx'; % Replace with your file name
% Read the Excel file into MATLAB
%data = readmatrix(fileName); % Use this for structured data with headers
data = readmatrix(fileName, 'NumHeaderLines', 1); % Skips the first row
X = data(:, 1:end-1); %% Features  
Y = data(:, end);     %% Labels  
A=X;
data1 = [A(1:700,1), A(701:1400,1),A(1401:2100,1),A(2101:2800,1),A(2801:3500,1)];
data2 = [A(1:700,2), A(701:1400,2),A(1401:2100,2),A(2101:2800,2),A(2801:3500,2)];
data3=  [A(1:700,3), A(701:1400,3),A(1401:2100,3),A(2101:2800,3),A(2801:3500,3)];
data4=  [A(1:700,4), A(701:1400,4),A(1401:2100,4),A(2101:2800,4),A(2801:3500,4)];

figure('Position', [100, 100, 1200, 600]); % Adjust width (1200) and height (600)
subplot(4,1,1)
boxplot(data1,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(a) f1-BE');
ylim([0.2 0.7]);
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(4,1,2)
boxplot(data2,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(b) f2-BE');
ylim([0.2 0.6]);
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(4,1,3)
boxplot(data3,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(c) f3-BE');
ylim([0.1 0.2]);
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(4,1,4)
boxplot(data4,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(d) f4-BE');
ylim([0.03 0.08]);
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);

%%  Mean and standared deviation
f1_band_mean_bubble= mean(data1);
f2_band_mean_bubble = mean(data2);
f3_band_mean_bubble= mean(data3);
f4_band_mean_bubble= mean(data4);
f1_band_sd_bubble= std(data1);
f2_band_sd_bubble = std(data2);
f3_band_sd_bubble= std(data3);
f4_band_sd_bubble= std(data4);
%% Perform two-sample t-test or Wilcoxon rank-sum test

% Example dataset (replace with your actual data)
num_features = 4;  % Number of features
num_classes = 5;   % Number of classes

% Initialize p-value storage
p_values = zeros(4, num_features); % Rows for levels (2, 3, 4, 5), Columns for features

% Loop through each feature and each level
for feature_idx = 1:num_features
    feature_data = X(:, feature_idx); % Extract the feature column

    % Data for level 1
    data_level_1 = feature_data(Y == 1);

    for level = 2:5
        % Data for the current level
        data_level_current = feature_data(Y == level);

        % Perform two-sample t-test or Wilcoxon rank-sum test
        % Uncomment the desired method below:

% %         % Two-sample t-test
%        [~, p] = ttest2(data_level_1, data_level_current); 

        % Wilcoxon rank-sum test (non-parametric)
         p = ranksum(data_level_1, data_level_current);

        % Store p-value
        p_values(level-1, feature_idx) = p;
    end
end

% Display results
fprintf('P-values for each feature comparing levels 2, 3, 4, 5 with level 1:\n');
disp(p_values);

% Optional: Visualize p-values
figure;
heatmap(p_values, 'XLabel', 'Feature Index', 'YLabel', 'Levels (2-5)', ...
        'Title', 'P-Values for Each Feature (Levels 2-5 vs Level 1)');
colormap('jet');
colorbar;

% Save P-Values to an Excel File
p_values_filename = 'p_values_BubbleEn.xlsx';
writematrix(p_values, p_values_filename);
fprintf('P-values successfully saved to %s\n', p_values_filename);

% Define mean and standard deviation matrices
means = [f1_band_mean_bubble; f2_band_mean_bubble; f3_band_mean_bubble; f4_band_mean_bubble; ...
         ];

stds = [f1_band_sd_bubble; f2_band_sd_bubble; f3_band_sd_bubble; f4_band_sd_bubble; ...
        ];

% Define row labels for Mean & Std
feature_names = {'f1_band_mean_bubble', 'f2_band_mean_bubble', 'f3_band_mean_bubble', 'f4_band_mean_bubble', ...
                 'f1_band_sd_bubble', 'f2_band_sd_bubble', 'f3_band_sd_bubble', 'f4_band_sd_bubble', ...
                 };

% Combine means and standard deviations into a structured table
mean_std_data = [means; stds];

% Create column headers for classes
class_headers = {'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'};

% Create a table
T = array2table(mean_std_data, 'VariableNames', class_headers);
T = addvars(T, feature_names', 'Before', 1, 'NewVariableNames', {'Mean_Std_Features'});

% Save the structured table to an Excel file
mean_std_filename = 'mean_std_BubbleEn.xlsx';
writetable(T, mean_std_filename);
fprintf('Mean and standard deviation successfully saved to %s\n', mean_std_filename);



