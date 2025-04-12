function [FB,lable0] = Construct_FB(X,nClus,nAnch,ks,eta)
%% Setting
nSmp = size(X{1},1);
nView = length(X);
B = cell(nView,1);
AnchorF = cell(nView,2);

seed = 2024;
rng(seed,'twister');

%shuffle
Xs = X{1};
for iView = 2:nView
    Xs = [Xs,X{iView}];
end

[lable0, ~] = litekmeans(Xs, nClus, 'MaxIter', 100, 'Replicates', 10);
[~, index] = sort(lable0);
% for iView = 1:nView
%     X{iView} = X{iView}(index,:);
% end

%% Construct Bipartite Graph B^{v} and Graph Filter AnchorF^{nView,2}
Xs = X{1};
dl = zeros(nView);
dl(1) = size(X{1},2);
for iView = 2:nView
    dl(iView) = size(X{iView},2);
    Xs = [Xs,X{iView}];
end
[~, Anchors] = litekmeans(Xs, nAnch, 'MaxIter', 100, 'Replicates', 10);


index_s = 1;
for iView = 1:nView
    B{iView} = ConstructBP_pkn(X{iView}, Anchors(:,index_s:index_s+dl(iView)-1), ks);
    index_s = index_s + dl(iView);
end
% shuffle
% Bs = B{1};
% for iView = 2:nView
%     Bs = [Bs,B{iView}];
% end
% [lable0, ~] = litekmeans(Bs, nClus, 'MaxIter', 100, 'Replicates', 10);
% [~, index] = sort(lable0);
% for iView = 1:nView
%     B{iView} = B{iView}(index,:);
% end
% Y = Y(index);




for iView = 1:nView
    P = B{iView} * diag(max(sum(B{iView}, 1),1e-8).^(-.5));
    PTP = eye(nAnch) - P'*P;
    PTP = (PTP+PTP')/2;
    PTP_inv = pinv(PTP);
    temp = PTP_inv - expm(-eta*PTP)*PTP_inv;
    AnchorF{iView,1} = P*temp;
    AnchorF{iView,2} = P';
end

%% Cross-view Graph Diffusion 
for iView = 1:nView
    FB{iView} = zeros(size(B{iView}));
    for iView1 = 1:nView
        if(iView1~=iView)
            temp = AnchorF{iView1,2} * B{iView};
            temp = AnchorF{iView1,1} * temp;
            FB{iView} = FB{iView} + B{iView} - temp;
        end
    end
    FB{iView} = FB{iView}/(nView-1);
end







