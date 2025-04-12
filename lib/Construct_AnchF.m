function [AnchorF, B] = Construct_AnchF(X,nClus,nAnch,ks,eta)
N = size(X{1},1);
M = nAnch;
nView = length(X);
Anchor = cell(nView,1);
AnchorF = cell(nView,1);
B = cell(nView,1);
Xs = X{1};
for iView = 2:nView
    Xs = [Xs,X{iView}];
end

Xs
for iView = 1:nView
    [~, Anchor{iView}] = litekmeans(X{iView}, nAnch, 'MaxIter', 10, 'Replicates', 10);
    B{iView} = ConstructBP_pkn(X{iView}, Anchor{iView}, ks);
    D = sum(B{iView},1);
    BDN = diag(1./sqrt(D+eps));
    % D = sum(B{iView},2);
    % BDN = diag(1./sqrt(D+eps))*B{iView};
    BL = eye(M) - 1/2.^BDN'*BDN;
    BL = (BL+BL')/2;
    AnchorF{iView} = expm(-eta*BL);
end



