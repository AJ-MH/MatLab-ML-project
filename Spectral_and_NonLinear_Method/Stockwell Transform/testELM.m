function Y_pred = testELM(X, InputWeight, BiasofHiddenNeurons, OutputWeight, activation_function)
    % Calculate hidden layer output
    H = applyActivation(X * InputWeight + BiasofHiddenNeurons, activation_function);

    % Calculate output layer output
    Y_pred_scores = H * OutputWeight;

    % Predict class labels
    [~, Y_pred] = max(Y_pred_scores, [], 2);
end
