function spectral_biomarker = generate_spectral_biomarker_trial(data_segment, sampling_frequency, bins )
%GENERATE_SPECTRAL_BIOMARKER_TRIAL Summary of this function goes here
%   Detailed explanation goes here

n_trials            = size(data_segment,1);
n_channels          = size(data_segment,2);
n_bins              = size(bins,1);
spectral_biomarker  = nan(n_trials*n_channels, n_bins);

for c1 = 1:n_trials
    
    trial_segment   = squeeze(data_segment(c1,:,:))';
      
    spectral_biomarker((c1-1)*n_channels+1:c1*n_channels,:) ...
        = generate_spectral_biomarker(trial_segment, sampling_frequency, bins);

end
end

