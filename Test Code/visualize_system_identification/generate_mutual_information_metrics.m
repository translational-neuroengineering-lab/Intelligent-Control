function mutual_information_metrics = generate_mutual_information_metrics(pre_stimulation, post_stimulation, layers)

n_trials = size(pre_stimulation,1);
n_layers = size(layers,1);

mutual_information_metrics = nan(n_trials*n_layers,1);
for c1 = 1:n_trials
    for c2 = 1:n_layers
        
        pre_mi  = mutualinfo(squeeze(pre_stimulation(c1,layers(c2,1),:)), ...
            squeeze(pre_stimulation(c1,layers(c2,2),:)));
        
        post_mi  = mutualinfo(squeeze(post_stimulation(c1,layers(c2,1),:)), ...
            squeeze(post_stimulation(c1,layers(c2,2),:)));
        
        mutual_information_metrics((c1-1)*n_layers+c2, :) = post_mi - pre_mi;
        
    end
end

end