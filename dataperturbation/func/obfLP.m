% function z_vector = obfLP(approx_idx, distance_matrix, cost_matrix, NR_LOC, EPSILON)


function [z_vector, obfuscationMatrix, distance_matrix, approx_idx_target, compute_time] = obfLP(top_idx_list, approx_idx, df_nodes, task_idx, cost_matrix, EPSILON, NR_CANDIDATE)

    approx_idx_target = find(approx_idx == top_idx_list); 
    NR_TASK_LOC = size(task_idx, 2); 
%% Input
% UL_matrix: Utility loss matrix, each UL(i, k) represents the utility loss
% caused by the obfuscated location k given the real location i
% distance_matrix: each distance_matrix(i, j) represents the Haversine
% distance between location i and location j
% EPSILON: the privacy budget
%% Output
% the obfuscation matrix 

    %% Calculate the distance_matrix
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

    %% Calculate the cost_matrix
    % cost_matrix = zeros(NR_CANDIDATE, NR_CANDIDATE); 
    % for i = 1:1:NR_CANDIDATE
    %     for j = 1:1:NR_CANDIDATE
    %         for l = 1:1:NR_TASK_LOC     
    %             [~, travel_cost_instance_] = shortestpath(G, top_idx_list(1, l), task_idx(1, l)); 
    %             cost_matrix(i, j) = cost_matrix(i, j) + travel_cost_instance_/NR_TASK_LOC; 
    %         end          
    %     end
    % end    


    %% Create the matrix for the Geo-indistinguishability constraints
    GeoI = sparse(NR_CANDIDATE*NR_CANDIDATE*(NR_CANDIDATE-1), NR_CANDIDATE*NR_CANDIDATE); 
    idx = 1; 
    for i = 1:1:NR_CANDIDATE
        for j = i+1:1:NR_CANDIDATE    
            for k = 1:1:NR_CANDIDATE
                GeoI(idx, (i-1)*NR_CANDIDATE + k) = 1;
                GeoI(idx, (j-1)*NR_CANDIDATE + k) = -exp(EPSILON*distance_matrix(i, j));
                idx = idx + 1;
                GeoI(idx, (i-1)*NR_CANDIDATE + k) = -exp(EPSILON*distance_matrix(i, j));
                GeoI(idx, (j-1)*NR_CANDIDATE + k) = 1;
                idx = idx + 1;
            end
        end
    end
    b_GeoI = zeros(NR_CANDIDATE*NR_CANDIDATE*(NR_CANDIDATE-1), 1); 


    %% Create the cost vector for the objective function
    for i = 1:1:NR_CANDIDATE
        for k = 1:1:NR_CANDIDATE
            f((i-1)*NR_CANDIDATE + k) = cost_matrix(i, k); 
        end
    end

    %% Create the matrix for the probability unit measure constraints
    for i = 1:1:NR_CANDIDATE
        for j = 1:1:NR_CANDIDATE
            A_um(i, (i-1)*NR_CANDIDATE + j) = 1;
        end
    end  

    b_um = ones(NR_CANDIDATE, 1);


    %% Upper bound and lower bound of the decision variables
    lb = zeros(NR_CANDIDATE*NR_CANDIDATE, 1);
    ub = ones(NR_CANDIDATE*NR_CANDIDATE, 1);
    % options = optimoptions('linprog','Algorithm','interior-point','Display','off', 'MaxIter', 10000);
    % [z, pfval, exitflag] = linprog(f, GeoI, b_GeoI, A_um, b_um, lb, ub, options);
    tic 
    [z, pfval, exitflag] = linprog(f, GeoI, b_GeoI, A_um, b_um, lb, ub);
    if exitflag ~= 1
        options = optimoptions('linprog','Algorithm','interior-point','Display','off', 'MaxIter', 10000);
        [z, pfval, exitflag] = linprog(f, GeoI, b_GeoI, A_um, b_um, lb, ub, options);
    end
    compute_time = toc; 
    obfuscationMatrix = reshape(z, NR_CANDIDATE, NR_CANDIDATE);
    obfuscationMatrix = obfuscationMatrix'; 

    z_vector = obfuscationMatrix(approx_idx_target, :); 



end