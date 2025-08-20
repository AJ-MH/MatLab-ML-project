clc;
close all;
clear all;

% Specify the folder containing .mat files
folderPath = 'C:\Users\AJ\Downloads\Kan_AJ\MatLab Simulations\NonLinear_Method\1_RawECG_to_Features\HealthControl_Without_Normalization\HealthControl_mat_all_files';
mat_files = dir(fullfile(folderPath, '*.mat'));

% Initialize data storage
xM = [];

for k = 1:length(mat_files)
    % Load the .mat file
    file_name = fullfile(folderPath, mat_files(k).name);
    load(file_name); % Load ECG data
    
    % Extract ECG signal safely
    d = val(2, 1:min(40000, size(val, 2)));  

    % Preprocessing
    xV = d - mean(d); % Remove DC component
    fs = 1000; % Sampling frequency
    xV = highpass(xV, 0.5, fs); % Remove baseline wander
    xV = bandstop(xV, [49 51], fs); % Remove 50 Hz noise
    
    % Segmentation
    n = 2000; % Window length
    s = n; % Step size
    segmented_signal = Divide_RR_sample(xV, n, s);
    
    if k == 1
        xM = zeros(size(segmented_signal, 1), size(segmented_signal, 2), length(mat_files));
    end
    common_cols = min(size(xM, 2), size(segmented_signal, 2));
    xM(:, 1:common_cols, k) = segmented_signal(:, 1:common_cols);
end

% Convert to 2D matrix: each column is one ECG segment
time = [xM];
Acell = num2cell(time, [2 1]);
Acell = reshape(Acell, size(time,3), 1);
desired_ECG = cell2mat(Acell)';
[row, col] = size(desired_ECG);
col=5;
% Initialize feature storage
features = zeros(col, 6);

for p = 1:col
    signal = desired_ECG(:, p);
    % 1. Sample Entropy
    r_val = max(0.2 * std(signal), 1e-8);
    [Samp, ~] = SampleEntropy(signal, 'm', 2, 'tau', 1, 'r', r_val);
    features(p, 1) = Samp(1);

    % 2. Bubble Entropy
    [Bubb, ~] = BubbleEntropy(signal, 'm', 2, 'tau', 1, 'Logx', exp(1));
    features(p, 2) = Bubb(1);

    % 3. Renyi Entropy
    alpha = 2;
    features(p, 3) = RenyiEntropy(signal, alpha);

    % 4. Dispersion Entropy
    m = 2; c = 6; tau = 1;
    features(p, 4) = DispersionEntropy(signal, m, c, tau);

    % 5. Lempel-Ziv Entropy
    bin_sig = signal > mean(signal); % Binary version
    features(p, 5) = lzentropy(bin_sig);

    % 6. Kolmogorov-Sinai Entropy
    features(p, 6) = kolmogorov(bin_sig);
end

% Column headers
headers = {'Sample Entropy', 'Bubble Entropy', 'Renyi Entropy', ...
           'Dispersion Entropy', 'Lempel-Ziv Entropy', 'Kolmogorov-Sinai Entropy'};

% Save to Excel
filename = 'HealthControl_AllEntropy_Features.xlsx';
xlswrite(filename, [headers; num2cell(features)]);

disp('All entropy features extracted and saved to Excel.');
