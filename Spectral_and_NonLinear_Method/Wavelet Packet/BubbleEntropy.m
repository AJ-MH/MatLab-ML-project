function BE = BubbleEntropy(signal, m, r)
    % Compute Bubble Entropy
    % signal: Input time series
    % m: Embedding dimension
    % r: Tolerance level

    N = length(signal);
    patterns = zeros(N - m + 1, m);
    
    % Create embedding matrix
    for i = 1:(N - m + 1)
        patterns(i, :) = signal(i:i + m - 1);
    end
    
    % Compute distances between all pattern pairs
    d = pdist2(patterns, patterns, 'euclidean');
    
    % Count similar patterns
    C = sum(d < r, 2) / (N - m + 1);
    
    % Compute Bubble Entropy
    BE = -mean(log(C + eps));  % Avoid log(0)
end
