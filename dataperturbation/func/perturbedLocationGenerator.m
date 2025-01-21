function perturbed_loc = perturbedLocationGenerator(z_vector)
    z_vector_accu = cumsum(z_vector); 
    rand_num = rand(); 
    for i = 1:1:size(z_vector, 2)
        if rand_num < z_vector_accu(1, i)
            perturbed_loc = i; 
            break; 
        end
    end
end