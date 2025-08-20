clc;
clear all;
close all;

% Specify the folder containing .mat files
folderPath = 'C:\Users\AJ\Downloads\Kan_AJ\MatLab Simulations\Spectral_Method\1_RawToFeatures\WPD\MI_Without_Normalization\Antero_SeptalMI_Without_Normalization\antero-septal_mat_all_files';

% Get list of all .mat files in the specified folder
mat_files = dir(fullfile(folderPath, '*.mat'));

% Initialize data storage
xM = [];

for k = 1:length(mat_files)
    file_name = fullfile(folderPath, mat_files(k).name);
    load(file_name);  % Load .mat file

    % Extract ECG signal safely based on available data length
    d = val(2, 1:min(40000, size(val, 2)));  

    % Preprocessing
    signal = d - mean(d);  % Remove DC component
    fs = 1000;  % Sampling frequency
    signal = highpass(signal, 0.5, fs);  % Remove baseline wander
    signal = bandstop(signal, [49 51], fs);  % Remove 50 Hz powerline noise

    xV = signal;  
    n = 2000;  % Window length
    s = n;     % Step size
    segmented_signal = Divide_RR_sample(xV, n, s);
    
    % Ensure consistent size before assigning to xM
    if k == 1
        xM = zeros(size(segmented_signal, 1), size(segmented_signal, 2), length(mat_files));
    end
    common_cols = min(size(xM, 2), size(segmented_signal, 2));
    xM(:, 1:common_cols, k) = segmented_signal(:, 1:common_cols);
end

% Convert segmented data to matrix format
time = [xM];
Acell = num2cell(time, [2 1]);
Acell = reshape(Acell, size(time,3), 1);
desired_ECG = cell2mat(Acell);
desired_ECG = desired_ECG';

[row, col] = size(desired_ECG);
mean_features = [];

for p = 1:col
    ecg = desired_ECG(:, p) - mean(desired_ECG(:, p));  % Remove mean (DC component)
    signal = ecg;

    % WPD Parameters
    wavelet_name = 'db4';
    level = 3;

    % Perform WPD
    wp_tree = wpdec(signal, level, wavelet_name);

    % Get 15 nodes from level 0 to level 3 (0 to 14)
    node_indices = 0:14;  
    num_nodes = length(node_indices);

    % Compute mean from each node
    feature_vec = zeros(1, num_nodes);

    for i = 1:num_nodes
        node_signal = wpcoef(wp_tree, node_indices(i));
        feature_vec(i) = mean(node_signal);
    end

    mean_features(p, :) = feature_vec;
end

% Create headers: m-nd0, m-nd1, ..., m-nd14
headers = strcat("m-nd", string(0:14));
output_data = [headers; num2cell(mean_features)];

% Write to Excel
xlswrite('ASMISpectral_WPD_MeanFeatures.xlsx', output_data);

disp('WPD Mean feature extraction and Excel file writing complete.');
