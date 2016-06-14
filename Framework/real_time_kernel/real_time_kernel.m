function  real_time_kernel
close all;  clc;  dbstop if error;

DEBUG           = 0;
EXPERIMENT_TYPE = 'cross_entropy';

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure TDT Settings %
%%%%%%%%%%%%%%%%%%%%%%%%%%
TD          = connect_to_tdt();
device_name = TD.GetDeviceName(0);
TD_FS       = TD.GetDeviceSF(device_name);
finishup    = onCleanup(@() clean_up(TD));

TD_BUFFER_TIME          = .5; % Seconds (Control policy checked at TD_BUFFER_TIME/2)
TD_READ_BUFFER_SIZE     = 16*ceil(TD_FS*TD_BUFFER_TIME);
TD.SetTargetVal([device_name '.read_durr'], TD_READ_BUFFER_SIZE); % DOES NOT WORK! Need to modify circuit directly

% Get acquisition circuit variables
n_read_pts      = TD_READ_BUFFER_SIZE;
n_buff_pts      = n_read_pts/2; 
curindex        = TD.ReadTargetVEX([device_name '.read_index'], 0, 1, 'F32', 'F32');
buffer_offset   = n_buff_pts;

if DEBUG
    button = questdlg('You are starting in DEBUG mode','Are you sure you want to continue?');
    switch button 
        case 'Cancel'
            return;
        case 'No'
            return;
    end
    
    TD.SetSysMode(2);
else
    TD.SetSysMode(3);
end
pause(0.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure Experiment Objects %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
optimization_object = [];

switch EXPERIMENT_TYPE 
    case 'grid_search'
        [optimization_object, ~, metric_objects] = ...
            configure_grid_search(TD, DEBUG);
        
    case 'cross_entropy'
        [optimization_object, ~, metric_objects] = ...
            configure_cross_entropy(TD, DEBUG);
end

while ~optimization_object.optimization_done

    if buffer_offset == 0 % Second half of buffer
        
        % Check if second half of buffer is full
        while(curindex >= n_buff_pts)
            curindex = TD.ReadTargetVEX([device_name '.read_index'], 0, 1, 'F32', 'F32');
        end
        buffer_offset = n_buff_pts;
 
    else % First half of buffer
        
        % Check if first half of buffer is full
        while(curindex < n_buff_pts)
            curindex = TD.ReadTargetVEX([device_name '.read_index'], 0, 1, 'F32', 'F32');
        end
        buffer_offset = 0; 
        
    end
    
    % Read data from buffer and reshape
    new_data    = TD.ReadTargetVEX([device_name '.read_buff'], ...
        buffer_offset, n_buff_pts, 'F32', 'F32');   
    new_data    = reshape(new_data, 16, n_buff_pts/16)';
    
    % Update metrics
    for c1 = 1:size(metric_objects,2)
        metric_objects{c1}.update_buffer(new_data);
    end
    
    % Iterate optimization step
    optimization_object.optimize();
    
    % Display metrics
    if exist('display_objects', 'var')
        realtime_metric_display(display_objects); 
    end

end  % End While

TD.SetSysMode(0)
end

function TD = connect_to_tdt()
    device_name = '';
    while strcmp(device_name,'')
        TD = actxserver('TDevAcc.X');
        TD.ConnectServer('Local');
        device_name = TD.GetDeviceName(0);
    end
end

function clean_up(TD)
    TD.SetSysMode(0);
    fclose('all');
    close all;
end
