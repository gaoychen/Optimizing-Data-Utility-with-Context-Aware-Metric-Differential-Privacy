function [maxPL, meanPL, expected_inference_error, success_rate, success_rate_, expected_utility_loss] ...
    = performance_evaluation(z_vector, obfuscationMatrix, distance_matrix, approx_idx_target, cost_matrix, loc_frequency_noprior, top_loc_list, i)
    
    posterior_vector = posteriorVector(z_vector, loc_frequency_noprior, obfuscationMatrix); 
    %Posterior Leakage
    [maxPL, meanPL] = posterLeakage(posterior_vector, loc_frequency_noprior, distance_matrix); 

    % Expected inference error and inference success rate
    expected_inference_error = 0; 
    success_rate = 0; 
    success_rate_ = 0; 

    % This part is used to generate perturbed location and the
    % corresponding posterior distribution
    SAMPLE_SIZE = 100000;
    for k = 1:1:100000
        perturbed_loc = perturbedLocationGenerator(z_vector); 
        estimated_loc = BayesianAttack(obfuscationMatrix, perturbed_loc);

        if estimated_loc == approx_idx_target
            success_rate = success_rate + 1;
        end

        [inference_error_instance, ~, ~] = haversine(top_loc_list(estimated_loc, :), top_loc_list(approx_idx_target, :)); 
        
        if inference_error_instance < 0.05
            success_rate_ = success_rate_ + 1;
        end

        expected_inference_error = expected_inference_error + inference_error_instance;
    end
    success_rate = success_rate/SAMPLE_SIZE; 
    success_rate_ = success_rate_/SAMPLE_SIZE; 
    expected_inference_error = expected_inference_error/SAMPLE_SIZE;  
    expected_utility_loss = sum(squeeze(cost_matrix(i, approx_idx_target, :))'.*z_vector); 
    
end