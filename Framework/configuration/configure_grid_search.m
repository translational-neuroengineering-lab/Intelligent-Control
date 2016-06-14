function [optimizer, stimulation_manager, metric_objects] = configure_grid_search(TD, DEBUG)

%
% Configure logging
%
animal_id                                   = '045';
experiment_name                             = 'Frequency Grid Search 1';
if strcmp(animal_id, '') ||  strcmp(experiment_name, '')
    [animal_id, experiment_name]                = get_experiment_info(DEBUG);    
end

if DEBUG
    experiment_name = [experiment_name 'DEBUG'];
end
result_dir                                  = 'results/ARN045';
time_str                                    = datestr(now, 30);
log_pattern                                 = [result_dir '/' experiment_name '-ARN%s_%s'];
exp_directory                               = sprintf(log_pattern, animal_id, time_str);
mkdir(exp_directory)

%
% Configure the stimulation_object
%
stimulation_manager                         = stimulator();
stimulation_manager.TD                      = TD;
stimulation_manager.device_name             = TD.GetDeviceName(0);
stimulation_manager.sampling_frequency      = TD.GetDeviceSF(stimulation_manager.device_name);
stimulation_manager.stimulation_channels    = [1 3 5 7 10 12 14 16];

stimulation_manager.stimulation_type        = 'synchronous';
stimulation_manager.stimulation_mode        = 'unipolar';
stimulation_manager.headstage_type          = 'RA16Z_CH';
stimulation_manager.electrode_location      = 'R_HPC';
stimulation_manager.logging_directory       = exp_directory;
stimulation_manager.tank_name               = 'ARN045';
stimulation_manager.block_name              = get_block_name(stimulation_manager.tank_name);
stimulation_manager.initialize();

stimulation_manager.animal_id                = animal_id;
stimulation_manager.experiment_name          = experiment_name;
stimulation_manager.experiment_start_time    = posixtime(datetime('now'));
stimulation_manager.display_log_output       = 'simple';

%
% Configure the metrics and objective function
%
metric_1        = bipolar_spectral_power(stimulation_manager.sampling_frequency,[2 4; 6 8; 11 9;15 13], exp_directory);
metric_2        = bipolar(stimulation_manager.sampling_frequency,[2 4], exp_directory);
metric_objects  = {metric_1, metric_2};

%
% Configure the optimization object
%
optimizer = grid_search();
optimizer.TD                        = TD;
optimizer.stimulation_time_s        = 5;
optimizer.evaluate_delay_s          = 10;

optimizer.n_samples                 = 1;

% Fine grids
% duration  = [.25 .5 .75 1 1.5 2 2.5 3 4 ]
% frequency = [7 11 25 35 42 50 75 100 125 150 175 200] 
% amplitude = [.1 .2 .3 .4 .5 .6] * AD threshold at 4s, 200Hz

optimizer.stimulation_type          = 'synchronous';
optimizer.frequency                 = [7 11 25 35 42 50 75 100 125 150 175 200];
optimizer.duration                  = [3];
optimizer.amplitude                 = [0.6]*2.9;
optimizer.n_repetitions             = 15;
optimizer.width                     = 0.0001;
optimizer.logging_directory         = exp_directory;
optimizer.display_log_output        = 'simple';
optimizer.stimulator                = stimulation_manager;

optimizer.initialize();

end

