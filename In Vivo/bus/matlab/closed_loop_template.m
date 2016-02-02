close all;  clc;

% Set up connection
if ~exist('TD', 'var')
    TD = TDEV();
end
TD.preview
TD_FS   = TD.FS{1};

% Configure Settings
BUFFER_TIME             = .5;

TD_READ_BUFFER_SIZE     = 16*ceil(TD_FS*BUFFER_TIME);
TD_WRITE_BUFFER_SIZE    = 16*ceil(TD_FS*BUFFER_TIME);
OPEN_VALUE              = 10000;

STIM_CHAN               = [1 3 5 7 10 12 14 16];
READ_CHAN               = [2 4 6 8 9  11 13 15];

DATA_VEC_SIZE           = 16;
DATA_BUFFER_SIZE        = ceil(TD_FS*BUFFER_TIME)*10;

DATA_BUFFER             = circVBuf(int64(DATA_BUFFER_SIZE), int64(DATA_VEC_SIZE), 0);
FREQ_BUFFER             = circVBuf(int64(10), int64(ceil(TD_FS*BUFFER_TIME/4)), 0);

TD.write('read_durr', TD_READ_BUFFER_SIZE);

% Open all stimulation channels
for c1 = STIM_CHAN
    TD.write(['stim_buff~' num2str(c1)], OPEN_VALUE*ones(1,10));
    TD.write(['dur~' num2str(c1)], 1);
end

% Get acquisition circuit variables
n_read_pts  = TD_READ_BUFFER_SIZE;%length(TD.read('read_buff'));
n_buff_pts  = n_read_pts/2; 
t           = (1:n_buff_pts)/TD_FS;

read_index  = TD.read('read_index');
curindex    = TD.read('read_index');

internal_buff = zeros(16, n_read_pts);

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
    
    % Process Data 
    signal_power = sum(new_data(:,2).^2)/size(new_data(:,2),1)*1e6;
    f = fft(new_data(:,2));
    FREQ_BUFFER.append(abs(f(1:end/2))');
    
    % Generate Signal
    subplot(2,1,1)
    t = double((1:DATA_BUFFER.lst-DATA_BUFFER.fst+1))/TD_FS;
    plot(t, DATA_BUFFER.raw(DATA_BUFFER.fst:DATA_BUFFER.lst,2));
    xlim([0, t(end)]);
    subplot(2,1,2)
    spectrogram(DATA_BUFFER.raw(DATA_BUFFER.fst:DATA_BUFFER.lst,2),128,120,128,TD.FS{1},'yaxis')
    ylim([0 1])
    colorbar off
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
%     internal_buff(1:n_buff_pts) = ...
%         reshape(TD.read('read_buff', 'OFFSET', n_buff_pts, 'SIZE', n_buff_pts), 16, n_buff_pts/16);
    DATA_BUFFER.append(reshape(TD.read('read_buff', 'OFFSET', n_buff_pts, 'SIZE', n_buff_pts), 16, n_buff_pts/16)');
    
    % Check read speed
    curindex = TD.read('read_index');

    if(curindex > n_buff_pts)
        warning('Transfer rate too slow');
    end
    % Change Settings
    
    % Check Stop Conditions

    % End While
end