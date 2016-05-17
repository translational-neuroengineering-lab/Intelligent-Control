% function visualize_parameter_sweep
RA16_ZCH_matrix = [4,3,2,1,5,6,7,8];
% 
% results_dir = '/Users/mconnolly/Intelligent Control Repository/results/ARN038_Grid_Search_MainDataTank_Block-64';
% stimulation = readtable([results_dir '/stimulation.csv']);
% 
% data = [];
% 
% load([results_dir '/ARN038_Grid_Search_MainDataTank_Block-64.mat'], 'data');

bins                            = [1 4; 4 8;8 14;14 30;30 50;50 75;75 100;100 150;150 200];
experiment.stimulation_table    = stimulation;
experiment.data                 = data;
experiment.sampling_frequency   = 6103.52;
experiment.n_recording_channels = numel(RA16_ZCH_matrix);

experiment.pre_stimulation = extract_stimulation_for_experiment( ...
    experiment, 5, '', -2);

experiment.post_stimulation = extract_stimulation_for_experiment( ...
    experiment, 5, '', 4);

experiment.spectral_biomarker = generate_spectral_biomarker_delta(experiment, bins);

plot_grouped_lines( Y, independent_variable, grouping_variable,...
        y_label, x_label, group_label, figure_flag, control_data, error_mode )
    
    

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

% end

