% function z_vector = obfLP(approx_idx, distance_matrix, cost_matrix, NR_LOC, EPSILON)
function [obfuscationMatrix] = obfConstOPT(df_nodes, cost_matrix, EPSILON, NR_CANDIDATE)

    % approx_idx = find(approx_idx == top_idx_list); 
    % NR_TASK_LOC = size(task_idx, 2); 
%% Input

%% Output
%% Calculate the distance_matrix

    % top_loc_list = df_nodes(top_idx_list, 2:3); 
    % top_loc_list = top_loc_list{:,:}; 

    distance_matrix = sparse(NR_CANDIDATE, NR_CANDIDATE); 
    for i = 1:1:NR_CANDIDATE
        for j = 1:1:NR_CANDIDATE
            loc_1 = df_nodes(i, 2:3); 
            loc_2 = df_nodes(j, 2:3); 
            loc_1 = loc_1{1, :};
            loc_2 = loc_2{1, :};

            [distance_matrix(i, j),~,~] = haversine(loc_1, loc_2); 
        end
    end


    %% Create the matrix for the Geo-indistinguishability constraints
    GeoI = sparse(NR_CANDIDATE*NR_CANDIDATE*(NR_CANDIDATE-1), NR_CANDIDATE*NR_CANDIDATE+NR_CANDIDATE); 
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
    f = zeros(1, NR_CANDIDATE*NR_CANDIDATE+NR_CANDIDATE); 
    for i = 1:1:NR_CANDIDATE
        for k = 1:1:NR_CANDIDATE
            f((i-1)*NR_CANDIDATE + k) = cost_matrix(i, k)+0.05; 
        end
    end

    %% Create the matrix for the probability unit measure constraints
    A_um = zeros(NR_CANDIDATE, NR_CANDIDATE*NR_CANDIDATE+NR_CANDIDATE);
    for i = 1:1:NR_CANDIDATE
        for j = 1:1:NR_CANDIDATE
            A_um(i, (i-1)*NR_CANDIDATE + j) = 1;
        end
    end  

    b_um = ones(NR_CANDIDATE, 1);

    for i = 1:1:NR_CANDIDATE
        for j = 1:1:NR_CANDIDATE
            A_Y((i-1)*NR_CANDIDATE + j, (i-1)*NR_CANDIDATE + j) = 1;
            A_Y((i-1)*NR_CANDIDATE + j, NR_CANDIDATE*NR_CANDIDATE + j) = -exp(EPSILON*distance_matrix(i, j));
        end
        
    end  
    b_Y = zeros(NR_CANDIDATE*NR_CANDIDATE, 1);  


    %% Upper bound and lower bound of the decision variables
    lb = zeros(NR_CANDIDATE*NR_CANDIDATE + NR_CANDIDATE, 1);
    ub = ones(NR_CANDIDATE*NR_CANDIDATE + NR_CANDIDATE, 1);
     

    [z, pfval, exitflag] = linprog(f, [GeoI; -A_um], [b_GeoI; -b_um], A_Y, b_Y, lb, ub);

    obfuscationMatrix = reshape(z(1:NR_CANDIDATE*NR_CANDIDATE, 1), NR_CANDIDATE, NR_CANDIDATE);
    % if exitflag ~= 1
    %     options = optimoptions('linprog','Algorithm','interior-point','Display','off');
    %     [z, pfval, exitflag] = linprog(f, [GeoI; -A_um], [b_GeoI; -b_um], A_Y, b_Y, lb, ub, options);
    % end
    % 
    % if exitflag ~= 1
    %     [z_vector, obfuscationMatrix, distance_matrix] = obfLaplace(top_idx_list, top_idx_list(1, approx_idx), df_nodes, EPSILON, NR_CANDIDATE);
    % 
    % else
    %     obfuscationMatrix = reshape(z(1:NR_CANDIDATE*NR_CANDIDATE, 1), NR_CANDIDATE, NR_CANDIDATE);
    %     obfuscationMatrix = obfuscationMatrix'; 
    %     z_vector = obfuscationMatrix(approx_idx, :); 
    %     scatter(top_loc_list(:, 1), top_loc_list(:, 2), [], z_vector, "filled"); 
    % end





end