function coherence_metrics = generate_coherence_metrics(pre_stimulation, post_stimulation, bins, layers)
dbstop if error
fs                  = 6103.52;
xhz                 = 1:.1:200;
n_trials            = size(pre_stimulation,1);
n_layers            = size(layers,1);
coherence_metrics   = nan(n_trials*n_layers, size(bins,2)-1);

for c1 = 1:n_trials
    for c2 = 1:n_layers
        pre_1               = squeeze(pre_stimulation(c1,layers(c2,1), :));
        pre_2               = squeeze(pre_stimulation(c1,layers(c2,2), :));
        
        post_1              = squeeze(post_stimulation(c1,layers(c2,1), :));
        post_2              = squeeze(post_stimulation(c1,layers(c2,2), :));
        
        [pre_cohere, f]     = mscohere(pre_1, pre_2,  [], [], xhz,fs);
        post_cohere         = mscohere(post_1, post_2, [], [], xhz,fs);
    
        coherence_metrics((c1-1)*n_layers+c2, :) = bin_spectrum(f, post_cohere - pre_cohere, bins);
    end
end

end

function bin_spectrum = bin_spectrum(f, S, bins)
    bin_spectrum = zeros(size(S,1),size(bins,2)-1);
    
    for c1 = 1:size(bins,2)-1
        start_idx           = find(f > bins(c1),1, 'first');
        stop_idx            = find(f < bins(c1+1),1, 'last');
        bin_spectrum(:,c1)  = sum(S(start_idx:stop_idx))';
    end
end