function channel_parameters = generate_channel_parameters( parameters, channels )
%GENERATE_CHANNEL_PARAMETERS Summary of this function goes here
%   Detailed explanation goes here

n_trials            = size(parameters,1);
n_channels          = size(channels,2);
channel_parameters  = nan(n_trials*n_channels, size(parameters,2)+1);

for c1 = 1:n_trials
    channel_parameters((c1-1)*n_channels + 1:c1*n_channels,:) ...
        = [repmat(parameters(c1,:),n_channels,1) channels'];
    
end
end

