function SE = SampleEntropy(signal, m, r)
    % Compute Sample Entropy
    % signal: Input time series
    % m: Embedding dimension
    % r: Tolerance level

    % Ensure signal is a column vector
    signal = signal(:);
    
    N = length(signal);
    
    % Check if signal is too short
    if N < m + 1
        SE = NaN;
        return;
    end

    % Create embedding matrix
    patterns = zeros(N - m, m);
    for i = 1:(N - m)
        patterns(i, :) = signal(i:i + m - 1);
    end
    
    % Compute Chebyshev distance manually
    d = max(abs(patterns - permute(patterns, [3, 2, 1])), [], 2);
    d = squeeze(d);  % Remove singleton dimensions
    
    % Count similar patterns
    A = sum(d < r, 2) - 1;  
    B = sum(A) / max((N - m), 1);  % Avoid division by zero
    
    % Avoid log(0) by ensuring B is positive
    B = max(B, eps);  

    % Compute Sample Entropy
    SE = -log(B / (N - m - 1 + eps));

    % Ensure the output is real
    SE = real(SE);
end
