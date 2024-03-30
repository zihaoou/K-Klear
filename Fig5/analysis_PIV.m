%% HISTORY: written by zihao. 2023-09-13
%% parameters for calculating the vector
clc;clear;
image_name        = "ChanA";
image_path        = './ChanA_band-pass-2-100/';
contrast = importdata("movie_contrast-50_check-motion.mat");
%% Motility patterns (between neighboring frames of high contrast)
% image_frame = 1:1:981;
% data_output_path = './results_velocity-data_w128256_contrast-50/';
%% Motility patterns (between frames of peak contrast)
% image_frame = importdata("movie_contrast-50_peak.mat");
image_frame = [343,353]; % contraction
% image_frame = [939,949]; % Expansion
% image_frame = [452,462]; % ratation
data_output_path = './results_velocity-data_w128256_peak-50/';
%% parameters for calculating the displacement vector (in pixel)
size_window = 128; % window size for features
size_search = 256; % search size for calculation of image correlation
size_vector_gap = 10; % shift in pixels between neighboring window
filter_size = [5, 5]; % average between neighoring displacement vectors
%% go through all the frames
for frame_index = 1 : length(image_frame) - 1
    current_frame = image_frame(frame_index);
    if contrast(contrast(:,1)==current_frame,3) % if current frame in focus
        disp(current_frame);
    else
        continue;
    end
    next_frame = image_frame(frame_index+1);
    while ~contrast(contrast(:,1)==next_frame,3) % if next frame not in focus
        frame_index = frame_index + 1;
        next_frame = image_frame(frame_index+1);
    end
    image_name_temp = fileName(image_name,current_frame,'.tif',1);
    frame_curr = imread(fullfile(image_path,image_name_temp));
    image_name_temp = fileName(image_name,image_frame(frame_index+1),'.tif',1);
    frame_next = imread(fullfile(image_path,image_name_temp));
    [xs, ys, dxs, dys] = vel_field(frame_curr, frame_next, size_window, size_search, size_vector_gap);
    mean_kernel = ones(filter_size) / prod(filter_size);
    dxs = imfilter(dxs, mean_kernel, 'conv');
    dys = imfilter(dys, mean_kernel, 'conv');
    norm_u = sqrt(dxs.^2 + dys.^2);
    directions = atan2(dys, dxs);
    data_name_temp = fileName(image_name,current_frame,'.txt',2);
    data_temp = [reshape(xs,[],1),reshape(ys,[],1),reshape(dxs,[],1),reshape(dys,[],1)];
    writematrix(data_temp, fullfile(data_output_path,data_name_temp), 'Delimiter', '\t');
end
%%
function [vec_x, vec_y, dxs, dys] = vel_field(curr_frame, next_frame, win_size, search_size, vector_gap)
half_win_size       =   win_size / 2;
half_search_size    =   search_size / 2;
[h, w] = size(curr_frame);
ys = half_win_size + 1   :   vector_gap  :  h - half_win_size;
xs = half_win_size + 1   :   vector_gap  :  w - half_win_size;
vec_x = zeros(length(ys), length(xs));
vec_y = zeros(length(ys), length(xs));
dys = zeros(length(ys), length(xs));
dxs = zeros(length(ys), length(xs));
for iy = 1:length(ys)
    y = ys(iy);
    for ix = 1:length(xs)
        x = xs(ix);
        rect_curr = [x - half_win_size, y - half_win_size, ...
                     x + half_win_size, y + half_win_size];
        search_win_x_min = x - half_search_size;
        search_win_y_min = y - half_search_size;
        search_win_x_max = x + half_search_size;
        search_win_y_max = y + half_search_size;
        rect_search_win = [max(1, search_win_x_min),max(1, search_win_y_min),...
            min(w, search_win_x_max), min(h, search_win_y_max)];
        int_win = curr_frame(rect_curr(2):rect_curr(4),rect_curr(1):rect_curr(3));
        search_win = next_frame(rect_search_win(2):rect_search_win(4),rect_search_win(1):rect_search_win(3));
        c = normxcorr2(int_win,search_win);
        % offset found by correlation
        [max_c,imax] = max(abs(c(:)));
        [ypeak,xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(int_win,2)),(ypeak-size(int_win,1))];
        % relative offset of position of subimages
        rect_offset = [(rect_search_win(1)-rect_curr(1)),(rect_search_win(2)-rect_curr(2))];
        % total offset
        offset = corr_offset + rect_offset;
        dys(iy, ix) = offset(2);
        dxs(iy, ix) = offset(1);
        vec_x(iy, ix) = x;
        vec_y(iy, ix) = y;
    end
end
end