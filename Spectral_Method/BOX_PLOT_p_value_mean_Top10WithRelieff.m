clc
clf
clear all
close all
fileName = 'Top10_Named_Feature_Values_Using_Relieff.xlsx'; % Replace with your file name
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
data5=  [A(1:700,5), A(701:1400,5),A(1401:2100,5),A(2101:2800,5),A(2801:3500,5)];
data6=  [A(1:700,6), A(701:1400,6),A(1401:2100,6),A(2101:2800,6),A(2801:3500,6)];
data7=  [A(1:700,7), A(701:1400,7),A(1401:2100,7),A(2101:2800,7),A(2801:3500,7)];
data8=  [A(1:700,8), A(701:1400,8),A(1401:2100,8),A(2101:2800,8),A(2801:3500,8)];
data9=  [A(1:700,9), A(701:1400,9),A(1401:2100,9),A(2101:2800,9),A(2801:3500,9)];
data10= [A(1:700,10), A(701:1400,10),A(1401:2100,10),A(2101:2800,10),A(2801:3500,10)];

figure('Position', [100, 100, 1200, 600]); % Adjust width (1200) and height (600)
subplot(5,2,1)
boxplot(data1,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(a) m-f2-st');
ylim([0 55]);
%ylim([0 3]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,3)
boxplot(data2,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(b) m-f4-st');
ylim([0 5]);
%ylim([2 5]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,5)
boxplot(data3,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(c) m-f3-st');
ylim([0 20]);
%ylim([2 5]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,7)
boxplot(data4,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(d) m-f1-st');
ylim([0 60]);
%ylim([0 4]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,9)
boxplot(data5,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(e) m-n0-wp');
ylim([-0.3e-12 0.3e-12]);
%ylim([-1e-12 1e-12]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,2)
boxplot(data6,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(f) mL1-a-sw');
ylim([-0.2e-13 0.2e-13]);
%ylim([1 5]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,4)
boxplot(data7,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(g) mL2-a-sw');
ylim([-0.3e-13 0.3e-13]);
%ylim([1 4]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,6)
boxplot(data8,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(h) m-n12-wp');
ylim([-0.5 0.5]);
%ylim([1 3]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,8)
boxplot(data8,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(i) m-n14-wp');
ylim([-0.5 0.5]);
%ylim([1 3]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
% Optional: Customize appearance
set(gca, 'FontSize', 10);
subplot(5,2,10)
boxplot(data8,{'HC','AMI', 'ALMI', 'ASMI', 'IMI'})
title('(j) m-n6-wp');
ylim([-0.5 0.5])
%ylim([1 3]);
%yticks([0 2 3 4]); % Set ticks only at 4 and 5
grid on;
box off
%%  Mean and standared deviation
f2_band_mean_stockwell= mean(data1);
f4_band_mean_stockwell = mean(data2);
f3_band_mean_stockwell= mean(data3);
f1_band_mean_stockwell= mean(data4);
n0_band_mean_wavePack= mean(data5);
l1_band_mean_staWav = mean(data6);
l2_band_mean_staWav= mean(data7);
n12_band_mean_wavePack= mean(data8);
n14_band_mean_wavePack= mean(data9);
n6_band_mean_wavePack= mean(data10);
f2_band_sd_stockwell= std(data1);
f4_band_sd_stockwell = std(data2);
f3_band_sd_stockwell= std(data3);
f1_band_sd_stockwell= std(data4);
n0_band_sd_wavePack= std(data5);
l1_band_sd_staWav = std(data6);
l2_band_sd_staWav= std(data7);
n12_band_sd_wavePack= std(data8);
n14_band_sd_wavePack= std(data9);
n6_band_sd_wavePack= std(data10);
%% Perform two-sample t-test or Wilcoxon rank-sum test

% Example dataset (replace with your actual data)
num_features = 10;  % Number of features
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
p_values_filename = 'p_values_Top10_Relieff.xlsx';
writematrix(p_values, p_values_filename);
fprintf('P-values successfully saved to %s\n', p_values_filename);

% Define mean and standard deviation matrices
means = [f2_band_mean_stockwell; f4_band_mean_stockwell; f3_band_mean_stockwell; f1_band_mean_stockwell; ...
         n0_band_mean_wavePack; l1_band_mean_staWav; l2_band_mean_staWav; n12_band_mean_wavePack; ...
         n14_band_mean_wavePack; n6_band_mean_wavePack];

stds = [f2_band_sd_stockwell; f4_band_sd_stockwell; f3_band_sd_stockwell; f1_band_sd_stockwell; ...
         n0_band_sd_wavePack; l1_band_sd_staWav; l2_band_sd_staWav; n12_band_sd_wavePack; ...
         n14_band_sd_wavePack; n6_band_sd_wavePack];


% Define row labels for Mean & Std
feature_names = {'f2_band_mean_stockwell', 'f4_band_mean_stockwell', 'f3_band_mean_stockwell', 'f1_band_mean_stockwell', ...
                 'n0_band_mean_wavePack', 'l1_band_mean_staWav', 'l2_band_mean_staWav', 'n12_band_mean_wavePack', ...
                 'n14_band_mean_wavePack', 'n6_band_mean_wavePack', ...
                 'f2_band_sd_stockwell', 'f4_band_sd_stockwell', 'f3_band_sd_stockwell', 'f1_band_sd_stockwell', ...
                 'n0_band_sd_wavePack', 'l1_band_sd_staWav', 'l2_band_sd_staWav', 'n12_band_sd_wavePack', ...
                 'n14_band_sd_wavePack', 'n6_band_sd_wavePack'};

% Combine means and standard deviations into a structured table
mean_std_data = [means; stds];

% Create column headers for classes
class_headers = {'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'};

% Create a table
T = array2table(mean_std_data, 'VariableNames', class_headers);
T = addvars(T, feature_names', 'Before', 1, 'NewVariableNames', {'Mean_Std_Features'});

% Save the structured table to an Excel file
mean_std_filename = 'mean_std_Top10_Relieff.xlsx';
writetable(T, mean_std_filename);
fprintf('Mean and standard deviation successfully saved to %s\n', mean_std_filename);



