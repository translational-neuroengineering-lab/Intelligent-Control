function [data_matrix_pre, data_matrix_post, parameter_matrix] = extract_stimulation(results_dir, data_file, duration, mode)
%EXTRACT_STIMULATION Summary of this function goes here
%   Detailed explanation goes here

fs                  = 6103.52;
data                = [];
data_matrix_pre     = [];
data_matrix_post    = [];
parameter_matrix    = [];

load(data_file);

fid         = fopen([results_dir '/stimulation.csv']);
stimulation = textscan(fid,'%f %f %f %f %f %s','Delimiter',',');
fclose(fid);

start_time  = csvread([results_dir '/start_time.csv']);

if strcmp(mode, 'plot')
    plot((1:length(data(1,:)))/fs,data', 'color', [.5 .5 .5])
    hold on;
end

for c1 = 1:size(stimulation{1},1)
    stimulation_time        = stimulation{1}(c1);
    stimulation_frequency   = stimulation{2}(c1);
    stimulation_duration    = stimulation{3}(c1);
    stimulation_amplitude   = stimulation{4}(c1);
    stimulation_width       = stimulation{5}(c1);
    
    if strcmp(stimulation{6}(c1),'synchronous')
        stimulation_mode = 1;
    elseif strcmp(stimulation{6}(c1),'asynchronous_high_frequency')
        stimulation_mode = 2;
    end
    
    stim_start              = stimulation_time - start_time - 1.5;
    pre_start               = stim_start - duration;
    
    stim_end                = stim_start + stimulation_duration + 3;
    post_end                = stim_end + duration;
    
    pre_stimulation         = data(:,floor(pre_start*fs:stim_start*fs));
    post_stimulation        = data(:,floor(stim_end*fs:post_end*fs));

    switch mode
        case 'save'
            save(sprintf('%s/extracted_stimulation_%.3d.mat',results_dir, c1),          ...
                'pre_stimulation', 'post_stimulation', 'stimulation_frequency',         ...
                'stimulation_duration', 'stimulation_amplitude', 'stimulation_width',   ...
                'stimulation_mode');

        case 'plot'
            plot([stim_start stim_start], [-0.0125 0.0125], 'r-');
            plot([stim_end stim_end], [-0.0125 0.0125], 'k-');
        
        case 'matrix'
            data_matrix_pre(c1,:,:)     = pre_stimulation;
            data_matrix_post(c1,:,:)    = post_stimulation;
            parameter_matrix(c1,:)      = [stimulation_frequency,   ...
                                        stimulation_duration,       ...
                                        stimulation_amplitude,      ...
                                        stimulation_width,          ...
                                        stimulation_mode];
    end
end

if strcmp(mode, 'plot')
    hold off
end

end

