function [G,objV] = solve_G(X,mu,XSize,delta,TNM)
% min 1/mu ||G||_gamma+1/2||G-(Z+W/MIU)||_F^2

er_eps = 10e-4;
G_hat=reshape(X,XSize);
objV = 0;
G_hat_re = shiftdim(G_hat, 1);
G_hat_fft = fft(G_hat_re,[],3);
max_iter = 100;
dim = size(G_hat_fft,3);
n3 = dim;

endIndex = int32(n3/2)+1;
for i = 1:endIndex
    [uhat,shat,vhat] = svd(full(G_hat_fft(:,:,i)),'econ');
    sigma = diag(shat);
    sigma_pre = sigma;
    for j = 1: max_iter
        nabla = nabla_Prox(sigma_pre,delta,TNM);
        sigma_now = max(0,sigma - nabla/mu);
        if sum((sigma_now-sigma_pre).^2) < er_eps
            break;
        end
        sigma_pre = sigma_now;
    end
    shat = diag(sigma_now);
    objV = objV + sum(shat(:));
    G_hat_ff(:,:,i) = uhat*shat*vhat';
    if i > 1 && i < endIndex +int32(n3/2)
        G_hat_ff(:,:,n3-i+2) = conj(uhat)*shat*conj(vhat)';
        objV = objV + sum(shat(:));
    end
end

G = ifft(G_hat_ff,[],3);
G = shiftdim(G, 2);
end
