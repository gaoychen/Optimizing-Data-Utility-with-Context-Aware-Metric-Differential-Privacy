function top_idx_list = topLocations(loc, df_nodes, NR_CANDIDATE)
    for i = 1:1:size(df_nodes, 1)
        x = df_nodes(i, "x");
        x = x{1, 1}; 
        y = df_nodes(i, "y");
        y = y{1, 1}; 
        [distance(i, 1), ~, ~] = haversine(loc, [y, x]); 
    end
    [~, top_idx_list] = mink(distance, NR_CANDIDATE); 
    % top_loc_list = df_nodes(top_idx_list, 2:3); 
    % top_loc_list = top_loc_list{:,:}; 
end