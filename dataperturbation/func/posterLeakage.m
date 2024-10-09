function [maxPL, meanPL] = posterLeakage(posterior_vector, prior_vector, distance_matrix)
    PL = zeros(size(posterior_vector, 2), size(posterior_vector, 2)); 
    for i = 1:1:size(posterior_vector, 2)
        for j = 1:1:size(posterior_vector, 2)
            if prior_vector(1, j) > 0 && posterior_vector(1, j) > 0
                prior_ratio = prior_vector(1, i)/prior_vector(1, j);
                posterior_ratio = posterior_vector(1, i)/posterior_vector(1, j);
                if prior_ratio > 0 
                    if i ~= j 
                        PL(i, j) = abs(log(posterior_ratio/prior_ratio)/distance_matrix(i, j)); 
                    else
                        PL(i, j) = 0; 
                    end
                end
            end
        end
    end
    meanPL = mean(mean(PL)); 
    maxPL = max(max(PL)); 
end