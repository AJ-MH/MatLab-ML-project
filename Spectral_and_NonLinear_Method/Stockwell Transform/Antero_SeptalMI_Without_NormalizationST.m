 clc
 clf
 close all
 clear all

 % Specify the folder containing .mat files
folderPath = 'C:\Users\AJ\Downloads\Kan_AJ\MatLab Simulations\Spectral_and_NonLinear_Method\Stockwell Transform\1_RawECG_to_Features\1_Without_Normalization_Features\MI_Without_Normalization\Antero_SeptalMI_Without_Normalization\sample_mat_files'; % Change this to your actual folder path
mat_files = dir(fullfile(folderPath, '*.mat'));

% Initialize data storage
%xM = [];

% for k = 1:length(mat_files)
%     % Load the .mat file
%     file_name = fullfile(folderPath, mat_files(k).name);
%     load(file_name); % Load ECG data
%     d = val(2, 1:min(40000, size(val, 2))); 
% %     d= d./max(d);
% xV=d; 
% n=2000;
% s=n;
% xM(:,:,k) = Divide_RR_sample(xV,n,s);
%  end

expected_cols = 20; % Define expected number of segments

for k = 1:length(mat_files)
    file_name = fullfile(folderPath, mat_files(k).name);
    load(file_name);
    d = val(2, 1:min(40000, size(val, 2)));
    xV = d;
    n = 2000;
    s = n;

    result = Divide_RR_sample(xV,n,s);

    % Only assign if it matches the expected size
    if size(result, 1) == 2000 && size(result, 2) == expected_cols
        xM(:,:,k) = result;
    else
        fprintf('Skipping file %s due to unexpected output size: %dx%d\n', ...
            mat_files(k).name, size(result,1), size(result,2));
    end
end


time=[xM];
Acell = num2cell(time,[2 1]); % put each page of A into a cell
Acell = reshape(Acell,size(time,3),1); %make the cell array a vector
desired_ECG = cell2mat(Acell);
desired_ECG=desired_ECG';
[row,col]=size(desired_ECG);
%col = 700;
entropy_samp=[];
for p=1:col
ecg=desired_ECG(:,p)-mean(desired_ECG(:,p));
signal = ecg; % Replace with the actual variable name
fs = 1000; % Sampling frequency (adjust to match your data)
N = length(signal); % Length of the signal
time = (0:N-1)/ fs; % Time vector
nhaf=fix(N/2);
frequency = ((0:1:nhaf)*fs/N);
% Example preprocessing
signal = highpass(signal, 0.5, fs); % Remove baseline wander
signal = bandstop(signal, [49 51], fs); % Remove 50 Hz noise
[ST]=stran(signal');

%% Calculate Entropies
bands = [0 5; 5 15; 15 40; 40 100]; % Adjust bands as needed
num_levels = size(bands, 1);
sample_entropies = zeros(1, num_levels);
bubble_entropies=zeros(1, num_levels);


for i = 1:num_levels
    % Extract frequency band
    band_mask = (frequency >= bands(i, 1)) & (frequency <= bands(i, 2));
    band_signal = ST(band_mask, :);
    signal_segment = abs(band_signal(:)); % Flatten the band signal
    % Compute Sample Entropy
    % Samp = SampEn(signal_segment(1:10000),'m', 2, 'tau', 1, 'r',
    % 0.2*std(signal_segment(1:10000))); gave the error: The value of 'r' is invalid. It must satisfy the function: @(x)isscalar(x)&&(x>0).
    
    seg = signal_segment(1:10000);
    r_val = max(0.2 * std(seg), 1e-6);  % Ensure r is always > 0
    Samp = SampEn(seg, 'm', 2, 'tau', 1, 'r', r_val);
    sample_entropies(i)= Samp(1);
    Bubbleentropy = BubbleEntropy(signal_segment, 'm', 2, 'tau', 1, 'Logx', exp(1));
    bubble_entropies(i) = Bubbleentropy;
      
end

sample_entropy_features(p,:)=sample_entropies;
bubble_entropy_features(p,:)=bubble_entropies;
end

% Entropy_features_samp=entropy_samp;
% Entropy_features_bubb=entropy_bubb; 
% [row,col]=size(Entropy_features);
% for i = 1 : col
% Entropy_features_norm(:,i)=(Entropy_features(:,i) - min(Entropy_features(:,i)))./(max(Entropy_features(:,i)) - min(Entropy_features(:,i)));
% end
% Entropy_norm_features=Entropy_features_norm;

% Save features in Excel
bubble_entropy_file = 'ASMIUnNormalized_BubbleEntropy_Features.xlsx';
sample_entropy_file = 'ASMIUnNormalized_SampleEntropy_Features.xlsx';

headers = strcat("Band_", string(1:num_levels));  

% Convert numerical data to cell array
bubble_entropy_data = num2cell(bubble_entropy_features);
sample_entropy_data = num2cell(sample_entropy_features);

% Create full-sized cell arrays with headers
bubble_entropy_final = [['Bubble Entropy', repmat({''}, 1, num_levels - 1)]; headers; bubble_entropy_data];
sample_entropy_final = [['Sample Entropy', repmat({''}, 1, num_levels - 1)]; headers; sample_entropy_data];

% Write to Excel
writematrix(bubble_entropy_file, bubble_entropy_final);
writematrix(sample_entropy_file, sample_entropy_final);

disp('Feature extraction and Excel file writing complete.');