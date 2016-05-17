function stimulation_data = extract_stimulation_for_experiment( ...
    experiment, segment_duration, mode, segment_offset)
%EXTRACT_STIMULATION Summary of this function goes here
%   Detailed explanation goes here

sampling_frequency = experiment.sampling_frequency;
if strcmp(mode, 'plot')
%     plot((1:length(experiment.data(1,:)))/experiment.sampling_frequency,experiment.data', ...
%         'color', [.5 .5 .5])
    figure;
    hold on;
end

segment_samples = floor(experiment.sampling_frequency*segment_duration);
for c1 = 1:size(experiment.stimulation_table,1)
    stimulation_time        = experiment.stimulation_table.stimulation_time(c1);
    start_time              = experiment.stimulation_table.experiment_start_time(c1);
    stimulation_duration    = experiment.stimulation_table.duration(c1);
    
    stimulation_start = stimulation_time - start_time;
    stimulation_end   = stimulation_start + stimulation_duration;
    
    if segment_offset > 0
         segment_start  = stimulation_end + segment_offset;
         segment_end    = segment_start + segment_duration;
    elseif segment_offset < 0
        segment_end     = stimulation_start + segment_offset;
        segment_start   = segment_end - segment_duration;
    else
        segment_start   = stimulation_start;
        segment_end     = segment_start + segment_duration;
    end
    
    segment_start_index = floor(segment_start*sampling_frequency);
    segment_end_index   = floor(segment_end*sampling_frequency);
    data_segment        = experiment.data(:,segment_start_index:segment_end_index);
    
    stimulation_data(c1,:,:) = data_segment(:,1:segment_samples);

    if strcmp(mode, 'plot')
        plot_window_start   = floor((stimulation_end - 10)*sampling_frequency);
        plot_window_end     = floor((stimulation_end + 10)*sampling_frequency);

        
        
        if segment_offset > 0
            plot_offset         = stimulation_end-10;
            plot_window_start   = floor((stimulation_end - 10)*sampling_frequency);
            plot_window_end     = floor((stimulation_end + 10)*sampling_frequency);
        elseif segment_offset <= 0
            plot_offset         = stimulation_start-10;
            plot_window_start   = floor((stimulation_start - 10)*sampling_frequency);
            plot_window_end     = floor((stimulation_start + 10)*sampling_frequency);
        end
        
        plot_window  = experiment.data(1, plot_window_start:plot_window_end)';

        plot((1:size(plot_window,1))/sampling_frequency, plot_window, 'color', [.5 .5 .5])
        plot([segment_start segment_start]-plot_offset, [-0.0125 0.0125], 'r-');
        plot([segment_end segment_end]-plot_offset, [-0.0125 0.0125], 'r-');
    end
      
end

if strcmp(mode, 'plot')
    hold off
end

end

