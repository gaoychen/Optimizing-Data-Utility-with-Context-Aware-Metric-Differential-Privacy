function estimated_loc = BayesianAttack(obfuscationMatrix, perturbed_loc)
    posterior_distribution = zeros(size(obfuscationMatrix, 1), 1); 
    denominator = sum(obfuscationMatrix(:, perturbed_loc)); 
    for i = 1:1:size(obfuscationMatrix, 1) 
        numerator = obfuscationMatrix(i, perturbed_loc); 
        posterior_distribution(i, 1) = numerator/denominator; 
    end
    [~, estimated_loc] = max(posterior_distribution); 
end