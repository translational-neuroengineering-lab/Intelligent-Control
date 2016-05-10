function plot_system_identification
%PLOT_ Summary of this function goes here
%   Detailed explanation goes here

file_name = 'temp_results/UG3_preliminary_system_id.mat';

load(file_name);

plot_correlation_durration(file_name);
% plot_mutual_information(file_name);
% plot_spectral_power(file_name);
% plot_coherence(file_name);

end
function plot_correlation_durration(file_name)

layer_parameters    = [];
correlation_metrics = [];

load(file_name)

% DURATIONS       = unique(layer_parameters(:,2));
LAYERS          = unique(layer_parameters(:,6));
FREQUENCIES     = unique(layer_parameters(:,1));
% n_durations     = size(DURATIONS,1);
n_layers        = size(LAYERS,1);
n_frequencies   = size(FREQUENCIES,1);

x_label         = 'Duration';
y_label         = 'Correlation Coefficient';
% group_label     = {'Baseline', 'Synchronous','Asynchronous - High Frequency'};
group_label     = {};
figure_flag     = 0;
figure;
for c1 = 1:n_frequencies
        
    for c2 = 1:n_layers
        subplot(5,4,(c1-1)*n_layers-c2+n_layers+1);
        
%         duration_index  = find(layer_parameters(:,2) == DURATIONS(c1));
        frequency_index  = find(layer_parameters(:,1) == FREQUENCIES(c1));
        layer_index     = find(layer_parameters(:,6)  == LAYERS(c2));

        index           = intersect(frequency_index, layer_index);

        plot_grouped_lines(correlation_metrics(index,1), layer_parameters(index,2), ...
            layer_parameters(index,5), y_label , x_label, group_label, figure_flag, ...
            correlation_baseline)
        
        title(sprintf('Layer %d, Frequency %.1fs', LAYERS(c2), FREQUENCIES(c1)));
    end
end

screenSize = get(0,'Screensize');
set(gcf, 'Position', [1 1 screenSize(3) screenSize(4)]);
% hgexport(gcf,sprintf('temp_results/correlation.eps'));
end

function plot_correlation(file_name)

layer_parameters    = [];
correlation_metrics = [];

load(file_name)

DURATIONS       = unique(layer_parameters(:,2));
LAYERS          = unique(layer_parameters(:,6));
n_durations     = size(DURATIONS,1);
n_layers        = size(LAYERS,1);

x_label         = 'Stimulation Frequency';
y_label         = 'Correlation Coefficient';
group_label     = {'Baseline', 'Synchronous','Asynchronous - High Frequency'};
figure_flag     = 0;
figure;
for c1 = 1:n_durations
        
    for c2 = 1:n_layers
        subplot(4,4,c1*n_durations-c2+1);
        
        duration_index  = find(layer_parameters(:,2) == DURATIONS(c1));
        layer_index     = find(layer_parameters(:,6)  == LAYERS(c2));

        index           = intersect(duration_index, layer_index);

        plot_grouped_lines(correlation_metrics(index,1), layer_parameters(index,1), ...
            layer_parameters(index,5), y_label , x_label, group_label, figure_flag, ...
            correlation_baseline)
        
        title(sprintf('Layer %d, Duration %.1fs', LAYERS(c2), DURATIONS(c1)));
    end
end

screenSize = get(0,'Screensize');
set(gcf, 'Position', [1 1 screenSize(3) screenSize(4)]);
hgexport(gcf,sprintf('temp_results/correlation.eps'));
end

function plot_mutual_information(file_name)

layer_parameters            = [];
mutual_information_metrics  = [];

load(file_name)

DURATIONS       = unique(layer_parameters(:,2));
LAYERS          = unique(layer_parameters(:,6));
n_durations     = size(DURATIONS,1);
n_layers        = size(LAYERS,1);

x_label         = 'Stimulation Frequency';
y_label         = 'Mutual Information';
group_label     = {'Baseline','Synchronous','Asynchronous - High Frequency'};
figure_flag     = 0;
figure;

for c2 = 1:n_durations
        
    for c1 = 1:n_layers
        subplot(4,4,(c1-1)*n_durations+c2);
        
        duration_index  = find(layer_parameters(:,2) == DURATIONS(c2));
        layer_index     = find(layer_parameters(:,6)  == LAYERS(c1));

        index           = intersect(duration_index, layer_index);

        plot_grouped_lines(mutual_information_metrics(index,1), layer_parameters(index,1), ...
            layer_parameters(index,5), y_label , x_label, group_label, figure_flag, ...
            mutual_information_baseline)
        
        title(sprintf('Layer %d, Duration %.1fs', LAYERS(c1), DURATIONS(c2)),'FontSize', 16);
    end
end

screenSize = get(0,'Screensize');
set(gcf, 'Position', [1 1 screenSize(3) screenSize(4)]);
hgexport(gcf,sprintf('temp_results/mutual_information.eps'));
       
end

function plot_spectral_power(file_name)

channel_parameters  = [];
spectral_metrics    = [];

load(file_name)

DURATIONS       = unique(channel_parameters(:,2));
CHANNELS        = unique(channel_parameters(:,6));
bins            = [1 4 8 14 30 50 75 100 150 200];

n_durations     = size(DURATIONS,1);
n_channels      = size(CHANNELS,1);
n_bins          = size(bins,2)-1;

x_label         = 'Stimulation Frequency';
group_label     = {'Baseline', 'Synchronous','Asynchronous - High Frequency'};
figure_flag     = 0;

for c3 = 1:n_bins
    
    y_label     = sprintf('Power V^2/Hz (%dHz-%dHz)',bins(c3), bins(c3+1));
    
    for c2 = 1:n_durations
        
        figure;
        for c1 = 1:n_channels
            if c1 <= n_channels/2             
                subplot(2,4,n_channels/2-c1+1);
            else
                subplot(2,4,c1)
            end
            
            duration_index  = find(channel_parameters(:,2) == DURATIONS(c2));
            layer_index     = find(channel_parameters(:,6) == CHANNELS(c1));
            
            index           = intersect(duration_index, layer_index);
            
            screenSize = get(0,'Screensize');
            set(gcf, 'Position', [1 1 screenSize(3) screenSize(4)/2]);
            plot_grouped_lines(spectral_metrics(index,c3), channel_parameters(index,1), ...
                channel_parameters(index,5), y_label , x_label, group_label, figure_flag, ...
                spectral_baseline(:,c3))
            
            title(sprintf('Channel %d, Duration %.1fs', CHANNELS(c1), DURATIONS(c2)), ...
                'FontSize', 16);
            hgexport(gcf,sprintf('temp_results/spectral_%dHz-%dHz_duration-%.1f.eps', bins(c3), bins(c3+1), DURATIONS(c2) ));
        end
    end
end
end

function plot_coherence(file_name)
layer_parameters    = [];
coherence_metrics   = [];

load(file_name)

DURATIONS       = unique(layer_parameters(:,2));
LAYERS          = unique(layer_parameters(:,6));
bins            = [1 4 8 14 30 50 75 100 150 200];

n_durations     = size(DURATIONS,1);
n_layers        = size(LAYERS,1);
n_bins          = size(bins,2)-1;

x_label         = 'Stimulation Frequency';
group_label     = {'Baseline', 'Synchronous','Asynchronous - High Frequency'};
figure_flag     = 0;

for c3 = 1:n_bins
    
    y_label     = sprintf('Coherence (%dHz-%dHz)',bins(c3), bins(c3+1));
    
    for c2 = 1:n_durations
        
        figure;
        for c1 = 1:n_layers
            
            subplot(1,4,n_layers - c1+1);
            
            duration_index  = find(layer_parameters(:,2) == DURATIONS(c2));
            layer_index     = find(layer_parameters(:,6) == LAYERS(c1));
            
            index           = intersect(duration_index, layer_index);
            
            screenSize = get(0,'Screensize');
            set(gcf, 'Position', [1 1 screenSize(3) screenSize(4)/2]);
            plot_grouped_lines(coherence_metrics(index,c3), layer_parameters(index,1), ...
                layer_parameters(index,5), y_label , x_label, group_label, figure_flag, ...
                coherence_baseline(:,c3))
            
            title(sprintf('Layer %d, Duration %.1fs', LAYERS(c1), DURATIONS(c2)), ...
                'FontSize', 16);
            hgexport(gcf,sprintf('temp_results/coherence_%dHz-%dHz_duration-%.1f.eps', bins(c3), bins(c3+1), DURATIONS(c2) ));
        end
    end
end

end

