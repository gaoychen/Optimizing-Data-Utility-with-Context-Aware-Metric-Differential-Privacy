function approx_id = approximation(loc, df_nodes)
    for i = 1:1:size(df_nodes, 1)
        x = df_nodes(i, "x");
        x = x{1, 1}; 
        y = df_nodes(i, "y");
        y = y{1, 1}; 
        [distance(i, 1), ~, ~] = haversine(loc, [y, x]); 
    end
    [~, approx_id] = min(distance); 
end
