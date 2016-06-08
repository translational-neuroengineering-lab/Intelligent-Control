function [optimizer, stimulation_manager, metric_objects] = configure_cross_entropy(TD, DEBUG)
%
% Configure logging
%
result_dir                                  = 'results/ARN045';
animal_id                                   = '045';
experiment_name                             = 'cross_entropy_optimization_frequency_theta_power_delta_minmization';
if strcmp(animal_id, '') ||  strcmp(experiment_name, '')
    [animal_id, experiment_name]                = get_experiment_info(DEBUG);    
end

if DEBUG
    experiment_name = [experiment_name 'DEBUG'];
end

time_str                                    = datestr(now, 30);
log_pattern                                 = [result_dir '/' experiment_name '-ARN%s_%s'];
exp_directory                               = sprintf(log_pattern, animal_id, time_str);
mkdir(exp_directory);

%
% Configure the stimulation_object
%
stimulation_manager                         = stimulator();
stimulation_manager.TD                      = TD;
stimulation_manager.device_name             = TD.GetDeviceName(0);
stimulation_manager.sampling_frequency      = TD.GetDeviceSF(stimulation_manager.device_name);
stimulation_manager.stimulation_channels    = [1 3 5 7 10 12 14 16];

stimulation_manager.stimulation_frequency   = 100;
stimulation_manager.stimulation_duration    = 3;
stimulation_manager.stimulation_amplitude   = 1.5;
stimulation_manager.stimulation_pulse_width = 0.0001; %100 microsecond pulse-width
            
stimulation_manager.stimulation_type        = 'synchronous';
stimulation_manager.stimulation_mode        = 'unipolar';
stimulation_manager.headstage_type          = 'RA16Z_CH';
stimulation_manager.electrode_location      = 'R_HPC';
stimulation_manager.logging_directory       = exp_directory;
stimulation_manager.tank_name               = 'ARN045';
stimulation_manager.block_name              = get_block_name(stimulation_manager.tank_name);

stimulation_manager.animal_id               = animal_id;
stimulation_manager.experiment_name         = experiment_name;
stimulation_manager.experiment_start_time   = posixtime(datetime('now'));
stimulation_manager.display_log_output      = 0;
stimulation_manager.initialize();
%
% Configure the metrics and objective function
%
metric_1        = bipolar_spectral_power(stimulation_manager.sampling_frequency,[2 4; 6 8; 11 9;15 13], exp_directory);
metric_2        = bipolar(stimulation_manager.sampling_frequency,[2 4], exp_directory);
metric_objects  = {metric_1};

%
% Configure the optimization object
%
optimizer                           = cross_entropy_optimization();
optimizer.TD                        = TD;
optimizer.device_name               = TD.GetDeviceName(0);
optimizer.sampling_frequency        = TD.GetDeviceSF(optimizer.device_name);
optimizer.objective_function        = metric_1; 
optimizer.objective_window_s        = 3;
optimizer.objective_type            = 'delta';
optimizer.optimization_direction    = 'minimize';

% Sampling distribution
optimizer.stimulation_parameter     = 'frequency';

optimizer.distribution              = 'gaussian';         
optimizer.n_parameters              = 1;
optimizer.mu                        = 100;
optimizer.sigma                     = 100;
optimizer.lower_bound               = 1;
optimizer.upper_bound               = 200;
optimizer.logging_directory         = exp_directory;

optimizer.stimulation_time_s        = 3;
optimizer.evaluate_delay_s          = 3;
optimizer.samples_per_cycle         = 100;
optimizer.n_elite_samples           = 10;
optimizer.stimulator                = stimulation_manager;

optimizer.initialize();
end