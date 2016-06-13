% This function estimate shift using dft registration algorithm, the output
% contain the info of horizontal and vertical translation.
% ----- dataset : low resolution sequence except the first image(moving image)
% ----- ref : the reference image ( the first image at sequence) 
function s_set = estimate_shift(dataset,ref)
    s_set = size(dataset,3);
    g = ref;
    for i = 1:size(dataset,3)
        f = squeeze(dataset(:,:,i));
        [output,~] = dftregistration(fft2(f),fft2(g),100);
        s = output(4);
        s_set(i) = s;
    end
end