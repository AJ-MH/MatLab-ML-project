clc;
%clf;
close all;
clear all;

% Specify the folder containing .mat files
folderPath = 'C:\Users\AJ\Downloads\Kan_AJ\MatLab Simulations\Stockwell Transform\1_RawECG_to_Features\HealthControl_Without_Normalization\HealthControl_mat_all_files'; % Change this to your actual folder path
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
    
    % Ensure consistent size before assigning to xM
    if k == 1
        % Initialize xM based on the first file's size
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
bubble_entropy_features = [];
sample_entropy_features = [];

for p = 1:col
    ecg = desired_ECG(:, p) - mean(desired_ECG(:, p)); % Remove mean (DC component)
    signal = ecg;
    
    % Perform Stockwell Transform using 'stran' function (as in your original code)
    ST = stran(signal');

    % Define frequency bands
    bands = [0 5; 5 15; 15 40; 40 100]; % Adjust as needed
    num_levels = size(bands, 1);
    
    % Initialize entropy storage
    bubble_entropies = zeros(1, num_levels); 
    sample_entropies = zeros(1, num_levels); 

    for i = 1:num_levels
        % Extract frequency band
        band_signal = ST(bands(i, 1)+1:bands(i, 2)+1, :); % Select corresponding frequency range

        % Flatten signal for entropy computation
        signal_segment = abs(band_signal(:));

        % Compute Entropies
        [Bubb, ~] = BubbleEntropy(signal_segment(1:5000), 'm', 2, 'tau', 1, 'Logx', exp(1));
        bubble_entropies(i) = Bubb(1);
        r_val = max(0.2 * std(signal_segment(1:5000)), 1e-8);
        [Samp, ~] = SampleEntropy(signal_segment(1:5000), 'm', 2, 'tau', 1, 'r', r_val);
        sample_entropies(i) = Samp(1);

    end

    % Store entropy features
    bubble_entropy_features(p, :) = bubble_entropies;
    sample_entropy_features(p, :) = sample_entropies;
end
% Normalize Entropy Features
% [row, col] = size(entropy_features);
% entropy_features_norm = zeros(size(entropy_features));
% 
% for i = 1:col
%     entropy_features_norm(:,i) = (entropy_features(:,i) - min(entropy_features(:,i))) ./ ...
%                                  (max(entropy_features(:,i)) - min(entropy_features(:,i)));
% end
% 
% Entropy_norm_features = entropy_features_norm;

% Save features in Excel
bubble_entropy_file = 'HealthControlUnNormalized_BubbleEntropy_Features.xlsx';
sample_entropy_file = 'HealthControlUnNormalized_SampleEntropy_Features.xlsx';

headers = strcat("Band_", string(1:num_levels));  

% Convert numerical data to cell array
bubble_entropy_data = num2cell(bubble_entropy_features);
sample_entropy_data = num2cell(sample_entropy_features);

% Create full-sized cell arrays with headers
bubble_entropy_final = [['Bubble Entropy', repmat({''}, 1, num_levels - 1)]; headers; bubble_entropy_data];
sample_entropy_final = [['Sample Entropy', repmat({''}, 1, num_levels - 1)]; headers; sample_entropy_data];

% Write to Excel
xlswrite(bubble_entropy_file, bubble_entropy_final);
xlswrite(sample_entropy_file, sample_entropy_final);

disp('Feature extraction and Excel file writing complete.');
