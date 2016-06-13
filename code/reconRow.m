% do reconstruction on a single row
% ----- a0: high resolution image
% ----- downset: low resolution sequence
% ----- k : downsample factor
% ----- s_set: movement set
% return ---- a0: updated(reconstruted result)
% -----r : residue
function [a0,r] = reconRow(a0,downset,k,s_set)
    %% functional form
    % a sequence of low resolution image with small movement
    y = downset';
    y = y(:);
    iter =1000;
    for i = 1 : iter
        diffset = [];
        gset = zeros(size(a0));
        gamma = [];
        for j = 1 : size(s_set,2)
            [y_temp,~] = matrix_mult(a0,s_set(j),k);
            y_m = downset(j,:);
            diff_temp = y_temp - y_m;
            diffset = [diffset;diff_temp];
            g_temp = matrix_T_mult(diff_temp,k,s_set(j));
            %gset = [gset;sum(g_temp)];
            gset = gset + g_temp;
        end
        gset = gset*k; % g is ready
        for p = 1 : size(s_set,2)
            [gamma_temp,~] = matrix_mult(gset,s_set(p),k);
            gamma = [gamma;gamma_temp]; % gamma is ready
        end
        diffset = diffset';
        diffset = diffset(:);
        gamma = gamma';
        gamma = gamma(:);
        epsilon = (gamma'*diffset)/(gamma'*gamma);
        r = norm(epsilon*gset,2)/norm(a0,2);
        a0 = a0 - epsilon * gset;
        if r < 10^(-12)
            break
        end
    end
end