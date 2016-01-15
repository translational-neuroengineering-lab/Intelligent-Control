function [ CA3, CA1 ] = data_extraction_testbed( SID )


rapid_kindling_SID_1_CA3_filepath = '/Users/mconnolly/Dropbox/stimulation data/ARN 035 Stim_Bicuculline_Stim 2015-10-13/SID_Date-2015-10-13_Ch-6.mat';
rapid_kindling_SID_1_CA1_filepath = '/Users/mconnolly/Dropbox/stimulation data/ARN 035 Stim_Bicuculline_Stim 2015-10-13/SID_Date-2015-10-13_Ch-11.mat';
rapid_kindling_SID_2_CA3_filepath = '/Users/mconnolly/Dropbox/stimulation data/ARN 035 RapidKindling/ARN035_RapidKindling_Block-157.mat';
rapid_kindling_SID_2_CA1_filepath = '/Users/mconnolly/Dropbox/stimulation data/ARN 035 RapidKindling/ARN035_RapidKindling_Block-157.mat';

fs = 2000;

if strcmp(getenv('OS'), 'Windows_NT')
   file_dir =  'C:\Users\mconnolly\Dropbox\stimulation data\ARN 035 RapidKindling\';
else
   file_dir =  '/Users/mconnolly/Dropbox/stimulation data/ARN 035 RapidKindling/';
end

if(SID == 1)
    SID_1_CA3 = load(rapid_kindling_SID_1_CA3_filepath);
    SID_1_CA1 = load(rapid_kindling_SID_1_CA1_filepath);


    SID_1_CA3_pre   = double(SID_1_CA3.data.streams.Wave.data(1:3.63e4));
    SID_1_CA3_post  = double(SID_1_CA3.data.streams.Wave.data(4.85e4:4.85e4 + 3.63e4-1));
    SID_1_CA1_pre   = double(SID_1_CA1.data.streams.Wave.data(1:3.63e4));
    SID_1_CA1_post  = double(SID_1_CA1.data.streams.Wave.data(4.85e4:4.85e4 + 3.63e4-1));

    SID_1_fs        = round(SID_1_CA3.data.streams.Wave.fs);

    SID_1_CA3_pre   = resample(SID_1_CA3_pre,fs, SID_1_fs);
    SID_1_CA3_post  = resample(SID_1_CA3_post,fs, SID_1_fs);
    SID_1_CA1_pre   = resample(SID_1_CA1_pre,fs, SID_1_fs);
    SID_1_CA1_post  = resample(SID_1_CA1_post,fs, SID_1_fs);

    SID_CA3_pre  = SID_1_CA3_pre(end-10*fs:end);
    SID_CA3_post = SID_1_CA3_post(1:10*fs);
    SID_CA1_pre  = SID_1_CA1_pre(end-10*fs:end);
    SID_CA1_post = SID_1_CA1_post(1:10*fs);
elseif (SID == 2)
    SID_2_CA3       = load(rapid_kindling_SID_2_CA3_filepath);
    SID_2_CA1       = load(rapid_kindling_SID_2_CA1_filepath);

    SID_2_CA3_pre   = double(SID_2_CA3.data.streams.Wave.data(6, 6997:6.84e5));
    SID_2_CA3_post  = double(SID_2_CA3.data.streams.Wave.data(6, 8e5:end));
    SID_2_CA1_pre   = double(SID_2_CA1.data.streams.Wave.data(6, 6997:6.84e5));
    SID_2_CA1_post  = double(SID_2_CA1.data.streams.Wave.data(6, 8e5:end));

    SID_2_fs    = round(SID_2_CA3.data.streams.Wave.fs);

    SID_2_CA3_pre  = resample(SID_2_CA3_pre,2000, SID_2_fs);
    SID_2_CA3_post = resample(SID_2_CA3_post,2000, SID_2_fs);
    SID_2_CA1_pre  = resample(SID_2_CA1_pre,2000, SID_2_fs);
    SID_2_CA1_post = resample(SID_2_CA1_post,2000, SID_2_fs);

    SID_CA3_pre  = SID_2_CA3_pre(end-10*fs:end);
    SID_CA3_post = SID_2_CA3_post(1:10*fs);
    SID_CA1_pre  = SID_2_CA1_pre(end-10*fs:end);
    SID_CA1_post = SID_2_CA1_post(1:10*fs);
    
elseif SID == 3
    filepath = '/Users/mconnolly/Dropbox/stimulation data/ARN 035 RapidKindling/ARN035_RapidKindling_Block-183.mat';
    LFP     = load(filepath);
    LFP_FS  = round(LFP.data.streams.Wave.fs);
    
    t_start = 2*60;
    t_end   = t_start+10;
    
    CA3     = double(LFP.data.streams.Wave.data(4,t_start*LFP_FS:t_end*LFP_FS));
    CA1     = double(LFP.data.streams.Wave.data(13,t_start*LFP_FS:t_end*LFP_FS));
    CA3     = resample(CA3, 2000, LFP_FS);
    CA1     = resample(CA1, 2000, LFP_FS);

    CA3     = CA3 - mean(CA3);
    CA1     = CA1 - mean(CA1);
elseif SID == 4
    filepath = [file_dir 'ARN035_RapidKindling_Block-183.mat'];
    LFP     = load(filepath);
    LFP_FS  = round(LFP.data.streams.Wave.fs);
    
    t_start = 3*60;
    t_end   = t_start+10;
    
    CA3     = double(LFP.data.streams.Wave.data(4,t_start*LFP_FS:t_end*LFP_FS));
    CA1     = double(LFP.data.streams.Wave.data(13,t_start*LFP_FS:t_end*LFP_FS));
    
    CA3     = resample(CA3, 2000, LFP_FS);
    CA1     = resample(CA1, 2000, LFP_FS);
    
    CA3     = CA3 - mean(CA3);
    CA1     = CA1 - mean(CA1);
elseif SID == 5
    filepath = '/Users/mconnolly/Dropbox/stimulation data/ARN 035 RapidKindling/ARN035_RapidKindling_Block-184.mat';
    LFP     = load(filepath);
    LFP_FS  = round(LFP.data.streams.Wave.fs);
    
    t_start = 3*60;
    t_end   = t_start+5;
    
    CA3     = double(LFP.data.streams.Wave.data(4,t_start*LFP_FS:t_end*LFP_FS));
    CA1     = double(LFP.data.streams.Wave.data(13,t_start*LFP_FS:t_end*LFP_FS));
   
    CA3     = resample(CA3, 2000, LFP_FS);
    CA1     = resample(CA1, 2000, LFP_FS);
    
    CA3(1:3) = repmat(CA3(4), 1, 3);
    CA1(1:3) = repmat(CA1(4), 1, 3);
    
    CA3(end-2:end) = repmat(CA3(end-3), 1, 3);
    CA1(end-2:end) = repmat(CA1(end-3), 1, 3);

    CA3     = CA3 - mean(CA3);
    CA1     = CA1 - mean(CA1);
elseif SID == 6
    filepath = '/Users/mconnolly/Dropbox/stimulation data/ARN 035 RapidKindling/ARN035_RapidKindling_Block-184.mat';
    LFP     = load(filepath);
    LFP_FS  = round(LFP.data.streams.Wave.fs);
    
    t_start = 218;
    t_end   = t_start+5;
    
    CA3 = double(LFP.data.streams.Wave.data(4,t_start*LFP_FS:t_end*LFP_FS)); 
    CA1 = double(LFP.data.streams.Wave.data(13,t_start*LFP_FS:t_end*LFP_FS));

    CA3 = resample(CA3, 2000, LFP_FS);
    CA1 = resample(CA1, 2000, LFP_FS);
    
    CA3(1:3) = repmat(CA3(4), 1, 3);
    CA1(1:3) = repmat(CA1(4), 1, 3);
    
    CA3(end-2:end) = repmat(CA3(end-3), 1, 3);
    CA1(end-2:end) = repmat(CA1(end-3), 1, 3);
    
    CA3     = CA3 - mean(CA3);
    CA1     = CA1 - mean(CA1);


elseif SID == 7
    filepath = [file_dir 'ARN035_RapidKindling_Block-169.mat'];
    LFP     = load(filepath);
    LFP_FS  = round(LFP.data.streams.Wave.fs);
    
    t_start = 105;
    t_end   = t_start+10;
    
    CA3 = double(LFP.data.streams.Wave.data(4,t_start*LFP_FS:t_end*LFP_FS)); 
    CA1 = double(LFP.data.streams.Wave.data(13,t_start*LFP_FS:t_end*LFP_FS));

    CA3 = resample(CA3, 2000, LFP_FS);
    CA1 = resample(CA1, 2000, LFP_FS);
    
    CA3     = CA3 - mean(CA3);
    CA1     = CA1 - mean(CA1);
    
    p = polyfit(1:length(CA3), CA3, 2);
    y = polyval(p, 1:length(CA3));
    CA3 = CA3 - y;
    
    p = polyfit(1:length(CA1), CA1, 2);
    y = polyval(p, 1:length(CA1));
    CA1 = CA1 - y;
elseif SID == 8
    filepath = [file_dir 'ARN035_RapidKindling_Block-169.mat'];
    LFP     = load(filepath);
    LFP_FS  = round(LFP.data.streams.Wave.fs);
    
    t_start = 161;
    t_end   = t_start+5;
    
    CA3 = double(LFP.data.streams.Wave.data(4,t_start*LFP_FS:t_end*LFP_FS)); 
    CA1 = double(LFP.data.streams.Wave.data(13,t_start*LFP_FS:t_end*LFP_FS));

    CA3 = resample(CA3, 2000, LFP_FS);
    CA1 = resample(CA1, 2000, LFP_FS);
    
    CA3     = CA3 - mean(CA3);
    CA1     = CA1 - mean(CA1);
    
    p = polyfit(1:length(CA3), CA3, 2);
    y = polyval(p, 1:length(CA3));
    CA3 = CA3 - y;
    
    p = polyfit(1:length(CA1), CA1, 2);
    y = polyval(p, 1:length(CA1));
    CA1 = CA1 - y;
end

end



% SID_1_pre = SID_1.data.streams.Wave.data(3e5:4e5);
% SID_1_post = SID_1.data.streams.Wave.data(4.15e5:5.15e5);
