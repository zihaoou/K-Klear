% NAME:  moviePlotNetworkEvolution.m
% PURPOSE: identify in focus by calculate local contrast value in a
% selected region
% HISTORY:  written by zihao, 2023/08/09
%%
clc;clear;
image_name          =   'ChanA';
image_path          =   './ChanA/';
contrast_threshold  =   50;
%%
videoFile = 'movie_check-local-focus';  % Output video file name
frameRate = 28;  % Frames per second
videoObj = VideoWriter(videoFile, 'Motion JPEG AVI');
videoObj.FrameRate = frameRate;
open(videoObj);
%%
image_frame = 1:1:1000;     % frame range of the video
x_min = 400; x_max = 700;   % small region range in x coordinates
y_min = 50;  y_max = 350;   % small region range in y coordinates
plot_window = [x_min,x_max,y_min,y_max];
result = zeros(length(image_frame),2);
for count = 1:length(image_frame)
    count_t = image_frame(count);
    disp(count_t);
    image_name_temp = fileName(image_name,count_t,'.tif',1);
    frame = imread(fullfile(image_path,image_name_temp));
    frame = frame(y_min:y_max,x_min:x_max);
    contrast = std2(frame);
    result(count,:) = [count_t,contrast];
    %%  plot the image overlaied with long axis and trajectories
    fig = figure(1);clf;
    Lx = x_max - x_min; Ly = y_max - y_min;
    screensize = get( groot, 'Screensize' ); Sx = screensize(3);Sy = screensize(4);
    set(fig,'Position', [floor(Sx/2-Lx/2) floor(Sy/2-Ly/2) Lx Ly]);
    fig_position = [0, 0, 1, 1];
    h1 = axes('Position', fig_position);
    imagesc(frame);colormap("gray"); clim([500,850]); colormap('gray');
    axis equal; axis off;
    hold on;
    if contrast < contrast_threshold
        color_temp = 'r';
    else
        color_temp = 'b';
    end
    text(5,15,['Contrast = ',num2str(contrast)],'FontSize',15,'Color',color_temp);
    text(5,35,['Frame = ',num2str(count_t)],'FontSize',15,'Color','w');
    hold off;
    frame = getframe;
    writeVideo(videoObj, frame);
end
close(videoObj);
%%
contrast_temp = result(:,2);
list_temp = contrast_temp > contrast_threshold;
disp(nnz(list_temp));
result = [result,list_temp];
contrast_smoothed = movmean(result(:,2),5);
[~,locs] = findpeaks(contrast_smoothed,result(:,1));
list_temp = zeros(length(result),1);
list_temp(locs) = 1;
result = [result,list_temp];
save('movie_contrast-50_check-motion.mat','result');
save('movie_contrast-50_peak.mat','locs');