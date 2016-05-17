function spectral_biomarker = generate_spectral_biomarker(data_segment, sampling_frequency, bins)
%GENERATE_SPECTRAL_METRICS Uses the chronux multi-taper spectrum estimation 
% (mtspectrumc) to generate the spectrum of each recording channel and
% returns the pre-post change in power spectral density grouped into bins

params.Fs           = sampling_frequency;
params.tapers       = [3 5];
params.fpass        = [1 200];

[S,f]               = mtspectrumc(data_segment,params);
spectral_biomarker  = bin_spectrum(f, S, bins);

end

function bin_spectrum = bin_spectrum(f, S, bins)
  
n_bins          = size(bins,1);
bin_spectrum    = zeros(size(S,2),n_bins);
    
for c1 = 1:n_bins
    start_idx           = find(f > bins(c1,1),1, 'first');
    stop_idx            = find(f < bins(c1,2),1, 'last');
    bin_spectrum(:,c1)  = sum(S(start_idx:stop_idx,:))';
end
end