function  TPROT_test()
close all;  clc; 

% Set up connection
if ~exist('TD', 'var')
    TD = TPROT();
end

TD.record

TD_FS   = TD.FS{1};

%%%%%%%%%%%%%%%%%%%%%%%
% Logging Information %
%%%%%%%%%%%%%%%%%%%%%%%
animal_id       = '000';
result_dir      = 'results';
log_header      = 'cross_entropy_optimization';
log_pattern     = [result_dir '/' log_header '-ARN%s_%s'];
time_str        = datestr(now, 30);
exp_directory   = sprintf(log_pattern, animal_id, time_str);
mkdir(exp_directory);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure Experiment Objects %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
coherence_1     = coherence(2,[1 2], exp_directory);
pass_through_1  = pass_through(TD_FS,5, exp_directory);
pass_through_2  = pass_through(TD_FS,2, exp_directory);

metric_objects  = {coherence_1,pass_through_1,pass_through_2};

% Configure optimization
optimization_object = cross_entropy_optimization(TD_FS, coherence_1, exp_directory);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure TDT Settings %
%%%%%%%%%%%%%%%%%%%%%%%%%%
TD_BUFFER_TIME          = 1; % Seconds (Control policy checked at TD_BUFFER_TIME/2)
TD_READ_BUFFER_SIZE     = 16*ceil(TD_FS*TD_BUFFER_TIME);
STIM_CHAN               = [1 3 5 7 10 12 14 16];
TD.write('read_durr', TD_READ_BUFFER_SIZE);

% Open all stimulation channels
open_channels(TD, STIM_CHAN);

% Get acquisition circuit variables
n_read_pts      = TD_READ_BUFFER_SIZE;
n_buff_pts      = n_read_pts/2; 
curindex        = TD.read('read_index');

while true
    
    %%%%%%%%%%%%
    % Buffer 1 %
    %%%%%%%%%%%%
    
    % Check if first half of buffer is full
    while(curindex < n_buff_pts)
        curindex = TD.read('read_index');
        pause(.05);
    end
  
    % Read data from buffer and reshape
    posix_time  = posixtime(datetime);
    new_data    = reshape(TD.read('read_buff', 'SIZE', n_buff_pts), 16, n_buff_pts/16)';
    
    % Update metrics
    for c1 = 1:size(metric_objects,2)
        metric_objects{c1}.update_buffer(new_data);
    end
    
    % Iterate optimization step
    optimization_object.optimize(TD);

    %%%%%%%%%%%%
    % Buffer 2 %
    %%%%%%%%%%%%
    
    % Check if second half of buffer is full
    while(curindex > n_buff_pts)
        curindex = TD.read('read_index');
        pause(.05);
    end
    
    % Read data from buffer and reshape
    new_data    = reshape(TD.read('read_buff', 'SIZE', n_buff_pts, 'OFFSET', n_buff_pts),...
                16, n_buff_pts/16)';
    
    % Update metrics
    for c1 = 1:size(metric_objects,2)
        metric_objects{c1}.update_buffer(new_data);
    end
    
    % Iterate optimization step
    optimization_object.optimize(TD);

    %%%%%%%%%%%%%%%
    % Other Steps %
    %%%%%%%%%%%%%%%
    
    % Check read speed
    curindex = TD.read('read_index');
    if(curindex > n_buff_pts)
        warning('Transfer rate too slow');
    end
    
    % Display metrics
    if exist('metric_objects', 'var') 
        realtime_metric_display(metric_objects); 
    end
    
end  % End While

end

