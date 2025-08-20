% function de = DispersionEntropy(x, m, c, tau)
%     N = length(x);
%     y = (x - mean(x)) / std(x);
%     edges = linspace(min(y), max(y), c+1);
%     classes = discretize(y, edges);
% 
%     L = N - (m - 1) * tau;
%     pattern = zeros(L, m);
%     for i = 1:m
%         pattern(:, i) = classes((1:L) + (i - 1) * tau);
%     end
% 
%     valid_rows = all(~isnan(pattern), 2);
%     pattern = pattern(valid_rows, :);
%     patterns_str = str2num(num2str(pattern)); %#ok<ST2NM>
%     [~, ~, idx] = unique(patterns_str, 'rows');
%     p = histcounts(idx, 1:max(idx)+1, 'Normalization', 'probability');
%     de = -sum(p .* log(p + eps));
% end

function de = DispersionEntropy(x, m, c, tau)
    N = length(x);

    % Avoid division by zero
    if std(x) == 0
        de = 0;
        return;
    end

    % Normalize and rescale
    y = (x - mean(x)) / std(x);

    % Define bin edges and ensure they're strictly increasing
    edges = linspace(min(y), max(y), c + 1);

    % If edges are not strictly increasing (i.e., flat signal), return 0
    if length(unique(edges)) < length(edges)
        de = 0;
        return;
    end

    % Discretize signal into c classes
    classes = discretize(y, edges);

    % Form embedded vectors
    L = N - (m - 1) * tau;
    if L <= 0
        de = 0;
        return;
    end

    pattern = zeros(L, m);
    for i = 1:m
        idx = (1:L) + (i - 1) * tau;
        if max(idx) > N
            de = 0;
            return;
        end
        pattern(:, i) = classes(idx);
    end

    % Remove rows with NaNs (may occur due to discretization issues)
    pattern(any(isnan(pattern), 2), :) = [];

    if isempty(pattern)
        de = 0;
        return;
    end

    % Convert to unique string-based patterns
    patterns_str = str2num(num2str(pattern)); %#ok<ST2NM>
    [~, ~, idx] = unique(patterns_str, 'rows');
    p = histcounts(idx, 1:max(idx)+1, 'Normalization', 'probability');

    % Compute entropy
    de = -sum(p .* log(p + eps));
end
