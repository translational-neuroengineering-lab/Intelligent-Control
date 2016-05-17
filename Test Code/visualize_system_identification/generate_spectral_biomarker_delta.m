function delta_spectral_biomarker_table = generate_spectral_biomarker_delta( experiment, bins )
%GENERATE_SPECTRAL_BIOMARKER_DELTA Summary of this function goes here
%   Detailed explanation goes here

sampling_frequency          = experiment.sampling_frequency;
spectral_biomarker_pre      = generate_spectral_biomarker_trial(experiment.pre_stimulation, sampling_frequency, bins);
spectral_biomarker_post     = generate_spectral_biomarker_trial(experiment.post_stimulation, sampling_frequency, bins);

delta_spectral_biomarker    = spectral_biomarker_post - spectral_biomarker_pre;

n_trials                    = size(experiment.pre_stimulation,1);
n_channels                  = experiment.n_recording_channels;
n_measurements              = size(delta_spectral_biomarker,1);

stimulation_time            = reshape(repmat(experiment.stimulation_table.stimulation_time, 1,n_channels)',1,n_measurements)';
biomarker_channels          = reshape(repmat(1:n_channels,n_trials,1)',1,n_measurements)';
delta_spectral_biomarker_table = array2table(delta_spectral_biomarker);

delta_spectral_biomarker_table.stimulation_time     = stimulation_time;
delta_spectral_biomarker_table.biomarker_channel    = biomarker_channels;
end

