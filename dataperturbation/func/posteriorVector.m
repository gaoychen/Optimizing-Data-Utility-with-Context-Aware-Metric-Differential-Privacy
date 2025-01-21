function posterior_vector = posteriorVector(z_vector, prior_vector, obfuscationMatrix)
    posterior_vector = zeros(1, size(z_vector, 2)); 

    z_vector_sum = cumsum(z_vector);
    z_vector_sum = [0 z_vector_sum]; 
    seed = rand; 
    obf_id = 0; 
    for i = 1:1:size(z_vector, 2)
        if z_vector_sum(1, i) <= seed && z_vector_sum(1, i+1) > seed
            obf_id = i; 
        end
    end
    for i = 1:1:size(z_vector, 2)
        numeractor = prior_vector(1, i)*obfuscationMatrix(i, obf_id); 
        denominator = 0; 
        for j = 1:1:size(z_vector, 2)
            denominator = denominator + prior_vector(1, j)*obfuscationMatrix(j, obf_id); 
        end
        posterior_vector(1, i) = numeractor/denominator; 
    end
end