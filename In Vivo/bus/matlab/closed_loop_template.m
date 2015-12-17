close all; clear all; clc;

% Configure Settings
MAX_READ_BUFFER_SIZE    = 16*5000;
MAX_WRITE_BUFFER_SIZE   = 16*50000;
OPEN_VALUE              = 10000;

STIM_CHAN               = [1 3 5 7 10 12 14 16];
READ_CHAN               = [2 4 6 8 9  11 13 15];

% Set up connection
TD = TDEV();
TD.preview
TD.write('read_durr', MAX_READ_BUFFER_SIZE);

% Open all stimulation channels
for c1 = STIM_CHAN
    TD.write(['stim_buff~' num2str(c1)], OPEN_VALUE*ones(1,10));
    TD.write(['dur~' num2str(c1)], 1);
end

% Get acquisition circuit variables
n_read_pts  = length(TD.read('read_buff'));
n_buff_pts  = n_read_pts/2; 
t           = (1:n_buff_pts)/TD.FS{1};

read_index  = TD.read('read_index');
curindex    = TD.read('read_index');

internal_buff = zeros(16, n_read_pts);

% Start while Loop
while true
     
    % Read data from the first half of the buffer
    while(curindex < n_buff_pts)
        curindex = TD.read('read_index');
        fprintf('Current %d, Waiting for %d\n',curindex, length(TD.read('read_buff')));
        pause(.05);
    end
  
    % Reshape and copy data to end of internal buffer
    internal_buff(n_buff_pts + 1:n_buff_pts * 2) = ...
        reshape(TD.read('read_buff', 'SIZE', n_buff_pts), 16, n_buff_pts/16);
        
    % Process Data 
    signal_power = sum(internal_buff(1,:).^2)/size(internal_buff(1,:),2)*1e6;
    
    % Generate Signal
    output = sprintf('Power = %.4f\n', signal_power);
    % arr = [zeros(1,1) ones(1,100) -ones(1,100)];

    % Send Signal
    disp(output);
    % TD.write('stim_buff~4', arr);
    % TD.write('stim_dur~4', numel(arr));
    
    % Read data from the second half of the buffer
    while(curindex > n_buff_pts)
        curindex = TD.read('read_index');
        pause(.05);
    end
    
    % Copy data to begining of internal buffer
    internal_buff(1:n_buff_pts) = ...
        reshape(TD.read('read_buff', 'OFFSET', n_buff_pts, 'SIZE', n_buff_pts), 16, n_buff_pts/16);
    
    % Check read speed
    curindex = TD.read('read_index');

    if(curindex > n_buff_pts)
        warning('Transfer rate too slow');
    end
    % Change Settings
    
    % Check Stop Conditions

    % End While
end