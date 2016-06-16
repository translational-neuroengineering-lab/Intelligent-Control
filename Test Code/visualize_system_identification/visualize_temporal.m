% RA16_ZCH_matrix = [4,3,2,1; 5,6,7,8];
 
results_dir = '/Users/mconnolly/Intelligent Control Repository/results/ARN038_Grid_Search_MainDataTank_Block-63';
stimulation = readtable([results_dir '/stimulation.csv']);

data = [];

load([results_dir '/ARN038_Grid_Search_MainDataTank_Block-63.mat'], 'data');

bins                            = [1 4; 4 8;8 14;14 30;30 50;50 75;75 100;100 150;150 200];
experiment.stimulation_table    = stimulation;
experiment.data                 = data;
experiment.sampling_frequency   = 6103.52;
experiment.n_recording_channels = numel(RA16_ZCH_matrix);
%% fdf

params.Fs = experiment.sampling_frequency;
params.tapers = [3 5];
params.fpass = [4 10];

experiment.pre_stimulation = extract_stimulation_for_experiment( ...
    experiment, 40, '', -20);
durs = unique(experiment.stimulation_table.duration);

theta = [];
for c1 = 1:numel(durs)
    dur_idx = find(experiment.stimulation_table.duration == durs(c1));
    
    
    for c2 = 1:numel(dur_idx)
        cr(1, :) = squeeze(experiment.pre_stimulation(dur_idx(c2),1,:) - experiment.pre_stimulation(dur_idx(c2),2,:));
        cr(2, :) = squeeze(experiment.pre_stimulation(dur_idx(c2),3,:) - experiment.pre_stimulation(dur_idx(c2),4,:));
        cr(3, :) = squeeze(experiment.pre_stimulation(dur_idx(c2),6,:) - experiment.pre_stimulation(dur_idx(c2),5,:));
        cr(4, :) = squeeze(experiment.pre_stimulation(dur_idx(c2),8,:) - experiment.pre_stimulation(dur_idx(c2),7,:));
%         channel_data = squeeze(experiment.pre_stimulation(dur_idx(c2),:,:))';
        
%         [S,t,f,] = mtspecgramc(channel_data,[.5 .2], params);
        [S,t,f,] = mtspecgramc(cr',[.25 .1], params);
%         imagesc(t,f,log(S(:,:,1))')
        theta(c1,c2,:) = sum(sum(S,3),2);
    end
    
    subplot(numel(durs), 1, c1)
    plot(t, log10(squeeze(theta(c1,:,:))));
end

% plot(mean(theta(1,:,:)))
