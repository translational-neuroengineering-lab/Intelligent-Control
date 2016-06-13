function biomarker_table = generate_spectral_biomarker_directory( directory )
%GENERATE_SPECTRAL_BIOMARKER_DIRECTROY Summary of this function goes here
%   Detailed explanation goes here

      
directory       = '/Volumes/TDT Data/extracted_data/ARN045/';
data            = [];
params.tapers   = [3 5];
params.fpass    = [4 100];

load([directory 'experiment_table.mat']);
d = dir(directory);

n_files             = numel(d);
biomarkers          = nan(n_files,1);
stimulation_time    = nan(n_files,1);

for c1 = 1:n_files
    file_name = d(c1).name;
    if strcmp(file_name(1), '3');
        load([directory file_name]);
        
        l_index             = experiment_table.stimulation_time == stim_start;
        sampling_frequency  = experiment_table.sampling_frequency(l_index);
        duration            = experiment_table.stimulation_duration(l_index);
        
        stimulation_start   = stim_start - t1;
        stimulation_end     = stimulation_start+duration + 0.002;       
        
        pre_stimulation_start       = floor((stimulation_start - .95)*sampling_frequency);
        pre_stimulation_stop        = floor(stimulation_start*sampling_frequency);
        
        post_stimulation_start      = floor(stimulation_end*sampling_frequency);
        post_stimulation_stop       = floor((stimulation_end + .95)*sampling_frequency);
        
        pre_stimulation_segment     = data(:,pre_stimulation_start:pre_stimulation_stop);
        post_stimulation_segment    = data(:,post_stimulation_start:post_stimulation_stop);
        
        params.Fs   = sampling_frequency;
        pre_S       = mtspectrumc(pre_stimulation_segment',params);
        post_S      = mtspectrumc(post_stimulation_segment',params);

        delta_S                 = post_S - pre_S;
        biomarkers(c1)          = mean(sum(delta_S));
        stimulation_time(c1)    = experiment_table.stimulation_time(l_index);
        
%         t = (1:length(data(1,:)))/sampling_frequency;
%         plot(t, data(1,:))
%         hold on
%         plot(t(pre_stimulation_start:pre_stimulation_stop), pre_stimulation_segment(1,:));
%         plot([stim_start stim_start] - t1, [-0.01 0.01])
%         plot([stimulation_end stimulation_end] - t1, [-0.01 0.01])
%         hold off
        c1
    end
end
stimulation_time    = stimulation_time(~isnan(stimulation_time));
biomarkers          = biomarkers(~isnan(biomarkers));

biomarker_table     = table(stimulation_time, biomarkers);
end

