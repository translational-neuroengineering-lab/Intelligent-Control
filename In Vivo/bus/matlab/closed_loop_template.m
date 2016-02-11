function closed_loop_template(TD)
close all;  clc; 

% Control function
control_function = @threshold_stimulation;

% Set up connection
if ~exist('TD', 'var')
    TD = TDEV();
end
TD.record
TD_FS   = TD.FS{1};

% Configure Settings
TD_BUFFER_TIME          = 1; % Seconds (Control policy checked at TD_BUFFER_TIME/2)

TD_READ_BUFFER_SIZE     = 16*ceil(TD_FS*TD_BUFFER_TIME);
TD_WRITE_BUFFER_SIZE    = 16*ceil(TD_FS*TD_BUFFER_TIME);

STIM_CHAN               = [1 3 5 7 10 12 14 16];
READ_CHAN               = [2 4 6 8 9  11 13 15];

DATA_VEC_SIZE           = 16;
DATA_BUFFER_SIZE        = TD_FS*10;
DATA_BUFFER             = circVBuf(int64(DATA_BUFFER_SIZE), int64(DATA_VEC_SIZE), 0);

TD.write('read_durr', TD_READ_BUFFER_SIZE);

% Open all stimulation channels
open_channels(TD, STIM_CHAN);

% Get acquisition circuit variables
n_read_pts      = TD_READ_BUFFER_SIZE;
n_buff_pts      = n_read_pts/2; 
curindex        = TD.read('read_index');

% Start while Loop
while true
     
    % Read data from the first half of the buffer
    while(curindex < n_buff_pts)
        curindex = TD.read('read_index');
        pause(.05);
    end
  
    % Reshape and copy data to end of internal buffer   
    new_data = reshape(TD.read('read_buff', 'SIZE', n_buff_pts), 16, n_buff_pts/16)';
    DATA_BUFFER.append(new_data);
    
    % Send data to control function 
    control_function(TD, DATA_BUFFER);
    
    % Read data from the second half of the bus buffer
    while(curindex > n_buff_pts)
        curindex = TD.read('read_index');
        pause(.05);
    end
    new_data = reshape(TD.read('read_buff', 'OFFSET', n_buff_pts, 'SIZE', n_buff_pts), 16, n_buff_pts/16)';
    
    % Append data to internal circular buffer
    DATA_BUFFER.append(new_data);
    
    % Send data to control function % TODO Optimize this 
    control_function(TD, DATA_BUFFER);    
    
    % Check read speed
    curindex = TD.read('read_index');
    if(curindex > n_buff_pts)
        warning('Transfer rate too slow');
    end
    
    % Change Settings
    % TODO
    
    % Check Stop Conditions
    % TODO
    
end  % End While

end

