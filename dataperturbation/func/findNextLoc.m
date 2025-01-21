function idx_next = findNextLoc(loc, trajectory)
    for i = 1:1:size(trajectory, 1)
        distance = sum((loc - trajectory(i, :)).^2); 
        if distance <= 0.000001
            break; 
        end
    end
    idx_next = i; 
end