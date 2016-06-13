%% function form of matrix multiplication
% ----- a : high resolution image 
% ----- delta: movement 
% ----- k : inverse of upsample factor (if upsample factor = 3 , k = 1/3)

function [downsample,coeff,result_conv] = matrix_mult(a,delta,k)
    part = mod(abs(delta),k)/k;
    shift = fix(delta/k);
    coeff = ones(1,(1/k)+1);
    
    % build coefficient matrix 
    if(delta >= 0)
        coeff(1) = 1 - part;
        coeff(end) = part;
    else 
        coeff(1) = part;
        coeff(end) = 1 - part;
    end
    delta;
    coeff;
    result_conv = conv(a,coeff);
    if delta >= 0
        x = 1/k - fix(mod(delta,1)/k);
        y = size(a,2)-shift;
    else
        x = 1/k - fix(mod(delta,1)/k)+1;
        y = size(result_conv,2)-(1/k)+shift+1;
    end
    
    while x < 0
        x = x +1/k;
    end
    while y > size(result_conv,2)
        y = y - 1/k;
    end
    downsample = result_conv(:,uint8(x):1/k:uint8(y));
    
    % padding for keep right size 
    if delta >= 1
        downsample = padarray(downsample,[0 abs(fix(delta))],'symmetric','pre');
    else 
        downsample = padarray(downsample,[0 abs(fix(delta))],'symmetric','post');
    end
    
    %downset(w,:) = downsample;
end