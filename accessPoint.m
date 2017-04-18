classdef accessPoint < hgsetget
    %ACCESSPOINT: Defines the accesspoint or the base station
    % Needs to select the co-ordinators based on expert advice
    
    properties
        location;
        numClusters;
        topology; % stores the network topology = coordinates of every node
        %  declare this as a Map with the key as the cluster index c1, c2,
        %  c3 etc.
        
        cqiFeedback; % channel quality feedback; again a Map set from the main simulation
        
    end
    
    methods
        
        function xyLeaders = selectCoordinators ()
            % Uses expert prediction to select coordinators
        end
    end
    
end

