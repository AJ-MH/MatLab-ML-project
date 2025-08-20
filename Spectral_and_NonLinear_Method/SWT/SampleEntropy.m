function SE = SampleEntropy(signal, m, r)
    % Compute Sample Entropy
    % signal: Input time series
    % m: Embedding dimension
    % r: Tolerance level

    N = length(signal);
    patterns = zeros(N - m, m);
    
    % Create embedding matrix
    for i = 1:(N - m)
        patterns(i, :) = signal(i:i + m - 1);
    end
    
    % Compute Chebyshev distance manually (Fixing the 'chebyshev' error)
    d = max(abs(patterns - permute(patterns, [3,2,1])), [], 2);
    d = squeeze(d);  % Remove singleton dimensions
    
    % Count similar patterns
    A = sum(d < r, 2) - 1;
    B = sum(A) / (N - m);

    % Compute Sample Entropy
    SE = -log(B / (N - m - 1 + eps));  % Avoid log(0)
end
