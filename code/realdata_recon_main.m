clear 
close all
clc 

%% import image
proj = readImg('linepair_proj.img');
gain = readImg('linepair_gain_proj.img');
proj_off = readImg('linepair_offset_proj.img');
gain_off = readImg('linepair_offset_gain_proj.img');

%% Average 
proj_avg = zeros([size(proj,1),size(proj,2),20]);
for i = 1 : size(proj_avg,3)
    proj_avg(:,:,i) = mean(proj(:,:,((i-1)*10 + 1):i*10),3);
end

gain_avg = mean(gain,3);
proj_off_avg = mean(proj_off,3);
gain_off_avg = mean(gain_off,3);

%% get the line pair view and crop it
line_pair = zeros(1000,500,size(proj_avg,3));
for i = 1 : 20
    temp = (proj_avg(:,:,i) - proj_off_avg) ./ (gain_avg - gain_off_avg);
    %imagesc
    line_pair(:,:,i) = temp;
end

figure; im(line_pair);colormap gray
s_set = estimate_shift(line_pair(:,:,2:end),squeeze(line_pair(:,:,1)));

%% get the line pair view and crop it
line_pair_crop = zeros(145,46,size(proj_avg,3));
for i = 1 : 20
    temp = (proj_avg(:,:,i) - proj_off_avg) ./ (gain_avg - gain_off_avg);
    imagesc
    line_pair_crop(:,:,i) = imcrop(temp,[323.5 84.5 45 144]);
end
rows = size(line_pair_crop,1);
cols = size(line_pair_crop,2);
slices = size(line_pair_crop,3);

figure; im(line_pair_crop);colormap gray

%% MAP method, want to reconstruct a high-resolution image.
period =2; %only supersample the pixel at column direction

line_data = line_pair_crop;
y = reshape(line_data,[size(line_data,1)*size(line_data,2),size(line_data,3)]);

% initialize z0 by interpolating the first low-resolution image, only
% interpolate long horizontal direction

x1 = line_data(:,:,1);
x1 = padarray(x1,[0 1],'symmetric','post');
x = (1:size(x1,2));
xv = (1:(1/period):size(x1,2)+((period - 1)/period));
z0 = zeros(size(x1,1),size(x1,2)*period);
for j = 1 : size(x1,1)
    z0(j,:) = interpn(x,x1(j,:),xv,'cubic');
end
%z0(:,1:(period)) = [];
z0(:,end-(period-1):end) = [];

%% do reconstruction row by row as 
for p = 1 : size(line_data,1)
    x1 = z0(p,:);
    y1_move = squeeze(line_data(p,:,:));
    y1_move = y1_move';
    y1_move = y1_move(2:end,:);
    y1_move = padarray(y1_move,[0 1],'both');
    x1 = padarray(x1,[0 2],'both');

    [y1_temp,r_temp] = reconRow(x1,y1_move,1/period,s_set);
    z0(p,:) = y1_temp(3:94);
end
z0 = z0*2;
z0 = z0(:,3:end-5);
figure;imagesc(z0);colormap gray;axis image
