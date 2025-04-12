%the main experiment of RTGD

clear;
clc;
data_path = fullfile(pwd, '..',  filesep, "data", filesep);
addpath(data_path);
lib_path = fullfile(pwd, '..',  filesep, "lib", filesep);
addpath(lib_path);
code_path = genpath(fullfile(pwd, '..', filesep, 'RTGD-MVC'));
addpath(code_path);

dirop = dir(fullfile(data_path, '*.mat'));
datasetCandi = {dirop.name};

exp_n = 'result_RTGD-MVC';%

% dataset loop
for i1 = 1:length(datasetCandi)
    data_name = datasetCandi{i1}(1:end-4);
    dir_name = [pwd, filesep, exp_n, filesep, data_name, filesep];
    create_dir(dir_name);
    fname2 = fullfile(data_path, [data_name, '.mat']);
    load(fname2);

    nClus = length(unique(Y));
    nSmp = length(Y);
    nView = length(X);
    nMeasure = 7;
    nRepeat = 1;
   
    seed = 2024;
    rng(seed,'twister');

    for iView = 1:nView
        X{iView} = NormalizeFea(X{iView},1);
    end 
    
    %hyper-parament setting 
    lambda_s = 10.^(-6:1:0); 
    delta_s = 10.^(-6:1:0);
    nAnch_s = nClus.*(2:1:8);
    ks_s = [10];
    eta_s = [1];
    Anchor = cell(nView);
    
    paramCell = cell(1, length(lambda_s) * length(delta_s) * length(nAnch_s)* length(ks_s) * length(eta_s));
    idx = 0;
    grid_ans = zeros(length(lambda_s),length(delta_s),length(nAnch_s),length(ks_s),length(eta_s),nMeasure+1,nRepeat);    
     for iParam1 = 1:length(eta_s)
        for iParam2 = 1:length(ks_s)
            for iParam3 = 1:length(nAnch_s)
                for iParam4 = 1:length(delta_s)
                    for iParam5 = 1:length(lambda_s)
                        idx = idx + 1;
                        param = [];
                        param.lambda = lambda_s(iParam5);
                        param.delta = delta_s(iParam4);
                        param.nAnch = nAnch_s(iParam3);
                        param.ks = min(ks_s(iParam2),param.nAnch-1);
                        param.eta = eta_s(iParam1);
                        param.iParam = [iParam1,iParam2,iParam3,iParam4,iParam5];
                        paramCell{idx} = param;
                    end
                end
            end
        end
    end
    paramCell = paramCell(~cellfun(@isempty, paramCell));
    nParam = length(paramCell);

    seed = 2024;
    rng(seed,'twister');
    random_seeds = randi([0, 1000000], 1, nRepeat);
    original_rng_state = rng;
    %*********************************************************************
    % RTGD
    %*********************************************************************
    fname2 = fullfile(dir_name, [data_name, '_RTGD.mat']);
    if ~exist(fname2, 'file')
        acc_max = 0; iParam_max = 0;
        RTGD_global_result = zeros(nParam, 1, nRepeat, nMeasure);
        RTGD_global_time = zeros(nParam, 1);
        for iParam = 1:nParam
            fprintf("iParam = %d/%d\n",iParam,nParam);
            param = paramCell{iParam};
            lambda = param.lambda;
            delta = param.delta;
            nAnch = param.nAnch;
            ks = param.ks;
            eta = param.eta;
            t1_s = tic;
            fname_tmp = fullfile(dir_name, [data_name, '_RTGD_param', num2str(iParam),'.mat']);
            if exist(fname_tmp,'file')
                load(fname_tmp);
                fprintf("iParam = %d/%d has been updated\n",iParam,nParam);
                grid_ans(param.iParam(1),param.iParam(2),param.iParam(3),param.iParam(4),param.iParam(5),:,:) = temp_grid_ans; 
            else
                t_sum = 0;
                for iRepeat = 1:nRepeat
                    rng(random_seeds(iRepeat),'twister');
                    t_s = tic; 
                    TNM = 'CTR';
                    [y,U,Z,converge_Z,converge_Z_G] = RTGD(X, nClus, nAnch, ks, eta, lambda, delta, TNM);
                    result_aio = ComputeECVIs(Y,y);
                    t = toc(t_s);
                    grid_ans(param.iParam(1),param.iParam(2),param.iParam(3),param.iParam(4),param.iParam(5),:,iRepeat) = [result_aio',t];
                    RTGD_global_result(iParam, 1, iRepeat, :) = result_aio';
                    t_sum = t_sum + t;
                end
                RTGD_global_time(iParam) = t_sum/nRepeat;
                temp_grid_ans = grid_ans(param.iParam(1),param.iParam(2),param.iParam(3),param.iParam(4),param.iParam(5),:,:);
                save(fname_tmp,'temp_grid_ans');
                fprintf("iParam = %d/%d has been saved\n",iParam,nParam);
            end
            acc = mean(grid_ans(param.iParam(1),param.iParam(2),param.iParam(3),param.iParam(4),param.iParam(5),1,:));
            if(acc > acc_max)
                acc_max = acc;
                iParam_max = iParam;
            end
            fprintf("%s:iParam = %d/%d-%d, acc= %.2f/%.2f\n",data_name,iParam,nParam,iParam_max,acc,acc_max);   
        end
        a1 = sum(RTGD_global_result, 2);
        a3 = sum(a1, 3);
        a4 = reshape(a3, nParam, nMeasure);
        a4 = a4/nRepeat;
        RTGD_global_result_summary = [max(a4, [], 1), sum(RTGD_global_time)];
        save(fname2, 'RTGD_global_result', 'RTGD_global_time', 'RTGD_global_result_summary', 'iParam_max');
        disp([data_name, ' has been completed!']);
        clear X,Y;
    end
end
rmpath(data_path);
rmpath(lib_path);
rmpath(code_path);