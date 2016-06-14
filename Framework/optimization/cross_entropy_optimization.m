classdef cross_entropy_optimization < handle
    %CROSS_ENTROPY_OPTIMIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TD
        device_name
        sampling_frequency
        logging_directory
        
        % Stimulation parameters
        stimulation_type
        f_stimulation_range
        duration_range
        amplitude_range
        width_range
        stim_channels
         
        stimulation_frequency
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
        evaluate_delay_s
        
        % Optimization parameters
        samples_per_cycle
        sample_results
        n_samples
        n_elite_samples
        n_parameters
        
        mu
        sigma
        lower_bound
        upper_bound
        parameter_vector
        stimulation_parameter
      
        objective_function
        objective_window_s
        pre_stimulation_metric
        
        % optimization_direction
        %   'maximize'  searches for maximum of objective function
        %   'minimize'  searches for minimum of objective function                        
        optimization_direction
        
        % objective_type values: 
        %   'raw'   evaluates post-stimulation metric
        %   'delta' evaluates the change in the metric from pre- to
        %   post-stimualtion
        objective_type          
        
        % distribution values:
        %   'gaussian'  Normal distribution parameterized by a mean (mu)
        %   and standard deviation (sigma). Can be restricted to a lower
        %   bound and upper bound
        %   'uniform'   Uniform distribution with upper and lower bounds 
        distribution
        
        % Logging parameters
        stimulation_fid
        objective_fid   
        parameter_fid
        
        optimization_done
        stimulator
    end
    
    methods
      
        %%%%%%%%%%%%%%%
        %
        %%%%%%%%%%%%%%%
        function initialize(obj)
            obj.run_start_time_s        = posixtime(datetime);
            obj.cycle_start_time_s      = posixtime(datetime);
            obj.last_time_s             = posixtime(datetime);
            obj.this_time_s             = posixtime(datetime); 
            obj.sample_results          = nan(obj.samples_per_cycle,1);
            obj.n_samples               = 0;

            obj.optimization_done       = 0;

            obj.parameter_vector        = nan(obj.samples_per_cycle, obj.n_parameters);
            
            obj.objective_fid           = fopen(sprintf('%s/objective_function.csv',...
                                            obj.logging_directory),'a');
            obj.parameter_fid           = fopen(sprintf('%s/parameter.csv',...
                                            obj.logging_directory),'a');
        end
        
        %%%%%%%%%%%%%%%
        %
        %%%%%%%%%%%%%%%
        function optimize(obj)
            
            obj.stimulator.check_stimulation()
            this_time  = obj.get_current_time();
             
            if this_time > obj.stimulation_time_s && obj.stimulator.stimulation_armed
                obj.pre_stimulation_metric = obj.objective_function.get_metric(0);            
                obj.select_next_sample()
                obj.stimulator.generate_stimulation_signal();
                obj.stimulator.write_stimulation_signals();
                obj.stimulator.stimulate()              
                
            elseif this_time  > obj.evaluate_delay_s + obj.stimulator.stimulation_duration + obj.stimulator.stimulation_time
                obj.evaluate_objective_function(); 
                
                if obj.n_samples >= obj.samples_per_cycle
                    obj.update_parameters();
                end
                
                obj.reset_time();
                obj.stimulator.stimulation_armed = 1;
            end  
                   
        end
        
        %%%%%%%%%%%%%%%
        % Evaluate objective function - this needs to be split into it's
        % own object 
        %%%%%%%%%%%%%%%
        function evaluate_objective_function(obj)
            
            m = obj.objective_function.get_metric(1);
            
            switch(obj.objective_type) 
                case 'raw' 
                    obj.sample_results(obj.n_samples,1) = m;
                case 'delta'          
                    obj.sample_results(obj.n_samples,1) = m-obj.pre_stimulation_metric;
            end
                         
            fprintf(obj.objective_fid,'%f, %f\n', ...
                posixtime(datetime('now')), obj.sample_results(obj.n_samples,1));         
            fprintf('Objective: %f\n', obj.sample_results(obj.n_samples,1));
        end
        
        
        %%%%%%%%%%%%%%%
        % Only set up for single parameter search
        %%%%%%%%%%%%%%%
        function  select_next_sample(obj)
            obj.n_samples = obj.n_samples + 1;
                    
            % Determine stimulation distribution
            switch obj.distribution
                
                case 'gaussian'
                    
                    % Select parameter from constrained Gaussian
                    params = normrnd(obj.mu,obj.sigma, 1);
                    while params < obj.lower_bound || params > obj.upper_bound
                        params = normrnd(obj.mu,obj.sigma, 1);
                    end

                    % Save to object
                    obj.parameter_vector(obj.n_samples) = params;

                case 'uniform'
                    
                    % Select parameter from a uniform distribution
                    obj.parameter_vector(obj.n_samples) = obj.lower_bound + (obj.upper_bound - obj.lower_bound)*rand();
                
            end
            
            fprintf('Sample: %d Stimulation %s = %f, ',obj.n_samples, obj.stimulation_parameter, obj.parameter_vector(obj.n_samples));
            
            % Update the stimulation parameter
            if strcmp(obj.stimulation_parameter, 'frequency')
                obj.stimulator.stimulation_frequency = obj.parameter_vector(obj.n_samples);
            elseif strcmp(obj.stimulation_parameter, 'duration')
                obj.stimulator.stimulation_duration = obj.parameter_vector(obj.n_samples);
            end

        end
        
        %%%%%%%%%%%%%%%
        % Resets the clock to start another stimulation trial
        %%%%%%%%%%%%%%%
        function reset_time(obj)
            obj.cycle_start_time_s   = obj.get_current_time();
            obj.last_time_s          = obj.get_current_time();
            obj.this_time_s          = obj.get_current_time();
        end
        
        %%%%%%%%%%%%%%%
        % Identifies the elite samples to update the sampling distribution
        %%%%%%%%%%%%%%%
        function update_parameters(obj)
            
            switch obj.optimization_direction
                case 'maximize'
                     [~, sorted_idx] = sort(obj.sample_results,'descend');
                case 'minimize'
                     [~, sorted_idx] = sort(obj.sample_results,'ascend');
            end
            
            old_mu          = obj.mu;
            old_sigma       = obj.sigma;

            obj.mu          = mean(obj.parameter_vector(sorted_idx(1:obj.n_elite_samples),:),1);
            obj.sigma       = std(obj.parameter_vector(sorted_idx(1:obj.n_elite_samples),:),1); 

            obj.n_samples   = 0;
            
            fprintf('\tOjective: \n\t\tmean = %.3e \n\t\tstd = %.3e\n', mean(obj.sample_results), std(obj.sample_results));
            fprintf('\tmu_1 %.3e -> %.3e\n', old_mu(1), obj.mu(1)) 
            fprintf('\tsigma_1 %.3e -> %.3e\n', old_sigma(1), obj.sigma(1))
            
            fprintf(obj.parameter_fid,'%f, %f, %f\n', ...
                posixtime(datetime('now')), obj.mu, obj.sigma);
            
        end   
        
        %%%%%%%%%%%%%%%
        % Identifies the elite samples to update the sampling distribution
        %%%%%%%%%%%%%%%
        function t = get_current_time(obj)
            t = obj.TD.ReadTargetVEX([obj.device_name '.current_time'], 0, 1, 'I32', 'F64')/obj.sampling_frequency;
        end
    end    
end

