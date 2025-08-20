clc;
clf;
close all;
clear all;

% Specify the folder containing .mat files
folderPath = 'C:\Users\AJ\Downloads\Kan_AJ\MatLab Simulations\Spectral_Method\1_RawToFeatures\ST\MI_Without_Normalization\InferiorMI_Without_Normalization\Inferior MI_Dataset_mat_all_files';
mat_files = dir(fullfile(folderPath, '*.mat'));

expected_cols = 20;
xM = [];

for k = 1:length(mat_files)
    file_name = fullfile(folderPath, mat_files(k).name);
    load(file_name);
    d = val(2, 1:min(40000, size(val, 2)));
    xV = d;
    n = 2000;
    s = n;

    result = Divide_RR_sample(xV, n, s);

    if size(result, 1) == 2000 && size(result, 2) == expected_cols
        xM(:, :, k) = result;
    else
        fprintf('Skipping file %s due to unexpected output size: %dx%d\n', ...
            mat_files(k).name, size(result, 1), size(result, 2));
    end
end

% Reshape segmented signals into column format
time = [xM];
Acell = num2cell(time, [2 1]);
Acell = reshape(Acell, size(time, 3), 1);
desired_ECG = cell2mat(Acell);
desired_ECG = desired_ECG';

[row, col] = size(desired_ECG);
mean_features = [];

for p = 1:col
    ecg = desired_ECG(:, p) - mean(desired_ECG(:, p));
    signal = highpass(ecg, 0.5, 1000);  % Remove baseline wander
    signal = bandstop(signal, [49 51], 1000);  % Remove 50 Hz noise

    fs = 1000;
    N = length(signal);
    time = (0:N-1)/fs;
    nhaf = fix(N/2);
    frequency = ((0:1:nhaf)*fs/N);

    % Apply Stockwell Transform
    ST = stran(signal');

    % Define 4 frequency bands
    bands = [0 5; 5 15; 15 40; 40 100];
    num_bands = size(bands, 1);
    means = zeros(1, num_bands);

    for i = 1:num_bands
        band_mask = (frequency >= bands(i, 1)) & (frequency <= bands(i, 2));
        band_signal = abs(ST(band_mask, :));
        means(i) = mean(band_signal(:));
    end

    mean_features(p, :) = means;
end

% Define headers: m-f1 to m-f4
headers = strcat("m-f", string(1:num_bands));
output_data = [headers; num2cell(mean_features)];

% Write to Excel
xlswrite('IMISpectral_ST_MeanFeatures.xlsx', output_data);

disp('Stockwell transform mean feature extraction and Excel writing complete.');
