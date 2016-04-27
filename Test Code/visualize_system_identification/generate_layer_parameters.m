function layer_parameters = generate_layer_parameters( parameters, layers )
%GENERATE_LAYER_PARAMETERS Summary of this function goes here
%   Detailed explanation goes here

n_trials            = size(parameters,1);
n_layers            = size(layers,1);
layer_parameters    = nan(n_trials*n_layers, size(parameters,2)+1);

for c1 = 1:n_trials
    layer_parameters((c1-1)*n_layers + 1:c1*n_layers,:) ...
        = [repmat(parameters(c1,:),n_layers,1) (1:4)'];
    
end
end

