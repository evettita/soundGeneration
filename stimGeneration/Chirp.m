classdef Chirp < AuditoryStimulus
    % Basic subclass for courtship song
    %
    % AVB 2015
    
    properties
        startFrequency  = 90;
        endFrequency    = 1500;
        chirpLength     = 10;
        mode            = 'speaker';
    end
    
    properties (Dependent = true, SetAccess = private)
        stimulus
        description
    end
    
    methods
        %%------Constructor-----------------------------------------------------------------
        function stimulus = get.stimulus(obj)
            stimTime = (1/obj.sampleRate):(1/obj.sampleRate):obj.chirpLength;
            stimulus = chirp(stimTime,obj.startFrequency,stimTime(end),obj.endFrequency)';
%             spectrogram(y,256,250,256,1E5,'yaxis')
            
            % Calculate envelope
            sampsPerChirp = length(stimulus);
            sampsPerRamp = floor(sampsPerChirp/10);
            ramp = sin(linspace(0,pi/2,sampsPerRamp));
            modEnvelope = [ramp,ones(1,sampsPerChirp - sampsPerRamp*2),fliplr(ramp)]';

            % apply the envelope to pip
            stimulus = modEnvelope.*stimulus;
            
            % Calculate ramp down 
            if strcmp(obj.mode,'speaker')
                if obj.startFrequency < obj.endFrequency
                    rampdown = linspace(1,0.25,sampsPerChirp)';
                else 
                    rampdown = linspace(0.25,1,sampsPerChirp)';
                end
            stimulus = rampdown.*stimulus; 
            end
            
            % Scale the stim to the maximum voltage in the amp
            stimulus = stimulus*obj.maxVoltage;
            
            % Add pause at the beginning of of the stim
            stimulus = obj.addPad(stimulus);
        end
        
        function description = get.description(obj)
            if obj.startFrequency < obj.endFrequency
                chirpType = 'Ascending';
            else 
                chirpType = 'Descending';
            end
            description = [chirpType,' chirp, ',num2str(obj.startFrequency),'Hz to ',num2str(obj.endFrequency),'Hz'];
        end
                
        %%------Plot Spectogram--------------------------------------------------------------------
        function spectPlot(obj,varargin)
            spectrogram(obj.stimulus,128,64,0:10:1500,obj.sampleRate,'yaxis');
            box off; axis on;
            set(gca,'TickDir','Out')
            title('Current Auditory Stimulus','FontSize',obj.defaultFontSize)
            ylabel('Frequency (Hz)','FontSize',obj.defaultFontSize)
            xlabel('Time (seconds)','FontSize',obj.defaultFontSize)
        end
        
        
    end
    
end