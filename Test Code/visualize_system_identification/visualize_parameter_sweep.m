
function visualize_parameter_sweep
% close all
clc
results_dir     = '/Volumes/TDT Data/extracted_data/ARN045/1D_Amplitude/';
experiment_dirs = {'amplitude_grid_1_post/'...
    'amplitude_grid_1_pre/'};

experiment_all = table();
biomarker_all = table();

for c1 = 1:numel(experiment_dirs)
    
    load([results_dir experiment_dirs{c1} 'experiment_table.mat'])
    load([results_dir experiment_dirs{c1} 'biomarker_get_average_theta_power_bipolar_window-3.mat']);
    
    experiment_all = [experiment_all; experiment_table];
    biomarker_all = [ biomarker_all; biomarker_table];
end
data  = innerjoin(experiment_all,biomarker_all);
data.stimulation_amplitude = data.stimulation_amplitude_a + data.stimulation_amplitude_b;

figure_flag     = '';
control_data    = [];
error_mode      = 'sem';
y_label         = '\Delta Theta Power';

x3_name         = 'stimulation_duration';
x2_name         = 'experiment_start_time';
x1_name         = 'stimulation_amplitude';

x1              = eval(strcat('data.', x1_name));
x2              = eval(strcat('data.', x2_name));
x3              = eval(strcat('data.', x3_name));


Y               = data.biomarkers;

plot_grouped_subplots(Y, x1, x2, x3, y_label, x1_name, x2_name, x3_name, ...
    [1], figure_flag, control_data, error_mode)
    
end

