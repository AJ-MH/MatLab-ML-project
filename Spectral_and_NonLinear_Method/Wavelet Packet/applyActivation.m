function H = applyActivation(H, activation_function)
    switch activation_function
        case 'sigmoid'
            H = 1 ./ (1 + exp(-H));
        case 'tanh'
            H = tanh(H);
        case 'relu'
            H = max(0, H);
        case 'wavelet'
            H = cos(1.75 * H) .* exp(-H.^2);
        case 'sine'
            H = sin(H);
        otherwise
            error('Unknown activation function');
    end
end