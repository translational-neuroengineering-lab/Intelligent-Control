function [pre_stimulation, post_stimulation] = normalize_stimulation_data(pre_stimulation, post_stimulation)
%NORMALIZE_STIMULATION_DATA
% Subtracts the mean and divides by standard deviation  of 3D data blocks 
% structured as stimulation_data(trial, channel, data)

pre_stimulation     = pre_stimulation - repmat(mean(pre_stimulation,3), 1, 1,size(pre_stimulation,3));
post_stimulation    = post_stimulation - repmat(mean(post_stimulation,3),1,1, size(post_stimulation,3));

pre_stimulation     = pre_stimulation./repmat(std(pre_stimulation,[],3),1,1, size(pre_stimulation,3));
post_stimulation    = post_stimulation./repmat(std(post_stimulation,[],3),1,1, size(post_stimulation,3));

end