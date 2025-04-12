function [labels,label0,U,H,conv_lossF,conv_lossM] = HBCD(X, nClus, nAnch, ks, eta,lambda, delta,TNM)
nView = length(X);
nSmp = size(X{1},1);
%% ============================ Initialization ============================
alpha = cell(nView,1);
[FB,label0] = Construct_FB(X, nClus, nAnch, ks, eta);
for iView = 1:nView
    H{iView} = zeros(nSmp,nAnch); 
    Y{iView} = zeros(nSmp,nAnch);
    G{iView} = zeros(nSmp,nAnch);
    S{iView} = zeros(nSmp,nAnch); 
    E{iView} = zeros(nSmp,nAnch); 
end
y = zeros(nSmp*nAnch*nView,1);
j = zeros(nSmp*nAnch*nView,1); 
XSize = [nSmp, nAnch, nView]; 

%% Optimization controling
iter = 0; iterMax = 50; epson = 1e-7; is_conv = 0;
mu = 10e-5; muMax = 10e10; muPho = 2;
rho = 0.0001; rhoMax = 10e12; rhoPho = 2;
conv_lossF=[]; conv_lossM=[];

%% ============================ DFTMVC Optimization =======================
while(is_conv == 0)
%% ============================== Upadate H^k =============================
    Ehat =[];
    for iView =1:nView
        tmp = S{iView} + mu*FB{iView} - mu*E{iView} -Y{iView}+ rho*G{iView}   ;
        H{iView}= tmp/(mu+rho);
        Ehat=[Ehat, FB{iView} - H{iView} + S{iView}/mu];
    end
%% =========================== Upadate E^k, S^k ===========================
    Ehat=Ehat';
    [Ehat_s] = solve_l1l2(Ehat, lambda/mu);
    E{1} =  Ehat_s(1:nAnch,:)';
    S{1} = S{1} + mu*(FB{1}- H{1} -E{1});
    for iView=2:nView
       E{iView} = Ehat_s(nAnch*(iView-1)+1:nAnch*iView,:)';
       S{iView} = S{iView} + mu*(FB{iView} - H{iView}- E{iView});
    end
%% ============================= Upadate G^k ==============================
    H_tensor = cat(3, H{:,:});
    Y_tensor = cat(3, Y{:,:});
    G_tensor = solve_G(H_tensor + 1/rho*Y_tensor, rho, XSize, delta, TNM);
    h = H_tensor(:);
    y = Y_tensor(:);
    g = G_tensor(:);
%% ============================== Upadate Y ===============================
    y = y + rho*(h - g);
    Y_tensor = reshape(y, XSize);
    for iView=1:nView
        Y{iView} = Y_tensor(:,:,iView);
    end
%% ====================== Checking Coverge Condition ======================
    max_lossF=0;
    max_lossM=0;
    is_conv = 1;
    for iView=1:nView
        lossF = norm(FB{iView}-H{iView}-E{iView},inf);
        if (lossF > epson)
            is_conv = 0;
            max_lossF=max(max_lossF,lossF);
        end
        lossM = norm(H{iView}-G{iView},inf);
        if (lossM > epson)
            is_conv = 0;
            max_lossM= max(max_lossM, lossM);
        end
    end
    conv_lossF = [conv_lossF,max_lossF];
    conv_lossM = [conv_lossM,max_lossM];
    if (iter>iterMax)
        is_conv  = 1;
    end
    iter = iter + 1;
    mu = min(mu*muPho, muMax);
    rho = min(rho*rhoPho, rhoMax);
end

Sbar=[];
for iView = 1:nView
    Sbar=cat(1,Sbar,1/sqrt(nView)*H{iView}');
end
[U,~,~] = mySVD(Sbar',nClus); 
seed = 2024;
rng(seed,'twister');
%labels=litekmeans(Sbar', nClus, 'MaxIter', 100,'Replicates',10);
labels=litekmeans(U, nClus, 'MaxIter', 100,'Replicates',10);
end

