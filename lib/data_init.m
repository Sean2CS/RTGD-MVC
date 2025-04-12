function [X, Y] = data_init(X, Y)
    nSmp = length(Y);    
    nClus = length(unique(Y));    
    nView = length(X);
   
    % format
    X_size = size(X);
    if X_size(1)>1
        X = X';
    end
    [row,col] =  size(X{1});
    if(row ~= nSmp)
        for iView = 1:nView
            X{iView} = X{iView}';
        end
    end

    % choose the best initiation 
    seed = 2025;
    rng(seed,'twister');

    for iView = 1:nView
        X{iView} = NormalizeFea(X{iView},0);
    end 
end
