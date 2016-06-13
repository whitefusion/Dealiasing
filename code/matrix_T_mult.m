% the function that performs transpose matrix multiplication given downsample factor 
% and movement
% ----- downsample: low resolution image
% ----- k : downsample factor
% ----- delta: movement
function temp_upsamp = matrix_T_mult(downsample,k,delta)
    part = mod(abs(delta),k)/k;
    coeff = ones(1,(1/k)+1);
    shift = fix(delta/k);
    if(delta <= 0)
        coeff(1) = 1 - part;
        coeff(end) = part;
    else 
        coeff(1) = part;
        coeff(end) = 1 - part;
    end

    dsamp_supp = downsample;  
    
    shift = abs(shift);
    
    if delta >= 0
        x = 1/k;
    else
        x =1;
    end
    upsample = repmat(dsamp_supp,[1/k,1]);
    upsample = upsample(:);
    y = size(upsample,1);
    if delta > 0
        for i = x:1/k:y
            if i ~= y
                upsample(i) = coeff(1)*upsample(i+1)+coeff(end)*upsample(i);
            elseif i==y
                if coeff(end) ~= 0
                    upsample(i) = coeff(end)*upsample(i);
                end
            end
        end
    end
    
    if delta < 0
        for i = x:1/k:y
            if i ~= y
                upsample(i) = coeff(1)*upsample(i) + coeff(end)*upsample(i+1);
            elseif i == y
                if coeff(1) ~= 0
                    upsample(i) = coeff(1)*upsample(i);
                end
            end 
        end
    end
    
    % pad to keep size 
    if delta > 0
        temp_upsamp = padarray(upsample,[shift 0],'post');
        temp_upsamp = temp_upsamp(1+shift:end);
    else
        temp_upsamp = padarray(upsample,[shift 0],'pre');
        temp_upsamp = temp_upsamp(1:size(upsample,1));
%         temp_upsamp(1:end-shift) = upsample(1:end-shift);
    end
    %pause;
    %figure(hFig3);
    %imagesc(upsample');colormap gray;axis image;
    temp_upsamp = k*temp_upsamp';
end