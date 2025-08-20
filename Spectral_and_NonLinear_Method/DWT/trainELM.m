function [InputWeight, BiasofHiddenNeurons, OutputWeight] = trainELM(X, Y, hidden_neurons, activation_function)
    % Prepare one-hot encoding for Y
    classes = unique(Y);
    T = zeros(length(Y), length(classes));
    for i = 1:length(classes)
        T(Y == classes(i), i) = 1;
    end

    % Initialize weights and biases
    InputWeight = rand(size(X, 2), hidden_neurons) * 2 - 1;
    BiasofHiddenNeurons = rand(1, hidden_neurons);

    % Calculate hidden layer output
    H = applyActivation(X * InputWeight + BiasofHiddenNeurons, activation_function);

    % Calculate output weights
    OutputWeight = pinv(H) * T;
end