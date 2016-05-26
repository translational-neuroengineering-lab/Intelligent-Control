function  plot_optimization_1D
close all;
home = '/Users/mconnolly/Dropbox/cross_entropy_correlation_synchronous-ARN038_20160504T153641/';
stimulation_frequencies = csvread([home 'stimulation_channel_.csv']);
optimization_parameters = csvread([home 'parameter.csv']);
objective_function      = csvread([home 'objective_function.csv']);

samples_per_cycle   = 100;
n_elite             = 10;
n_samples           = size(objective_function,1);

% Plot elite/non-elite samples 
subplot(3,1,1); hold on;

for c1 = 1 : n_samples/ samples_per_cycle -1
        
    [~, objective_idx]   = sort(objective_function((c1-1)*samples_per_cycle + 1: c1*samples_per_cycle,2), 'descend');
    sample_freq = stimulation_frequencies((c1-1)*samples_per_cycle + 1: c1*samples_per_cycle,2);
    
    non_elite_samples   = sample_freq(objective_idx(n_elite+1:end));
    elite_samples       = sample_freq(objective_idx(1:n_elite));
    
    scatter(ones(size(non_elite_samples))*c1, non_elite_samples, 'MarkerEdgeColor', [1 1 1]*.7, 'LineWidth', 1 )
    scatter(ones(size(elite_samples))*c1, elite_samples, 'MarkerEdgeColor', [1 0 0], 'SizeData', 200, 'Marker', 'X', 'linewidth', 2)
     
end

ylabel('Stimulation Frequency');

% Plot value of opjective function
for c1 = 1 : n_samples/ samples_per_cycle -1
    objective_mean(c1) = mean(objective_function((c1-1)*samples_per_cycle + 1: c1*samples_per_cycle,2));
    objective_std(c1) = std(objective_function((c1-1)*samples_per_cycle + 1: c1*samples_per_cycle,2))/10;
end

subplot(3,1,2);
errorbar(1:c1, objective_mean, objective_std,'k-','linewidth', 2);
xlim([1 11]);
ylabel('Mean CA3-CA1 Correlation Coefficient');

subplot(3,1,3);
hold on
plot(1:c1, optimization_parameters(1:c1, 2)- optimization_parameters(1:c1, 3), 'k-', 'linewidth', 2 )
plot(1:c1, optimization_parameters(1:c1, 2), 'r-', 'linewidth', 2 )
plot(1:c1, optimization_parameters(1:c1, 2)+ optimization_parameters(1:c1, 3), 'k-', 'linewidth', 2 )
ylabel('Search Distribution - Mean +/- STD (Hz)');
xlabel('Iteration (100 stimulations each)')
end

