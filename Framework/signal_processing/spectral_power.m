classdef spectral_power < handle
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
        function obj = spectral_power(TD_FS, channels, ~)
            obj.sampling_frequency                  = 2;
            obj.channels                            = channels;
            obj.SPECTRAL_POWER_BUFFER_DURRATION     = 20;
            obj.SPECTRAL_POWER_VEC_SIZE             = 1;
            obj.SPECTRAL_POWER_BUFFER_SIZE          = TD_FS*obj.SPECTRAL_POWER_BUFFER_DURRATION/(TD_FS*.5);
            obj.SPECTRAL_POWER_BUFFER               = circVBuf(int64(obj.SPECTRAL_POWER_BUFFER_SIZE),...
                                                    int64(obj.SPECTRAL_POWER_VEC_SIZE), 0);
            obj.ylim                                = [0 1];
            obj.params.Fs                           = TD_FS;
            obj.params.tapers                       = [3 5];
            obj.bin_min                             = 4;
            obj.bin_max                             = 10;
            obj.name                                = sprintf('Spectral Power (%d-%dHz)', obj.bin_min, obj.bin_max);

            
        end
        
        function update_buffer(obj, new_data)
            channel_a   = new_data(:,obj.channels(1));
            
            [S, f]      = mtspectrumc(channel_a, obj.params);
%             S           = S/max(S);
            bin_min_idx = find(f > obj.bin_min,1);
            bin_max_idx = find(f > obj.bin_max,1);
            
            obj.SPECTRAL_POWER_BUFFER.append(sum(S(bin_min_idx:bin_max_idx)));
%             obj.SPECTRAL_POWER_BUFFER.append(mean(S(bin_min_idx:bin_max_idx)));
        end
        
        function m = get_metric(obj, duration)
            start_point = obj.SPECTRAL_POWER_BUFFER.lst-duration*obj.sampling_frequency;
            end_point   = obj.SPECTRAL_POWER_BUFFER.lst;
            
            m = obj.SPECTRAL_POWER_BUFFER.raw(start_point:end_point);
            
        end
        
        function update_metric(~)
            
        end
    end
    
end

