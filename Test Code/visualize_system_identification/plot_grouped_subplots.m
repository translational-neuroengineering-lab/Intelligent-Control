function plot_grouped_subplots(  Y, x1, x2, x3,...
        y_label, x1_label, x2_label, x3_label, subplot_arrangement, figure_flag, control_data, error_mode )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


[n_rows, n_columns] = size(subplot_arrangement);
n_subplots          = numel(subplot_arrangement);
plot_order          = reshape(subplot_arrangement',1,n_subplots);
x3_vars             = unique(x3);

for c1 = 1:n_subplots
    sub_indicies = x3 == x3_vars(c1);
    sub_Y   = Y(sub_indicies);
    sub_x1  = x1(sub_indicies);
    sub_x2  = x2(sub_indicies);
    
    subplot(n_rows, n_columns, plot_order(c1));
        
    plot_grouped_lines(sub_Y, sub_x1, sub_x2, y_label ,x1_label, x2_label, figure_flag, control_data, error_mode )

    title(sprintf('%s: %f', strrep(x3_label,'_', ' '), x3_vars(c1)))
    set(gca, 'FontSize', 16)   

end
end

