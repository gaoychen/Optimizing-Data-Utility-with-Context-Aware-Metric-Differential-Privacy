%% main file of CAmDP
addpath('./func/'); 
addpath('./func/haversine/'); 

load('./datasets/Porto/intermediate/loc_frequency_MB.mat'); 
load('./datasets/Porto/intermediate/loc_frequency_noMB.mat'); 


loc_frequency_MB = loc_frequency_MB + 1;
loc_frequency_noMB = loc_frequency_noMB + 1;

loc_frequency_MB_sum = sum(loc_frequency_MB); 
loc_frequency_noMB_sum = sum(loc_frequency_noMB); 

for i = 1:1:size(loc_frequency_MB, 2)
    loc_frequency_MB(:, i) = loc_frequency_MB(:, i)/loc_frequency_MB_sum(1, i); 
    loc_frequency_noMB(:, i) = loc_frequency_noMB(:, i)/loc_frequency_noMB_sum(1, i); 
end


rng(0)
NR_TASK_LOC = 1; 
NR_LOC = 100; 
NR_CANDIDATE = 50; 

ETA = 10; 

load('./datasets/Porto/selected_traj.mat'); 
picked_locations = csvread('./datasets/Porto/picked_locations.csv'); 

opts = detectImportOptions('./datasets/Porto/nodes.csv');
opts = setvartype(opts, 'osmid', 'int64');
df_nodes = readtable('./datasets/Porto/nodes.csv', opts);
df_edges = readtable('./datasets/Porto/edges.csv');

NR_NODES = size(df_nodes, 1); 
task_idx = randperm(NR_NODES, NR_TASK_LOC); 

[G, u, v, timeTaken] = graph_preparation(df_nodes, df_edges);
%% Pre-Processing data: GPS coordinates -> nodes
real_travel_cost = zeros(NR_LOC, 1); 
estimated_travel_cost = zeros(NR_LOC, 1); 
approx_idx = zeros(NR_LOC, 1); 
approx_idx_next = zeros(NR_LOC, 1); 
top_idx_list = zeros(NR_LOC, NR_CANDIDATE); 

% for i = 1:1:NR_LOC
% %     i
%     selectedTraj_instance = selectedTraj(1, i).matrix(:, 1:2); 
%     picked_location = picked_locations(i, :); 
%     approx_idx(i, 1) = approximation(picked_location, df_nodes);
%     top_idx_list(i, :) = topLocations(picked_location, df_nodes, NR_CANDIDATE); 
% 
%     idx_next = findNextLoc(picked_location, selectedTraj_instance); 
%     picked_location_next = selectedTraj_instance(idx_next, :); 
%     approx_idx_next(i, 1) = approximation(picked_location_next, df_nodes); 
% end

%% Pre-Processing data: cost matrix calculation 
load('./datasets/Porto/intermediate/approx_idx.mat'); 
load('./datasets/Porto/intermediate/approx_idx_next.mat'); 
load('./datasets/Porto/intermediate/top_idx_list.mat'); 

cost_matrix_MB = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 
cost_matrix_noMB = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 
cost_matrix = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 
% for k = 1:1:NR_LOC
%     k
%     for i = 1:1:NR_CANDIDATE
%         for j = 1:1:NR_CANDIDATE
%             for l = 1:1:NR_TASK_LOC     
%                 [~, travel_cost_instance_real] = shortestpath(G, top_idx_list(k, i), task_idx(1, l)); 
%                 [~, travel_cost_instance_pert] = shortestpath(G, top_idx_list(k, j), task_idx(1, l));
%                 cost_matrix(k, i, j) = cost_matrix(k, i, j) + abs(travel_cost_instance_real-travel_cost_instance_pert)/NR_TASK_LOC;
%                 cost_matrix_noMB(k, i, j) = cost_matrix_noMB(k, i, j) + loc_frequency_noMB(k, top_idx_list(k, i))*abs(travel_cost_instance_real-travel_cost_instance_pert)/NR_TASK_LOC; 
%                 cost_matrix_MB(k, i, j) = cost_matrix_MB(k, i, j) + loc_frequency_MB(k, top_idx_list(k, i))*abs(travel_cost_instance_real-travel_cost_instance_pert)/NR_TASK_LOC; 
%             end          
%         end
%     end    
% end
load('./datasets/Porto/intermediate/cost_matrix.mat'); 
load('./datasets/Porto/intermediate/cost_matrix_MB.mat'); 
load('./datasets/Porto/intermediate/cost_matrix_noMB.mat'); 

%% Calculate the real travel cost
for i = 1:1:NR_LOC
    for l = 1:1:NR_TASK_LOC
        [~, travel_cost_instance] = shortestpath(G, approx_idx_next(i, 1), task_idx(1, l)); 
        real_travel_cost(i, 1) = real_travel_cost(i, 1) + travel_cost_instance/NR_TASK_LOC; 
    end
end
% load('.\datasets\intermediate\real_travel_cost.mat'); 


loc_frequency_noprior = ones(NR_LOC, size(df_nodes, 1))/size(df_nodes, 1); 


for EPSILON = 1:1:5 

%% Calculate the estimated travel cost
for i = 1:1:20 %NR_LOC   
    [EPSILON, i] 

    %% Method 
    % [z_vector, obfuscationMatrix, distance_matrix] = obfLaplace(top_idx_list(i, :), approx_idx(i, 1), df_nodes, EPSILON/10, NR_CANDIDATE);
    [z_vector, obfuscationMatrix, distance_matrix] = obfLP(top_idx_list(i, :), approx_idx(i, 1), df_nodes, task_idx, squeeze(cost_matrix(i, :, :)), EPSILON/10, NR_CANDIDATE); 
    % [z_vector, obfuscationMatrix, distance_matrix] = obfConstOPT(top_idx_list(i, :), approx_idx(i, 1), df_nodes, task_idx, squeeze(cost_matrix(i, :, :)), EPSILON/10, NR_CANDIDATE);
    posterior_vector = posteriorVector(z_vector, loc_frequency_noprior(i, top_idx_list(i, :)), obfuscationMatrix); 
    [maxPL(i, EPSILON), meanPL(i, EPSILON)] = posterLeakage(posterior_vector, loc_frequency_noprior(i, top_idx_list(i, :)), distance_matrix); 
    top_loc_list = df_nodes(top_idx_list(i, :), 2:3); 
    top_loc_list = top_loc_list{:,:}; 
    expected_inference_error(i, EPSILON) = 0; 
    for k = 1:1:NR_CANDIDATE
        estimated_travel_cost(i, 1) = 0;
        for l = 1:1:NR_TASK_LOC     
            [~, travel_cost_instance_] = shortestpath(G, top_idx_list(i, k), task_idx(1, l)); 
            estimated_travel_cost(i, 1) = estimated_travel_cost(i, 1) + travel_cost_instance_/NR_TASK_LOC; 
        end
        utility_loss(1, k) = abs(estimated_travel_cost(i, 1) - real_travel_cost(i, 1)); 
        [inference_error_instance, ~, ~] = haversine(top_loc_list(k, :), picked_locations(i, :)); 
        expected_inference_error(i, EPSILON) = expected_inference_error(i, EPSILON) + inference_error_instance*z_vector(1, k);
    end    
    expected_utility_loss(i, EPSILON) = sum(utility_loss.*z_vector); 
end
end
a = 0; 