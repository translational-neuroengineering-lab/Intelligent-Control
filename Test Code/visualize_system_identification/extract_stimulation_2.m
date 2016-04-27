function [data_struct] = extract_stimulation( ...
    results_dir, data_file, segment_duration, mode, segment_offset, sampling_frequency)
%EXTRACT_STIMULATION Summary of this function goes here
%   Detailed explanation goes here

if ~exist('sampling_frequency', 'var') || isempty(sampling_frequency)
    sampling_frequency = 6103.52;
end

data                = [];

load(data_file);

fid         = fopen([results_dir '/stimulation.csv']);
stimulation = textscan(fid,'%f %f %f %f %f %s','Delimiter',',');
fclose(fid);

start_time  = csvread([results_dir '/start_time.csv']);

if strcmp(mode, 'plot')
    plot((1:length(data(1,:)))/sampling_frequency,data', 'color', [.5 .5 .5])
    hold on;
end

for c1 = 1:size(stimulation{1},1)
    data_struct(c1).stimulation_time        = stimulation{1}(c1);
    data_struct(c1).stimulation_frequency   = stimulation{2}(c1);
    data_struct(c1).stimulation_duration    = stimulation{3}(c1);
    data_struct(c1).stimulation_amplitude   = stimulation{4}(c1);
    data_struct(c1).stimulation_width       = stimulation{5}(c1);
    data_struct(c1).stimulation_mode        = stimulation{6}(c1);
    data_struct(c1).segment_offset          = segment_offset;
    data_struct(c1).segment_duration        = segment_duration;
    
    stimulation_start = data_struct(c1).stimulation_time - start_time;
    stimulation_end   = stimulation_start + data_struct(c1).stimulation_duration;
    
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
    data_segment        = data(:,segment_start_index:segment_end_index);
    
    data_struct(c1).data = data_segment;

    if strcmp(mode, 'plot')
        plot([segment_start segment_start], [-0.0125 0.0125], 'r-');
        plot([segment_end segment_end], [-0.0125 0.0125], 'r-');
    end
      
end

if strcmp(mode, 'plot')
    hold off
end

end

