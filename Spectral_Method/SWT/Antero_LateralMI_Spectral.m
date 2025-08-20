clc;
clear all;
close all;

% Specify the folder containing .mat files
folderPath = 'C:\Users\AJ\Downloads\Kan_AJ\MatLab Simulations\Spectral_Method\1_RawToFeatures\SWT\MI_Without_Normalization\Antero_LateralMI_Without_Normalization\antero-lateral_mat_all_files';

% Get list of all .mat files in the specified folder
mat_files = dir(fullfile(folderPath, '*.mat'));

% Initialize data storage
xM = [];

for k = 1:length(mat_files)
    file_name = fullfile(folderPath, mat_files(k).name);
    load(file_name);  % Load .mat file

    % Extract ECG signal safely
    d = val(2, 1:min(40000, size(val,2)));  

    % Preprocessing
    signal = d - mean(d);  % Remove DC
    fs = 1000;  % Sampling frequency
    signal = highpass(signal, 0.5, fs);  % Baseline wander removal
    signal = bandstop(signal, [49 51], fs);  % Remove 50 Hz

    xV = signal;  
    n = 2000;
    s = n;

    segmented_signal = Divide_RR_sample(xV, n, s);

    if k == 1
        xM = zeros(size(segmented_signal, 1), size(segmented_signal, 2), length(mat_files));
    end

    common_cols = min(size(xM, 2), size(segmented_signal, 2));
    xM(:, 1:common_cols, k) = segmented_signal(:, 1:common_cols);
end

% Reshape segmented signals
time = [xM];
Acell = num2cell(time, [2 1]);
Acell = reshape(Acell, size(time, 3), 1);
desired_ECG = cell2mat(Acell);
desired_ECG = desired_ECG';

[row, col] = size(desired_ECG);
mean_features = [];

for p = 1:col
    ecg = desired_ECG(:,p) - mean(desired_ECG(:,p)); 
    signal = ecg;
    N = length(signal);

    % SWT Decomposition
    wavelet_name = 'db4';
    level = 4;

    target_length = ceil(N / 2^level) * 2^level;
    if length(signal) < target_length
        signal = [signal; zeros(target_length - length(signal), 1)];
    else
        signal = signal(1:target_length);
    end

    [CA, CD] = swt(signal, level, wavelet_name);

    feature_vec = zeros(1, level * 2);

    for i = 1:level
        approx_signal = CA(i, :);
        detail_signal = CD(i, :);

        feature_vec((i - 1) * 2 + 1) = mean(approx_signal);  % Mean of Approx Coefficients
        feature_vec((i - 1) * 2 + 2) = mean(detail_signal);  % Mean of Detail Coefficients
    end

    mean_features(p, :) = feature_vec;
end

% Define headers
headers = {
    'mL1-apx', 'mL1-det', ...
    'mL2-apx', 'mL2-det', ...
    'mL3-apx', 'mL3-det', ...
    'mL4-apx', 'mL4-det'};

% Combine headers and data
final_data = [headers; num2cell(mean_features)];

% Write to Excel
writecell(final_data, 'ALMISpectral_MeanFeatures.xlsx');

disp('Mean feature extraction and Excel file writing complete.');
