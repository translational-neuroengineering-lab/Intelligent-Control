function plot_grouped_lines( Y, x1, grouping_variable,...
        y_label, x1_label, x2_label, figure_flag, control_data, error_mode )
%PLOT_STIMULATION_EFFECT Summary of this function goes here
%   Detailed explanation goes here
load('Tools/default_color_order.mat');

groups      = unique(grouping_variable);
variable    = unique(x1);
min_var     = min(variable);
max_var     = max(variable);
offsets     = (-1*(size(groups,1)-1)/2:(size(groups,1)-1)/2)*.002*(max_var-min_var);

n_groups    = numel(groups);

if figure_flag
    figure; 
end
hold on;

if ~exist('error_mode', 'var') || isempty(error_mode)
    error_mode = 'std';
end

% Plot control patch
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

% Plot grouped errorbars
for c1 = 1:size(groups,1)
    
    x_values    = unique(x1(grouping_variable == groups(c1)));
    means       = nan(size(x_values));
    err         = nan(size(x_values));
    
    for c2 = 1:size(x_values,1)
        point_data  = Y(grouping_variable == groups(c1) & x1 == x_values(c2));
        
        means(c2)   = mean(point_data);
        
        switch error_mode
            case 'std'
                err(c2)    = std(point_data);
            case 'sem'
                err(c2)    = std(point_data)/sqrt(size(point_data,1));
        end
        
        
    end
    
    plot(x_values+offsets(c1), means,  'LineWidth', 2,'color', default_color_order(c1,:))
    errbar(x_values+offsets(c1), means, err, 'LineWidth', 2, 'color', default_color_order(c1,:));
    ax = gca;
    ax.Layer = 'top';

end

% Set labels
if exist('y_label', 'var')
    ylabel(strrep(y_label,'_', ' '),'FontSize', 16)
end

if exist('x1_label', 'var')
    xlabel(strrep(x1_label,'_', ' '),'FontSize', 16)
end

if exist('x2_label', 'var')
    legend_labels = cell(1,n_groups);
    
    for c1 = 1:n_groups
        legend_labels{c1} = sprintf('%s: %.1f', strrep(x2_label,'_', ' '), groups(c1));
    end
    
    if exist('control_data', 'var') && ~isempty(control_data)
        legend_labels = [legend_labels 'control'];
    end
    
    legend(legend_labels);
end

% Adjust limits
xlim([min_var+offsets(1)*2, max_var+offsets(end)*2]);
end
