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
        
        % Expert setting
        numExperts; % Number of experts
        expertWt;   % Weights on each expert
        
    end
    
    methods
        
        function xyLeaders = selectCoordinators(xyLeaders,topology)
            nNodes = 10;
            conf=zeros(1,nNodes);% Uses expert prediction to select coordinators
            % for each expert
                % for each cluster
                clN = 1;
                for cl = [{'c1'},{'c2'},{'c3'}]
                    top = topology(cell2mat(cl));
                    % for each node if chosen as leader
                    for leadInd = 1:nNodes
                        dis = sum(((ones(nNodes,1)*top(leadInd,:)-top).^2),2);  %Euclidean Distance.
                        qMeasure = mean(dis);   % a measure of average distance to leader
                        conf(:,leadInd,clN) = qMeasure;%(prob)./sum(prob);   % probabilities
                    end
                    clN = clN+1;
                end
                xyLeaders = conf;
        end
    end
    
end

