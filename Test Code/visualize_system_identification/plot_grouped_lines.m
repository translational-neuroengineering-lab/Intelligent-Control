function plot_grouped_lines( Y, independent_variable, grouping_variable,...
        y_label, x_label, group_label, figure_flag, control_data, error_mode )
%PLOT_STIMULATION_EFFECT Summary of this function goes here
%   Detailed explanation goes here

groups      = unique(grouping_variable);
variable    = unique(independent_variable);
min_var     = min(variable);
max_var     = max(variable);
offsets     = (-1*(size(groups,1)-1)/2:(size(groups,1)-1)/2)*.1;

if figure_flag
    figure; 
end
hold on;

if ~exist('error_mode', 'var') || isempty(error_mode)
    error_mode = 'std';
end

if exist('control_data', 'var') && ~isempty(control_data)
    mean_control    = mean(control_data);
    
    switch error_mode
        case 'std'
            sem_control    = std(control_data);
        case 'sem'
            sem_control    = std(control_data)/sqrt(size(control_data,1));
    end
    
    upper_lim       = mean_control + sem_control;
    lower_lim       = mean_control - sem_control;
    
    patch([min([min_var 0]), min([min_var 0]), 2*max_var, 2*max_var ], ...
        [lower_lim, upper_lim, upper_lim, lower_lim],  ones(1,3)*.9, 'EdgeColor', 'none')
end

for c1 = 1:size(groups,1)
    
    x_values    = unique(independent_variable(grouping_variable == groups(c1)));
    means       = nan(size(x_values));
    err         = nan(size(x_values));
    
    for c2 = 1:size(x_values,1)
        point_data  = Y(grouping_variable == groups(c1) & independent_variable == x_values(c2));
        
        means(c2)   = mean(point_data);
        
        switch error_mode
            case 'std'
                err(c2)    = std(point_data);
            case 'sem'
                err(c2)    = std(point_data)/sqrt(size(point_data,1));
        end
        
        
    end
    
    errorbar(x_values+offsets(c1), means, err, 'LineWidth', 2);
    ax = gca;
    ax.Layer = 'top';
end

if exist('y_label', 'var')
    ylabel(y_label,'FontSize', 16)
end

if exist('x_label', 'var')
    xlabel(x_label,'FontSize', 16)
end

if exist('group_label', 'var')
    legend(group_label);
end

xlim([min([min_var 1]), max_var*1.1])
end
