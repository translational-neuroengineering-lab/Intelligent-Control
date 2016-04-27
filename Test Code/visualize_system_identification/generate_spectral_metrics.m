function spectral_metrics = generate_spectral_metrics(pre_stimulation, post_stimulation, bins)
%GENERATE_SPECTRAL_METRICS Uses the chronux multi-taper spectrum estimation 
% (mtspectrumc) to generate the spectrum of each recording channel and
% returns the pre-post change in power spectral density grouped into bins

params.Fs           = 6103.52;
params.tapers       = [3 5];
params.fpass        = [1 200];
n_trials            = size(pre_stimulation,1);
n_channels          = size(pre_stimulation,2);

spectral_metrics    = nan(n_trials*n_channels, size(bins,2) - 1);

for c1 = 1:n_trials
    [pre_S,~]           = mtspectrumc(squeeze(pre_stimulation(c1,:,:))',params);
    [post_S,f]          = mtspectrumc(squeeze(post_stimulation(c1,:,:))',params);
   
    spectral_metrics((c1-1)*n_channels+1:c1*n_channels,:)    ...
                        = bin_spectrum(f, post_S - pre_S, bins);

end

end

function bin_spectrum = bin_spectrum(f, S, bins)
    bin_spectrum = zeros(size(S,2),size(bins,2)-1);
    
    for c1 = 1:size(bins,2)-1
        start_idx           = find(f > bins(c1),1, 'first');
        stop_idx            = find(f < bins(c1+1),1, 'last');
        bin_spectrum(:,c1)  = sum(S(start_idx:stop_idx,:))';
    end
end