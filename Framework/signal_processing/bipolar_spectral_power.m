classdef bipolar_spectral_power < handle
    %COHERENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DATA_BUFFER_DURRATION
        DATA_VEC_SIZE
        DATA_BUFFER_SIZE
        DATA_BUFFER
        
        SPECTRAL_POWER_BUFFER_DURRATION
        SPECTRAL_POWER_VEC_SIZE
        SPECTRAL_POWER_BUFFER_SIZE
        SPECTRAL_POWER_BUFFER
        
        params
        sampling_frequency        
        channels
        ylim
        name
        
        bin_min
        bin_max
    end
    
    methods
        function obj = bipolar_spectral_power(TD_FS, channels, ~)
            obj.sampling_frequency                  = 4;
            obj.channels                            = channels;
            
            obj.DATA_BUFFER_DURRATION               = 3;
            obj.DATA_VEC_SIZE                       = 4;
            obj.DATA_BUFFER_SIZE                    = obj.DATA_BUFFER_DURRATION*TD_FS;
            obj.DATA_BUFFER                         = circVBuf(int64(obj.DATA_BUFFER_SIZE),...
                                                    int64(obj.DATA_VEC_SIZE), 0);
            
            obj.SPECTRAL_POWER_BUFFER_DURRATION     = 20;
            obj.SPECTRAL_POWER_VEC_SIZE             = 1;
            obj.SPECTRAL_POWER_BUFFER_SIZE          = obj.SPECTRAL_POWER_BUFFER_DURRATION*obj.sampling_frequency;
            obj.SPECTRAL_POWER_BUFFER               = circVBuf(int64(obj.SPECTRAL_POWER_BUFFER_SIZE),...
                                                    int64(obj.SPECTRAL_POWER_VEC_SIZE), 0);

            obj.params.Fs                           = TD_FS;
            obj.params.tapers                       = [3 5];
            obj.params.fpass                        = [4 10];

            obj.name                                = sprintf('Bipolar Spectral Power (%d-%dHz)', obj.params.fpass(1), obj.params.fpass(2));

            
        end
        
        function update_buffer(obj, new_data)
            
            new_data    = new_data - repmat(mean(new_data),size(new_data,1),1);
            new_data    = new_data ./ repmat(std(new_data),size(new_data,1),1);
            
            channel_a   = new_data(:,obj.channels(:,1))-new_data(:,obj.channels(:,2));
            obj.DATA_BUFFER.append(channel_a);

        end
        
        function m = get_metric(obj,t)
            if t
                plot(obj.DATA_BUFFER.raw(obj.DATA_BUFFER.fst:obj.DATA_BUFFER.lst))
            end
            [S, ~]  = mtspectrumc(obj.DATA_BUFFER.raw(obj.DATA_BUFFER.fst:obj.DATA_BUFFER.lst,:), obj.params);
            m       = mean(sum(S));
            
        end
        
        function update_metric(~)
            
        end
    end
    
end

