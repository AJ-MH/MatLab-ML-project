function H = RenyiEntropy(signal, alpha)
    signal = signal - min(signal);
    signal = signal / max(signal);
    nbins = 100;
    p = histcounts(signal, nbins, 'Normalization', 'probability');
    p = p(p > 0);
    H = 1 / (1 - alpha) * log(sum(p.^alpha));
end
