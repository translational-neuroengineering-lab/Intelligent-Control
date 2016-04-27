function [baseline_matrix_pre, baseline_matrix_post] = extract_baseline(results_dir, data_file, duration, mode)
%EXTRACT_STIMULATION Summary of this function goes here
%   Detailed explanation goes here

fs                      = 6103.52;
data                    = [];
baseline_matrix_pre     = [];
baseline_matrix_post    = [];

load(data_file);

fid         = fopen([results_dir '/stimulation.csv']);
stimulation = textscan(fid,'%f %f %f %f %f %s','Delimiter',',');
fclose(fid);

start_time  = csvread([results_dir '/start_time.csv']);

if strcmp(mode, 'plot')
    plot((1:length(data(1,:)))/fs,data', 'color', [.5 .5 .5])
    hold on;
end

for c1 = 1:size(stimulation{1},1)-1
    
    baseline_midpoint       = stimulation{1}(c1) - start_time + ...
                            (stimulation{1}(c1+1) - stimulation{1}(c1))/2;
    baseline_duration       = stimulation{3}(c1);
    
    baseline_start          = baseline_midpoint - 1.5;
    pre_baseline_start      = baseline_start - duration;
    
    baseline_end            = baseline_start + baseline_duration + 3;
    post_baseline_end       = baseline_end + duration;
    
    pre_baseline            = data(:,floor(pre_baseline_start*fs:baseline_start*fs));
    post_baseline           = data(:,floor(baseline_end*fs:post_baseline_end*fs));

    switch mode
        case 'save'
            save(sprintf('%s/extracted_baseline_%.3d.mat',results_dir, c1),          ...
                'pre_baseline', 'post_baseline');

        case 'plot'
            plot([baseline_start baseline_start], [-0.0125 0.0125], 'r-');
            plot([baseline_end baseline_end], [-0.0125 0.0125], 'k-');
        
        case 'matrix'
            baseline_matrix_pre(c1,:,:)     = pre_baseline;
            baseline_matrix_post(c1,:,:)    = post_baseline;
            
    end
end

if strcmp(mode, 'plot')
    hold off
end

end

