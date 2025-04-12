function y = nabla_Prox(x,delta,TNM)
if(TNM == 'ETR')
    y  = delta*exp(delta^2)./((x+delta).^2+eps); %ETR
elseif(TNM == 'CTR')
    y = x./delta.*exp(-x./delta); %Exp
else
    y = 1;
end
