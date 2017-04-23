%% Runs the simulation

clc; clear; close all;

numCluster = 3; % three clusters of machine nodes
APPos = [0 0];

clusterCenters = [50 50; 0 -50; -50 50];

xyAP = [0 0]; % coordinates of the access point

nNodes = 10;
radius = 20; % meters

c1 = cluster (nNodes,clusterCenters(1,:), radius);
c2 = cluster (nNodes,clusterCenters(2,:), radius);
c3 = cluster (nNodes,clusterCenters(3,:), radius);

nEpochs = 100;

AP = accessPoint ();

AP.set('location',xyAP, 'numClusters', numCluster);

for i=1:nEpochs
    
    c1.computeChannelLoss(xyAP);
    c2.computeChannelLoss(xyAP);
    c3.computeChannelLoss(xyAP);
    
    % Just report the path loss to the AP/BS
    cqiReport = containers.Map ();
    cqiReport('c1') = c1.channelLoss2AP;
    cqiReport('c2') = c2.channelLoss2AP;
    cqiReport('c3') = c3.channelLoss2AP;
    
    topology = containers.Map ();
    topology('c1') = c1.nodesPos;
    topology('c2') = c2.nodesPos;
    topology('c3') = c3.nodesPos;
    
    AP.set('topology',topology, 'cqiFeedback', cqiReport);
    
    % TBD: Send this to the BS.
    
    % BS has all different experts residing. Job of each expert is to find
    % leader coordinates with confidences using any alogirhtm
    Leaders = AP.selectCoordinators(topology);  % Has 'average' distance measures for all choices of leaders for each cluster
    [dis,leaderIndx]=min(Leaders);
    
    % BS returns the "leader coordinates"
    % Populate the leader co-ordinates in xyLeaders
    % this can also be a map of sorts.
    xyLeaders = [c1.nodesPos(leaderIndx(1),:); c2.nodesPos(leaderIndx(2),:); c3.nodesPos(leaderIndx(3),:)]; % TBD TBD
    
    c1.computeLoss2Coordinator(xyLeaders(1,:));
    c2.computeLoss2Coordinator(xyLeaders(2,:));
    c3.computeLoss2Coordinator(xyLeaders(3,:));
    
    c1.transmit ();
    c2.transmit ();
    c3.transmit ();
end