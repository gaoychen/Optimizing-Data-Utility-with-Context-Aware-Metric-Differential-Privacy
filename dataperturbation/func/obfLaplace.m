function [z_vector, obfuscationMatrix, distance_matrix, approx_idx_target] = obfLaplace(top_idx_list, approx_id, df_nodes, EPSILON, NR_CANDIDATE)
%% Description:
    % The obfmatrix_generator_laplace is function which generate the
    % obfuscaed location vector
%% Input
    % top_loc_list: Actual x and y coordinate from the openstreet map data
    % i: location on which obfuscation will happen
    % EPSILON: randomized value
    % NR_CANDIDATE: total number of nodes

%% Output
    % z_vector: obfuscation vector for that node
%%
    approx_idx_target = find(approx_id == top_idx_list); 

    distance_matrix = zeros(NR_CANDIDATE, NR_CANDIDATE); 
    for i = 1:1:NR_CANDIDATE
        for j = 1:1:NR_CANDIDATE
            loc_1 = df_nodes(i, 2:3); 
            loc_2 = df_nodes(j, 2:3); 
            loc_1 = loc_1{1, :};
            loc_2 = loc_2{1, :};

            [distance_matrix(i, j),~,~] = haversine(loc_1, loc_2); 
        end
    end

    top_loc_list = df_nodes(top_idx_list, 2:3); 
    top_loc_list = top_loc_list{:,:}; 

    obfuscationMatrix = zeros(NR_CANDIDATE, NR_CANDIDATE);
    for i = 1:1:NR_CANDIDATE
        for j = 1:1:NR_CANDIDATE
            obfuscationMatrix(i, j) = exp(-distance_matrix(i,j)*EPSILON/2);        % changed i to 1
        end
        obfuscationMatrix(i, :) = obfuscationMatrix(i, :)/sum(obfuscationMatrix(i, :));            %changed i to 1
    end
    
    z_vector = obfuscationMatrix(approx_idx_target, :);  %changed i to 1
    % scatter(top_loc_list(:, 1), top_loc_list(:, 2), [], z_vector, "filled"); 


%     %% Measure the expected errors
%     [~, D] = shortestpathtree(G, PATIENT);
%     overallcost = 0; 
%     for i = 1:1:NR_CANDIDATE
%         for j = 1:1:NR_CANDIDATE
%             approx_distance = sqrt((top_loc_list(j, 1) - top_loc_list(PATIENT, 1))^2 + (top_loc_list(j, 2) - top_loc_list(PATIENT, 2))^2 + (top_loc_list(j, 3) - top_loc_list(PATIENT, 3))^2); 
%             distance_error = abs(approx_distance - D(i)); 
%             costMatrix(i, j) = distance_error; 
%             overallcost = overallcost + distance_error * z(i, j);
%         end
%     end
%     overallcost = overallcost/NR_CANDIDATE; 
%     cost_distribution = cost_error_distribution(z, costMatrix, NR_CANDIDATE); 
end
