clc;
clear all;
close all;

% Specify the folder containing .mat files
folderPath = 'C:\Users\AJ\Downloads\Kan_AJ\MatLab Simulations\Wavelet Packet\1_RawECG_to_Features\MI_Without_Normalization\InferiorMI_Without_Normalization\Inferior MI_Dataset_mat_all_files';

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
    s = n;  % Step size
    % Get the segmented signal
    segmented_signal = Divide_RR_sample(xV, n, s);
    
    % Ensure consistent size before assigning to xM
    if k == 1
        % Initialize xM based on the first file's size
        xM = zeros(size(segmented_signal, 1), size(segmented_signal, 2), length(mat_files));
    end
    % Ensure the column size is consistent with the first file
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
entropy_features = [];

for p = 1:col
    ecg = desired_ECG(:, p) - mean(desired_ECG(:, p));  % Remove mean (DC component)
    signal = ecg;
    
    % Wavelet Packet Decomposition (WPD) Parameters
    wavelet_name = 'db4';  % Daubechies wavelet
    level = 3;  % Decomposition level

    % Perform WPD decomposition
    wp_tree = wpdec(signal, level, wavelet_name);
    
    % Get all nodes at the final level
    node_indices = allnodes(wp_tree);  % Get all nodes from levels 1, 2, and 3
    num_nodes = length(node_indices);

    % Initialize entropy arrays
    bubble_entropies = zeros(1, num_nodes); 
    sample_entropies = zeros(1, num_nodes); 
    
    for i = 1:num_nodes
        node_signal = wpcoef(wp_tree, node_indices(i));  % Extract coefficients for each node
        node_signal = node_signal / max(abs(node_signal));  % Normalize
        
        % Compute Bubble Entropy
        bubble_entropies(i) = BubbleEntropy(node_signal, 2, 0.2 * std(node_signal));

        % Compute Sample Entropy
        sample_entropies(i) = SampleEntropy(real(node_signal), 2, 0.2 * std(real(node_signal)));
    end

    % Store entropy features
    entropy_features(p, :) = [bubble_entropies, sample_entropies];
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

% Store features in Excel separately for Bubble and Sample Entropy
% Define column headers dynamically based on WPD nodes
headers = strcat("Node_", string(1:num_nodes));  

% Convert numerical data to a cell array
bubble_entropy_data = num2cell(entropy_features(:, 1:num_nodes));
sample_entropy_data = num2cell(entropy_features(:, num_nodes+1:end));

% Create a full-sized cell array with the entropy type centered at the top
bubble_entropy_final = [['Bubble Entropy', repmat({''}, 1, size(headers, 2) - 1)]; headers; bubble_entropy_data];
sample_entropy_final = [['Sample Entropy', repmat({''}, 1, size(headers, 2) - 1)]; headers; sample_entropy_data];

% Write to Excel
xlswrite('InferiorMI_UnNormalized_BubbleEntropyWPD_Features.xlsx', bubble_entropy_final);
xlswrite('InferiorMI_UnNormalized_SampleEntropyWPD_Features.xlsx', sample_entropy_final);

disp('Feature extraction and Excel file writing complete.');
