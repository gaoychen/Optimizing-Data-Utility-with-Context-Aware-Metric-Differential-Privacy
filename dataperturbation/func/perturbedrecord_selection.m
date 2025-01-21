function index = perturbedrecord_selection(z_vector)
    z_vector_sum = cumsum(z_vector); 
    z_vector_sum = [0, z_vector_sum];
    rand_seed = rand(); 
    for l = 1:1:size(z_vector_sum, 2)-1
        if rand_seed < z_vector_sum(1, l+1) && rand_seed >= z_vector_sum(1, l)
            index = l; 
        end
    end
end