classdef cluster < hgsetget
    %CLUSTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %clusterId;
        numNodes;
        nodesPos;
        nodeEnergyUsage;
        channelLoss2Coord;
        channelLoss2AP;
        
        clusterCenter; % cluster center; default at origin
        clusterRadius; % cluster radius; default 10
        
        fc = 2.4*1e9; % operating frequency 2 GHz
        bw = 10*1e6; % 10 MHz of total BW
        Ptx = 1e-3; % 10 mW of TX power
        nBitsTx = 800; % each node sends 100 bytes of data : fixed for now.
        
    end
    
    methods
        function obj = cluster ( num, cntr, radius)
            
            %obj.clusterId = cId;
            
            obj.numNodes = num;
            obj.clusterCenter = cntr;
            obj.clusterRadius = radius;
            
            p1 = [rand(obj.numNodes,1) rand(obj.numNodes,1)];
            obj.nodesPos = p1*obj.clusterRadius + repmat(cntr, obj.numNodes,1);
            
            obj.nodeEnergyUsage = zeros(obj.numNodes,1);
        end
        
        % computes the channel loss to the specified accessPoint
        % works as a CQI feed back
        function computeChannelLoss (obj,apCoord)
            
            pmf = [0.25 0.55 0.2]; % LOS, NLOS and Blocking probability
            loss = [0 -10 -100]; % loss in dB due to channel state
            
            pdist = [0, cumsum(pmf)];
            u = rand(obj.numNodes,1);
            [~,indx] = histc(u,pdist);
            chLoss = loss(indx); % in dB
            
            dist = sum((obj.nodesPos - repmat(apCoord, obj.numNodes,1)).^2,2);            
            
            lam = (3*1e8)/obj.fc;
            PL = 20.*log10((lam./(4*pi*dist)));
            
            obj.channelLoss2AP = PL + chLoss';
        end
        
        function computeLoss2Coordinator (obj, LeaderCoord)
            pmf = [0.4059 0.594 0.0001]; % very less blocking probabilty
            
            loss = [0 -10 -100]; % loss in dB due to channel state
            
            pdist = [0, cumsum(pmf)];
            u = rand(obj.numNodes,1);
            [~,indx] = histc(u,pdist);
            chLoss = loss(indx); % in dB
            
            dist = sum((obj.nodesPos - repmat(LeaderCoord, obj.numNodes,1)).^2,2);
            
            lam = (3*1e8)/obj.fc;
            PL = 20.*log10((lam./(4*pi*dist)));
            
            PL(dist == 0) = 0;
            
            
            obj.channelLoss2Coord = PL + (dist ~= 0).*(chLoss');
        end
        
        % secondary nodes TX to coordinator. Coordinator Tx to AP/BS
        function transmit (obj)
            bwPerNode = obj.bw/(obj.numNodes - 1);
            SNR = 10*log10(obj.Ptx) - obj.channelLoss2Coord;
            SNR2AP = 10*log10(obj.Ptx) - obj.channelLoss2AP;
            
            rate = (obj.channelLoss2Coord ~=0).*(bwPerNode.*log2(1+10.^(0.1*SNR))) + ...
                (obj.channelLoss2Coord == 0).*(obj.bw*log2(1+ SNR2AP));
            
            numBits = (obj.channelLoss2Coord ~=0).*(obj.nBitsTx*ones(obj.numNodes,1)) + ...
                (obj.channelLoss2Coord == 0).*(obj.numNodes*obj.nBitsTx*ones(obj.numNodes,1));
                    
            
            txTime = numBits ./ rate;
            
            obj.nodeEnergyUsage = obj.nodeEnergyUsage + obj.Ptx.*txTime;
        end
    end
    
end

