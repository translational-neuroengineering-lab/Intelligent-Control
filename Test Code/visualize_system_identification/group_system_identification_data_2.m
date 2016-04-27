function group_system_identification_data

tic
bins            = [1 4 8 14 30 50 75 100 150 200];
layers          = [1 8; 2 7; 3 6; 4 5];
channels        = [2 4 6 8 9 11 13 15];
results_home    = '/Users/mconnolly/Dropbox/Grid_search_data/';

data_files  = {'ARN038_Grid_Search_MainDataTank_Block-50' ...
    'ARN038_Grid_Search_MainDataTank_Block-53' ...
    'ARN038_Grid_Search_MainDataTank_Block-55' ...
    'ARN038_Grid_Search_MainDataTank_Block-57' ...
    'ARN038_Grid_Search_MainDataTank_Block-59' ...
    'ARN038_Grid_Search_MainDataTank_Block-61' ...
    'ARN038_Grid_Search_MainDataTank_Block-63' ...
    'ARN038_Grid_Search_MainDataTank_Block-64' ...
    };

spectral_metrics            = [];
spectral_baseline           = [];
coherence_metrics           = [];
coherence_baseline          = [];
correlation_metrics         = [];
correlation_baseline        = [];
mutual_information_metrics  = [];
mutual_information_baseline = [];
channel_parameters          = [];
layer_parameters            = [];

segment_duration            = 1;
segment_offset              = -2;
mode                        = 'plot';
sampling_frequency          = 6103.52;

% Extract data 
for c1 = 1:size(data_files,2)
    result_directory = [results_home data_files{c1}];
    data_file        = [results_home data_files{c1} '/' data_files{c1} '.mat']
    
    data_struct = extract_stimulation(result_directory, data_file, ...
    segment_duration, mode, segment_offset, sampling_frequency) 
  

end           