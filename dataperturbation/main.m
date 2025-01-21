%% main file of CAmDP
addpath('./func/'); 
addpath('./func/haversine/'); 

load('./datasets/intermediate/Rome/loc_frequency_MB.mat'); 
load('./datasets/intermediate/Rome/loc_frequency_noMB.mat'); 


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
NR_LOC = 500; 
NR_CANDIDATE = 50; 

ETA = 10; 

load('./datasets/Rome/selected_traj.mat'); 
picked_locations = csvread('./datasets/Rome/picked_locations.csv'); 

opts = detectImportOptions('./datasets/Rome/nodes.csv');
opts = setvartype(opts, 'osmid', 'int64');
df_nodes = readtable('./datasets/Rome/nodes.csv', opts);
df_edges = readtable('./datasets/Rome/edges.csv');

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
%     i
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
% load('./datasets/intermediate/Rome/approx_idx.mat'); 
% load('./datasets/intermediate/Rome/approx_idx_next.mat'); 
% load('./datasets/intermediate/Rome/top_idx_list.mat'); 

load('./datasets/intermediate/Rome/approx_idx_500.mat'); 
load('./datasets/intermediate/Rome/approx_idx_next_500.mat'); 
load('./datasets/intermediate/Rome/top_idx_list_500.mat'); 

cost_matrix_MB = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 
cost_matrix_noMB = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 
cost_matrix = zeros(NR_LOC, NR_CANDIDATE, NR_CANDIDATE); 

tic
% [cost_matrix, cost_matrix_noMB, cost_matrix_MB] = cost_matrix_calculation(G, top_idx_list, task_idx, loc_frequency_noMB, loc_frequency_MB, NR_LOC, NR_CANDIDATE, NR_TASK_LOC);
for k = 1:1:NR_LOC
    tic
    for i = 1:1:NR_CANDIDATE
        [k i]
        for j = 1:1:NR_CANDIDATE
            for l = 1:1:NR_TASK_LOC     
                [~, travel_cost_instance_real] = shortestpath(G, top_idx_list(k, i), task_idx(1, l)); 
                [~, travel_cost_instance_pert] = shortestpath(G, top_idx_list(k, j), task_idx(1, l));
                cost_matrix(k, i, j) = cost_matrix(k, i, j) + abs(travel_cost_instance_real-travel_cost_instance_pert)/NR_TASK_LOC;
                cost_matrix_noMB(k, i, j) = cost_matrix_noMB(k, i, j) + loc_frequency_noMB(k, top_idx_list(k, i))*abs(travel_cost_instance_real-travel_cost_instance_pert)/NR_TASK_LOC; 
                cost_matrix_MB(k, i, j) = cost_matrix_MB(k, i, j) + loc_frequency_MB(k, top_idx_list(k, i))*abs(travel_cost_instance_real-travel_cost_instance_pert)/NR_TASK_LOC; 
            end          
        end
    end
    time = toc; 
end
time = toc; 
% load('./datasets/intermediate/Rome/cost_matrix.mat'); 
% load('./datasets/intermediate/Rome/cost_matrix_MB.mat'); 
% load('./datasets/intermediate/Rome/cost_matrix_noMB.mat'); 
% 
% load('./datasets/intermediate/Rome/cost_matrix_500.mat'); 
% load('./datasets/intermediate/Rome/cost_matrix_MB_500.mat'); 
% load('./datasets/intermediate/Rome/cost_matrix_noMB_500.mat'); 

% load('./datasets/intermediate/Rome/nearVeh/cost_matrix.mat'); 
% load('./datasets/intermediate/Rome/nearVeh/cost_matrix_MB.mat'); 
% load('./datasets/intermediate/Rome/nearVeh/cost_matrix_noMB.mat'); 

%% Calculate the real travel cost
% for i = 1:1:NR_LOC
%     for l = 1:1:NR_TASK_LOC
%         [~, travel_cost_instance] = shortestpath(G, approx_idx_next(i, 1), task_idx(1, l)); 
%         real_travel_cost(i, 1) = real_travel_cost(i, 1) + travel_cost_instance/NR_TASK_LOC; 
%     end
% end
% load('.\datasets\intermediate\real_travel_cost.mat'); 


loc_frequency_noprior = ones(NR_LOC, size(df_nodes, 1))/size(df_nodes, 1); 


% load("./expected_inference_error.mat");
% load("./expected_inference_error_MB.mat");
% load("./expected_inference_error_noMB.mat");
% load("./success_rate.mat");
% load("./success_rate_.mat");
% load("./success_rate_MB.mat");
% load("./success_rate_MB_.mat");
% load("./success_rate_noMB.mat");
% load("./expected_utility_loss.mat");
% load("./expected_utility_loss_MB.mat");
% load("./expected_utility_loss_noMB.mat");


for EPSILON = 1:1:5 

%% Calculate the estimated travel cost
for i = 1:1:100 % NR_LOC   
    [EPSILON, i] 
    top_loc_list = df_nodes(top_idx_list(i, :), 2:3); 
    top_loc_list = top_loc_list{:,:}; 

    %% Method 
    [z_vector_Lap, obfuscationMatrix_Lap, distance_matrix, approx_idx_target] = obfLaplace(top_idx_list(i, :), approx_idx(i, 1), df_nodes, EPSILON/100, NR_CANDIDATE);
    [z_vector_OPT, obfuscationMatrix_OPT, distance_matrix, approx_idx_target] = obfConstOPT(top_idx_list(i, :), approx_idx(i, 1), df_nodes, task_idx, squeeze(cost_matrix(i, :, :)), EPSILON/100, NR_CANDIDATE);
    
    
    [z_vector_LP, obfuscationMatrix_LP, distance_matrix, approx_idx_target] = obfLP(top_idx_list(i, :), approx_idx(i, 1), df_nodes, task_idx, squeeze(cost_matrix(i, :, :)), EPSILON/100, NR_CANDIDATE); 
    [z_vector_MB, obfuscationMatrix_MB, distance_matrix, approx_idx_target, compute_time(i,EPSILON)] = obfLP(top_idx_list(i, :), approx_idx(i, 1), df_nodes, task_idx, squeeze(cost_matrix_MB(i, :, :)), EPSILON/100, NR_CANDIDATE); 
    % save("./results/compute_time.mat", "compute_time");
    % tic 
    % for k = 1:1:1000
    %     index = perturbedrecord_selection(z_vector_MB);
    % end
    % per_selec_time(i,EPSILON) = toc; 

    [z_vector_noMB, obfuscationMatrix_noMB, distance_matrix, approx_idx_target] = obfLP(top_idx_list(i, :), approx_idx(i, 1), df_nodes, task_idx, squeeze(cost_matrix_noMB(i, :, :)), EPSILON/100, NR_CANDIDATE); 
    


    [maxPL_Lap(i, EPSILON), meanPL_Lap(i, EPSILON), expected_inference_error_Lap(i, EPSILON), success_rate_Lap(i, EPSILON), success_rate_Lap_(i, EPSILON), expected_utility_loss_Lap(i, EPSILON)] ...
    = performance_evaluation(z_vector_Lap, obfuscationMatrix_Lap, distance_matrix, approx_idx_target, cost_matrix_MB, loc_frequency_noprior, top_loc_list, i); 
    save("./results/expected_inference_error_Lap.mat", "expected_inference_error_Lap");
    save("./results/success_rate_Lap.mat", "success_rate_Lap");
    save("./results/success_rate_Lap_.mat", "success_rate_Lap_");
    save("./results/expected_utility_loss_Lap.mat", "expected_utility_loss_Lap");
    save("./results/maxPL_Lap.mat", "maxPL_Lap");
    save("./results/meanPL_Lap.mat", "meanPL_Lap");


    [maxPL_LP(i, EPSILON), meanPL_LP(i, EPSILON), expected_inference_error_LP(i, EPSILON), success_rate_LP(i, EPSILON), success_rate_LP_(i, EPSILON), expected_utility_loss_LP(i, EPSILON)] ...
    = performance_evaluation(z_vector_LP, obfuscationMatrix_LP, distance_matrix, approx_idx_target, cost_matrix_MB, loc_frequency_noprior, top_loc_list, i); 
    save("./results/expected_inference_error_LP.mat", "expected_inference_error_LP");
    save("./results/success_rate_LP.mat", "success_rate_LP");
    save("./results/success_rate_LP_.mat", "success_rate_LP_");
    save("./results/expected_utility_loss_LP.mat", "expected_utility_loss_LP");
    save("./results/maxPL_LP.mat", "maxPL_LP");
    save("./results/meanPL_LP.mat", "meanPL_LP");

    [maxPL_MB(i, EPSILON), meanPL_MB(i, EPSILON), expected_inference_error_MB(i, EPSILON), success_rate_MB(i, EPSILON), success_rate_MB_(i, EPSILON), expected_utility_loss_MB(i, EPSILON)] ...
    = performance_evaluation(z_vector_MB, obfuscationMatrix_MB, distance_matrix, approx_idx_target, cost_matrix_MB, loc_frequency_noprior, top_loc_list, i); 
    save("./results/expected_inference_error_MB.mat", "expected_inference_error_MB");
    save("./results/success_rate_MB.mat", "success_rate_MB");
    save("./results/success_rate_MB_.mat", "success_rate_MB_");
    save("./results/expected_utility_loss_MB.mat", "expected_utility_loss_MB");
    save("./results/maxPL_MB.mat", "maxPL_MB");
    save("./results/meanPL_MB.mat", "meanPL_MB");

    [maxPL_noMB(i, EPSILON), meanPL_noMB(i, EPSILON), expected_inference_error_noMB(i, EPSILON), success_rate_noMB(i, EPSILON), success_rate_noMB_(i, EPSILON), expected_utility_loss_noMB(i, EPSILON)] ...
    = performance_evaluation(z_vector_noMB, obfuscationMatrix_noMB, distance_matrix, approx_idx_target, cost_matrix_MB, loc_frequency_noprior, top_loc_list, i); 
    save("./results/expected_inference_error_noMB.mat", "expected_inference_error_noMB");
    save("./results/success_rate_noMB.mat", "success_rate_noMB");
    save("./results/success_rate_noMB_.mat", "success_rate_noMB_");
    save("./results/expected_utility_loss_noMB.mat", "expected_utility_loss_noMB");
    save("./results/maxPL_noMB.mat", "maxPL_noMB");
    save("./results/meanPL_noMB.mat", "meanPL_noMB");

    [maxPL_OPT(i, EPSILON), meanPL_OPT(i, EPSILON), expected_inference_error_OPT(i, EPSILON), success_rate_OPT(i, EPSILON), success_rate_OPT_(i, EPSILON), expected_utility_loss_OPT(i, EPSILON)] ...
    = performance_evaluation(z_vector_OPT, obfuscationMatrix_OPT, distance_matrix, approx_idx_target, cost_matrix_MB, loc_frequency_noprior, top_loc_list, i); 
    save("./results/expected_inference_error_OPT.mat", "expected_inference_error_OPT");
    save("./results/success_rate_OPT.mat", "success_rate_OPT");
    save("./results/success_rate_OPT_.mat", "success_rate_OPT_");
    save("./results/expected_utility_loss_OPT.mat", "expected_utility_loss_OPT");
    save("./results/maxPL_OPT.mat", "maxPL_OPT");
    save("./results/meanPL_OPT.mat", "meanPL_OPT");
    
    % posterior_vector = posteriorVector(z_vector, loc_frequency_noprior(i, top_idx_list(i, :)), obfuscationMatrix); 
    % posterior_vector_MB = posteriorVector(z_vector_MB, loc_frequency_noprior(i, top_idx_list(i, :)), obfuscationMatrix_MB); 
    % posterior_vector_noMB = posteriorVector(z_vector_noMB, loc_frequency_noprior(i, top_idx_list(i, :)), obfuscationMatrix_noMB); 
    % posterior_vector_OPT = posteriorVector(z_vector_OPT, loc_frequency_noprior(i, top_idx_list(i, :)), obfuscationMatrix_OPT); 
    % 
    % %% Posterior Leakage
    % [maxPL(i, EPSILON), meanPL(i, EPSILON)] = posterLeakage(posterior_vector, loc_frequency_noprior(i, top_idx_list(i, :)), distance_matrix); 
    % [maxPL_MB(i, EPSILON), meanPL_MB(i, EPSILON)] = posterLeakage(posterior_vector_MB, loc_frequency_noprior(i, top_idx_list(i, :)), distance_matrix); 
    % [maxPL_noMB(i, EPSILON), meanPL_noMB(i, EPSILON)] = posterLeakage(posterior_vector_noMB, loc_frequency_noprior(i, top_idx_list(i, :)), distance_matrix); 
    % [maxPL_OPT(i, EPSILON), meanPL_OPT(i, EPSILON)] = posterLeakage(posterior_vector_OPT, loc_frequency_noprior(i, top_idx_list(i, :)), distance_matrix); 
    % 

    % 
    % 
    % %% Expected inference error and inference success rate
    % expected_inference_error(i, EPSILON) = 0; 
    % expected_inference_error_MB(i, EPSILON) = 0; 
    % expected_inference_error_noMB(i, EPSILON) = 0;
    % expected_inference_error_OPT(i, EPSILON) = 0;
    % 
    % success_rate(i, EPSILON) = 0; 
    % success_rate_MB(i, EPSILON) = 0; 
    % success_rate_noMB(i, EPSILON) = 0;
    % success_rate_OPT(i, EPSILON) = 0;
    % 
    % success_rate_(i, EPSILON) = 0; 
    % success_rate_MB_(i, EPSILON) = 0; 
    % success_rate_noMB_(i, EPSILON) = 0; 
    % success_rate_OPT_(i, EPSILON) = 0; 
    % 
    % % This part is used to generate perturbed location and the
    % % corresponding posterior distribution
    % SAMPLE_SIZE = 10000;
    % for k = 1:1:10000
    %     perturbed_loc = perturbedLocationGenerator(z_vector); 
    %     perturbed_loc_MB = perturbedLocationGenerator(z_vector_MB);
    %     perturbed_loc_noMB = perturbedLocationGenerator(z_vector_noMB);
    %     perturbed_loc_OPT= perturbedLocationGenerator(z_vector_OPT);
    % 
    %     estimated_loc = BayesianAttack(obfuscationMatrix, perturbed_loc);
    %     estimated_loc_MB = BayesianAttack(obfuscationMatrix_MB, perturbed_loc_MB);
    %     estimated_loc_noMB = BayesianAttack(obfuscationMatrix_noMB, perturbed_loc_noMB);
    %     estimated_loc_OPT = BayesianAttack(obfuscationMatrix_OPT, perturbed_loc_OPT);
    % 
    %     if estimated_loc == i
    %         success_rate(i, EPSILON) = success_rate(i, EPSILON) + 1;
    %     end
    %     if estimated_loc_MB == i
    %         success_rate_MB(i, EPSILON) = success_rate_MB(i, EPSILON) + 1;
    %     end
    %     if estimated_loc_noMB == i
    %         success_rate_noMB(i, EPSILON) = success_rate_noMB(i, EPSILON) + 1;
    %     end
    %     if estimated_loc_noMB == i
    %         success_rate_OPT(i, EPSILON) = success_rate_OPT(i, EPSILON) + 1;
    %     end
    % 
    %     [inference_error_instance, ~, ~] = haversine(top_loc_list(estimated_loc, :), top_loc_list(i, :)); 
    %     [inference_error_instance_MB, ~, ~] = haversine(top_loc_list(estimated_loc_MB, :), top_loc_list(i, :));
    %     [inference_error_instance_noMB, ~, ~] = haversine(top_loc_list(estimated_loc_noMB, :), top_loc_list(i, :));
    %     [inference_error_instance_OPT, ~, ~] = haversine(top_loc_list(estimated_loc_OPT, :), top_loc_list(i, :));
    % 
    %     if inference_error_instance < 0.05
    %         success_rate_(i, EPSILON) = success_rate_(i, EPSILON) + 1;
    %     end
    %     if inference_error_instance_MB < 0.05
    %         success_rate_MB_(i, EPSILON) = success_rate_MB_(i, EPSILON) + 1;
    %     end
    %     if inference_error_instance_noMB < 0.05
    %         success_rate_noMB_(i, EPSILON) = success_rate_noMB_(i, EPSILON) + 1;
    %     end
    %     if inference_error_instance_OPT < 0.05
    %         success_rate_OPT_(i, EPSILON) = success_rate_OPT_(i, EPSILON) + 1;
    %     end
    % 
    %     expected_inference_error(i, EPSILON) = expected_inference_error(i, EPSILON) + inference_error_instance;
    %     expected_inference_error_MB(i, EPSILON) = expected_inference_error_MB(i, EPSILON) + inference_error_instance_MB;
    %     expected_inference_error_noMB(i, EPSILON) = expected_inference_error_noMB(i, EPSILON) + inference_error_instance_noMB;
    %     expected_inference_error_OPT(i, EPSILON) = expected_inference_error_OPT(i, EPSILON) + inference_error_instance_OPT;
    % end
    % success_rate(i, EPSILON) = success_rate(i, EPSILON)/SAMPLE_SIZE; 
    % success_rate_MB(i, EPSILON) = success_rate_MB(i, EPSILON)/SAMPLE_SIZE;
    % success_rate_noMB(i, EPSILON) = success_rate_noMB(i, EPSILON)/SAMPLE_SIZE;
    % success_rate_OPT(i, EPSILON) = success_rate_OPT(i, EPSILON)/SAMPLE_SIZE;
    % 
    % success_rate_(i, EPSILON) = success_rate_(i, EPSILON)/SAMPLE_SIZE; 
    % success_rate_MB_(i, EPSILON) = success_rate_MB_(i, EPSILON)/SAMPLE_SIZE;
    % success_rate_noMB_(i, EPSILON) = success_rate_noMB_(i, EPSILON)/SAMPLE_SIZE;
    % success_rate_OPT_(i, EPSILON) = success_rate_OPT_(i, EPSILON)/SAMPLE_SIZE;
    % 
    % expected_inference_error(i, EPSILON) = expected_inference_error(i, EPSILON)/SAMPLE_SIZE; 
    % expected_inference_error_MB(i, EPSILON) = expected_inference_error_MB(i, EPSILON)/SAMPLE_SIZE;
    % expected_inference_error_noMB(i, EPSILON) = expected_inference_error_noMB(i, EPSILON)/SAMPLE_SIZE;
    % expected_inference_error_OPT(i, EPSILON) = expected_inference_error_OPT(i, EPSILON)/SAMPLE_SIZE;
    % 
    % 
    % % for k = 1:1:NR_CANDIDATE
    % %     estimated_travel_cost(i, 1) = 0;
    % %     for l = 1:1:NR_TASK_LOC     
    % %         [~, travel_cost_instance_] = shortestpath(G, top_idx_list(i, k), task_idx(1, l)); 
    % %         estimated_travel_cost(i, 1) = estimated_travel_cost(i, 1) + travel_cost_instance_/NR_TASK_LOC; 
    % %     end
    % %     utility_loss(1, k) = abs(estimated_travel_cost(i, 1) - real_travel_cost(i, 1)); 
    % % 
    % % end    
    % expected_utility_loss(i, EPSILON) = sum(squeeze(cost_matrix_MB(i, approx_idx_target, :))'.*z_vector); 
    % expected_utility_loss_MB(i, EPSILON) = sum(squeeze(cost_matrix_MB(i, approx_idx_target, :))'.*z_vector_MB);
    % expected_utility_loss_noMB(i, EPSILON) = sum(squeeze(cost_matrix_MB(i, approx_idx_target, :))'.*z_vector_noMB);
    % expected_utility_loss_OPT(i, EPSILON) = sum(squeeze(cost_matrix_MB(i, approx_idx_target, :))'.*z_vector_OPT);

    % save("./results/expected_inference_error.mat", "expected_inference_error");
    % save("./results/expected_inference_error_MB.mat", "expected_inference_error_MB");
    % save("./results/expected_inference_error_noMB.mat", "expected_inference_error_noMB");
    % save("./results/expected_inference_error_OPT.mat", "expected_inference_error_OPT"); 
    % save("./results/success_rate.mat", "success_rate");
    % save("./results/success_rate_.mat", "success_rate_");
    % save("./results/success_rate_MB.mat", "success_rate_MB");
    % save("./results/success_rate_MB_.mat", "success_rate_MB_");
    % save("./results/success_rate_noMB.mat", "success_rate_noMB");
    % save("./results/success_rate_noMB_.mat", "success_rate_noMB_");
    % save("./results/success_rate_OPT.mat", "success_rate_OPT");
    % save("./results/success_rate_OPT_.mat", "success_rate_OPT_");
    % save("./results/expected_utility_loss.mat", "expected_utility_loss");
    % save("./results/expected_utility_loss_MB.mat", "expected_utility_loss_MB");
    % save("./results/expected_utility_loss_noMB.mat", "expected_utility_loss_noMB");
    % save("./results/expected_utility_loss_OPT.mat", "expected_utility_loss_OPT");
    % save("./results/maxPL.mat", "maxPL");
    % save("./results/maxPL_MB.mat", "maxPL_MB");
    % save("./results/maxPL_noMB.mat", "maxPL_noMB");
    % save("./results/maxPL_OPT.mat", "maxPL_OPT");
    % save("./results/meanPL.mat", "meanPL");
    % save("./results/meanPL_MB.mat", "meanPL_MB");
    % save("./results/meanPL_noMB.mat", "meanPL_noMB");
    % save("./results/meanPL_OPT.mat", "meanPL_OPT");
end
end
a = 0; 

    % save("./results/expected_inference_error.mat", "expected_inference_error");
    % save("./results/expected_inference_error_MB.mat", "expected_inference_error_MB");
    % save("./results/expected_inference_error_noMB.mat", "expected_inference_error_noMB");
    % save("./results/expected_inference_error_OPT.mat", "expected_inference_error_OPT"); 
    % save("./results/success_rate.mat", "success_rate");
    % save("./results/success_rate_.mat", "success_rate_");
    % save("./results/success_rate_MB.mat", "success_rate_MB");
    % save("./results/success_rate_MB_.mat", "success_rate_MB_");
    % save("./results/success_rate_noMB.mat", "success_rate_noMB");
    % save("./results/success_rate_noMB_.mat", "success_rate_noMB_");
    % save("./results/success_rate_OPT.mat", "success_rate_OPT");
    % save("./results/success_rate_OPT_.mat", "success_rate_OPT_");
    % save("./results/expected_utility_loss.mat", "expected_utility_loss");
    % save("./results/expected_utility_loss_MB.mat", "expected_utility_loss_MB");
    % save("./results/expected_utility_loss_noMB.mat", "expected_utility_loss_noMB");
    % save("./results/expected_utility_loss_OPT.mat", "expected_utility_loss_OPT");
    % save("./results/maxPL.mat", "maxPL");
    % save("./results/maxPL_MB.mat", "maxPL_MB");
    % save("./results/maxPL_noMB.mat", "maxPL_noMB");
    % save("./results/maxPL_OPT.mat", "maxPL_OPT");
    % save("./results/meanPL.mat", "meanPL");
    % save("./results/meanPL_MB.mat", "meanPL_MB");
    % save("./results/meanPL_noMB.mat", "meanPL_noMB");
    % save("./results/meanPL_OPT.mat", "meanPL_OPT");