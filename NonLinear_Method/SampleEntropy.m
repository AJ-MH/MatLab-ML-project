function [sampen, count] = SampleEntropy(x, varargin)
    % Default parameters
    m = 2; r = 0.2 * std(x); tau = 1;

    % Parse optional name-value pairs
    for k = 1:2:length(varargin)
        switch lower(varargin{k})
            case 'm', m = varargin{k+1};
            case 'r', r = varargin{k+1};
            case 'tau', tau = varargin{k+1};
        end
    end

    N = length(x);
    xm = zeros(N - (m-1)*tau, m);
    for i = 1:size(xm,1)
        xm(i,:) = x(i:tau:i+(m-1)*tau);
    end
    count = zeros(1,2);
    for dim = m:m+1
        X = zeros(N - (dim-1)*tau, dim);
        for i = 1:size(X,1)
            X(i,:) = x(i:tau:i+(dim-1)*tau);
        end
        D = pdist2(X, X, 'chebychev');
        D = D - diag(diag(D));
        count(dim-m+1) = sum(D <= r, 'all') / (size(D,1)*(size(D,1)-1));
    end
    sampen = -log(count(2)/count(1));
end
