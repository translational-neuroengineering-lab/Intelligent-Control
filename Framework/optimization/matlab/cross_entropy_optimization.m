classdef cross_entropy_optimization < handle
    %CROSS_ENTROPY_OPTIMIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        f_sample
        
        % Stimulation parameters
        f_stimulation_range
        duration_range
        amplitude_range
        width_range
        stim_channel
         
        f_stimulation
        duration
        amplitude
        width
        
        % Timing parameters
        run_start_time_s
        cycle_start_time_s
        this_time_s
        last_time_s
        
        stimulation_time_s
        evaluate_time_s
        
        % Optimization parameters
        samples_per_cycle
        sample_results
        n_samples
        n_elite_samples
        n_parameters
        
        mu
        sigma
        parameter_vector
      
        objective_function
        distribution
        
        % Logging parameters
        stimulation_fid
        objective_fid   
        parameter_fid
    end
    
    methods
        function obj = cross_entropy_optimization(TD_FS, objective_function, logging_directory)
            obj.f_sample                = TD_FS;
            
            obj.run_start_time_s        = posixtime(datetime);
            obj.cycle_start_time_s      = posixtime(datetime);
            obj.last_time_s             = posixtime(datetime);
            obj.this_time_s             = posixtime(datetime);
            
            obj.stimulation_time_s      = 0.5;
            obj.evaluate_time_s         = 2.5;
            
            obj.samples_per_cycle       = 100;
            obj.sample_results          = nan(1,obj.samples_per_cycle);
            obj.n_samples               = 0;
            obj.n_elite_samples         = 1;
            
            obj.n_parameters            = 1;
            obj.mu                      = [5];
            obj.sigma                   = ones(1,obj.n_parameters)*150;
            
            obj.parameter_vector        = nan(obj.samples_per_cycle, obj.n_parameters);
            
            obj.objective_function      = objective_function;
            obj.distribution            = 'uniform';
            obj.duration                = 1;
            obj.amplitude               = 4;
            obj.width                   = 0.01;
            obj.stim_channel            = 5;
                        
            obj.stimulation_fid         = fopen(sprintf('%s/stimulation_channel_%d.csv',...
                                            logging_directory, obj.stim_channel), 'a');
            obj.objective_fid           = fopen(sprintf('%s/objective_function.csv',...
                                            logging_directory),'a');
            obj.parameter_fid           = fopen(sprintf('%s/parameter.csv',...
                                            logging_directory),'a');
        end
        
        function optimize(obj, TD)
            obj.last_time_s = obj.this_time_s;
            obj.this_time_s = posixtime(datetime);
            
            this_time       = obj.this_time_s - obj.cycle_start_time_s;
            global_time_s   = obj.this_time_s - obj.run_start_time_s;
            last_time       = obj.last_time_s - obj.cycle_start_time_s;
                    
            if this_time > obj.stimulation_time_s && last_time < obj.stimulation_time_s
                               
                signals = get_stimulation(obj);
                
                write_signal(TD, obj.stim_channel(1), signals(1,:));
                
                fprintf(obj.stimulation_fid,'%f, %f\n', ...
                    posixtime(datetime('now')), obj.parameter_vector(obj.n_samples) );

                stimulate(TD);
                
            elseif this_time > obj.evaluate_time_s && last_time < obj.evaluate_time_s     
                
                m = obj.objective_function.get_metric(7);
                    
                obj.sample_results(obj.n_samples,1) = mean(m(2:5));
                
                fprintf(obj.objective_fid,'%f, %f\n', ...
                    posixtime(datetime('now')), obj.sample_results(obj.n_samples,1) );
                
                fprintf('Objective: %f\n', obj.sample_results(obj.n_samples,1));
                reset_time(obj)
                
                if obj.n_samples >= obj.samples_per_cycle
                    update_parameters(obj)
                end
            else
                    
            end  
                   
        end
        
        function signal = get_stimulation(obj)
            obj.n_samples = obj.n_samples + 1;
            
            for c1 = 1:obj.n_parameters
                
                if strcmp(obj.distribution, 'gaussian')
                    
                    obj.parameter_vector(obj.n_samples,c1) = normrnd(obj.mu(c1),obj.sigma(c1), 1);
               
                elseif strcmp(obj.distribution, 'uniform')
                    
                    obj.parameter_vector(obj.n_samples,c1) = obj.mu + (obj.sigma - obj.mu)*rand();
                
                end
                
                signal(c1,:) = generate_biphasic(obj.f_sample,obj.parameter_vector(obj.n_samples,c1),obj.duration,obj.amplitude,obj.width);
            end

        end
        
        % Resets the clock to start another stimulation trial
        function reset_time(obj)
            obj.cycle_start_time_s   = posixtime(datetime);
            obj.last_time_s          = posixtime(datetime);
            obj.this_time_s          = posixtime(datetime);
        end
        
        % Identifies the elite samples to update the sampling distribution
        function update_parameters(obj)
            [~, sorted_idx] = sort(obj.sample_results,'descend');

            old_mu          = obj.mu;
            old_sigma       = obj.sigma;

            obj.mu          = mean(obj.parameter_vector(sorted_idx(1:obj.n_elite_samples),:),1);
            obj.sigma       = std(obj.parameter_vector(sorted_idx(1:obj.n_elite_samples),:),1); 

            obj.n_samples   = 0;
            
            fprintf('\tmu_1 %.3f -> %.3f\n', old_mu(1), obj.mu(1)) 
            fprintf('\tsigma_1 %.3f -> %.3f\n', old_sigma(1), obj.sigma(1))
            
            fprintf(obj.parameter_fid,'%f, %f, %f\n', ...
                posixtime(datetime('now')), obj.mu, obj.sigma);
            
        end
        
        
        function log_data(obj)
            
            fprintf(obj.fid, '\nmu=%f, sigma=%f, N=%d, N_e=%d\n', ...
                obj.mu, obj.sigma, obj.samples_per_cycle, obj.n_elite_samples);
            
            for c1 = 1:size(obj.parameter_vector,1)
                fprintf(obj.fid, '%f, %f\n', ...
                    obj.parameter_vector(c1), obj.sample_results(c1));
            end
            
        end
    end
    
end

