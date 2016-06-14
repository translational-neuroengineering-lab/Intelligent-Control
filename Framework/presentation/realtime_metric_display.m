function  realtime_metric_display( metric_objects)
%REALTIME_DISPLAY Summary of this function goes here
%   Detailed explanation goes here

n_displays  = length(metric_objects);
for c1 = 1:n_displays
    
    subplot(n_displays,1, c1)
    duration = 10;
    data = metric_objects{c1}.get_metric();
    fs   = metric_objects{c1}.sampling_frequency;
    
    t = fliplr(0:1/fs:duration)*-1;
    L = min(length(t), length(data));
    plot(t(1:L), real(data(1:L)));
    ylabel(metric_objects{c1}.name);
    if isprop(metric_objects{c1}, 'ylim') && ~isempty(metric_objects{c1}.ylim)
        ylim(metric_objects{c1}.ylim)
    end
    xlim([-1*duration 0])
end
drawnow
end

