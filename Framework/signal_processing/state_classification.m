function [f_data group class_loo] = state_classification
% Classifier to determine whether the stimulation will result in
% seizure/afterdischarges

% Get data
data_directory              = 'data/ARN035 Kindling Extracted/';
file_list                   = dir(data_directory);
f_sample                    = 25000;
N_bins                      = 10;
bin_size                    = 10;
block_length                = 10;
[AD_blocks,  AD_labels]     = get_AD_Meta;

row_idx                     = 1;

for c1 = 1:length(file_list)
    fname = file_list(c1).name;
    
    if ~strcmp(fname(1), '.')   ...
        && size(fname,2) > 30     ...
        && strcmp(fname(end-3:end),'.mat') ...
         
        block_idx = find(AD_blocks == str2double(fname(28:30)),1);
        
        if ~isempty(block_idx)
            pre_stimulation = [];
            load([data_directory fname]);
        

            data        = pre_stimulation(2,end-block_length*f_sample:end);
%             data        = post_stimulation(2,f_sample*4:block_length*(f_sample+4));

%             data        = (data - mean(data))/std(data);
            params.Fs   = f_sample;
            [S f]       = mtspectrumc(data, params);

            % Bin data
            for c1 = 1:N_bins
                lower = (c1-1)*bin_size;
                upper = bin_size*c1;

                lower_idx = find(f > lower,1);
                upper_idx = find(f > upper,1) -1;
                f_data(row_idx, c1) = sum(S(lower_idx:upper_idx));  


            end

            plot(data);
            group(row_idx) = AD_labels(block_idx)
            row_idx = row_idx+1;
        end
    end
end

size(f_data);
% Separate into training and validation set


% Leave-one-out loop
for c1 = 1:length(group)
   f_data_loo       = f_data([1:c1-1 c1+1:length(group)],:);
   group_loo        = group([1:c1-1 c1+1:length(group)]);
   
   SVMStruct        = svmtrain(f_data_loo, group_loo);
   class_loo(c1)    = svmclassify(SVMStruct, f_data(c1,:));
end
% Train svm classifier with all but one block

% Test classifier with one left out

% End loop
end

function [AD_blocks, AD_labels]= get_AD_Meta

AD_blocks = [161 162 164 165,166,167,168,169,170,171,172,173,174,175,176,...
     177,178,180,181,182,183,184,185,186,187,188,189,194,195,196,197,198, ...
     199,200,203,204,205,206,207,208,209,210,211,212,213];

AD_labels = [1,1,1,2,2,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,...
     2,2,2,1,2,2,2,1,2,2,1,1,2,2,2,1,1,2,1,1,1];

end