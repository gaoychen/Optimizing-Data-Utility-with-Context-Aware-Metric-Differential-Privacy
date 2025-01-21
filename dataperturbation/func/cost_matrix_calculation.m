function [cost_matrix, cost_matrix_noMB, cost_matrix_MB] = cost_matrix_calculation(G, top_idx_list, task_idx, loc_frequency_noMB, loc_frequency_MB, NR_LOC, NR_CANDIDATE, NR_TASK_LOC)
    cost_matrix_MB = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 
    cost_matrix_noMB = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 
    cost_matrix = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 

    NR_VEHICLE = 5;
    available_vehicle_loc = randperm(NR_CANDIDATE, NR_VEHICLE);
    
    for k = 1:1:NR_LOC
        k
        for i = 1:1:NR_CANDIDATE  
            for l = 1:1:NR_TASK_LOC
                [~, travel_distance(i, l)] = shortestpath(G, top_idx_list(k, i), task_idx(1, l));
            end
        end

         
        for i = 1:1:NR_CANDIDATE
            for j = 1:1:NR_CANDIDATE
                real_loc = i; 
                fake_loc = j; 



                for l = 1:1:NR_TASK_LOC
                    [~, min_idx_real] = min(travel_distance([available_vehicle_loc, real_loc], l));
                    [~, min_idx_fake] = min(travel_distance([available_vehicle_loc, fake_loc], l));
                    if min_idx_real ~= min_idx_fake
                        utility_loss = 1; 
                    else 
                        utility_loss = 0;
                    end
                    cost_matrix(k, i, j) = cost_matrix(k, i, j) + utility_loss/NR_TASK_LOC;
                    cost_matrix_noMB(k, i, j) = cost_matrix_noMB(k, i, j) + loc_frequency_noMB(k, top_idx_list(k, i))*utility_loss/NR_TASK_LOC; 
                    cost_matrix_MB(k, i, j) = cost_matrix_MB(k, i, j) + loc_frequency_MB(k, top_idx_list(k, i))*utility_loss/NR_TASK_LOC; 
                end          
            end
        end    
    end
end