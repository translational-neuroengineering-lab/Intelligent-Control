% function visualize_parameter_sweep
% RA16_ZCH_matrix = [4,3,2,1; 5,6,7,8];
%  
% results_dir = '/Users/mconnolly/Intelligent Control Repository/results/ARN038_Grid_Search_MainDataTank_Block-64';
% stimulation = readtable([results_dir '/stimulation.csv']);
% 
% data = [];
% 
% load([results_dir '/ARN038_Grid_Search_MainDataTank_Block-64.mat'], 'data');
% 
% bins                            = [1 4; 4 8;8 14;14 30;30 50;50 75;75 100;100 150;150 200];
% experiment.stimulation_table    = stimulation;
% experiment.data                 = data;
% experiment.sampling_frequency   = 6103.52;
% experiment.n_recording_channels = numel(RA16_ZCH_matrix);
% 
% experiment.pre_stimulation = extract_stimulation_for_experiment( ...
%     experiment, 5, '', -2);
% 
% experiment.post_stimulation = extract_stimulation_for_experiment( ...
%     experiment, 5, '', 4);
% 
% experiment.spectral_biomarker = generate_spectral_biomarker_delta(experiment, bins(1,:));

% data  = innerjoin(experiment.stimulation_table,experiment.spectral_biomarker);
function visualize_parameter_sweep
close all
clc
load('/Volumes/TDT Data/extracted_data/ARN045/1D_Duration/duration_grid_1.2/experiment_table.mat')
load(sprintf('/Volumes/TDT Data/extracted_data/ARN045/1D_Duration/duration_grid_1.2/biomarker_get_average_theta_power_bipolar_window-%d.mat',3));
data  = innerjoin(experiment_table,biomarker_table);
data.stimulation_amplitude = data.stimulation_amplitude_a + data.stimulation_amplitude_b;

figure_flag     = '';
control_data    = [];
error_mode      = 'sem';
y_label         = '';

x1_name         = 'stimulation_duration';
x2_name         = 'pulse_frequency';
x3_name         = 'stimulation_amplitude';

x1              = eval(strcat('data.', x1_name));
x2              = eval(strcat('data.', x2_name));
x3              = eval(strcat('data.', x3_name));


Y               = data.biomarkers;


plot_grouped_subplots(Y, x1, x2, x3, y_label, x1_name, x2_name, x3_name, ...
    [1], figure_flag, control_data, error_mode)
    
grouping = {data.stimulation_duration, data.stimulation_amplitude, data.pulse_frequency};
% [~,~,stats] = anovan(data.biomarkers,grouping,'model','interaction','varnames',{'duration', 'frequency', 'amplitude'});
% figure
% multcompare(stats,'Dimension',[1 3])
% figure
% multcompare(stats,'Dimension',[1 2])
% figure
% multcompare(stats,'Dimension',[2 3])


% mode
% duration
% amplitude_a
% amplitude_b
% pulse_width_a
% pulse_width_b
% gap
% pulse_frequency
% train_frequency
% stim_order
% synchronicity

biomarker   = 'spectral_power';

end

