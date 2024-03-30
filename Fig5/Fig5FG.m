% HISTORY:  written by zihao, 2023/08/09
%%
clc;clear;
%% Fig.5F - directional patterns
% plot_window_size = 300;
% x_min = 350; x_max = x_min + plot_window_size;
% y_min = 90; y_max = y_min + plot_window_size;
% image_frame = 491; image_output = 'Fig5F-1.png';
% image_frame = 499; image_output = 'Fig5F-2.png';
% image_frame = 502; image_output = 'Fig5F-3.png';
% image_frame = 512; image_output = 'Fig5F-4.png';
% image_frame = 520; image_output = 'Fig5F-5.png';
% image_frame = 531; image_output = 'Fig5F-6.png';
%% Fig.5G - complex motion patterns
image_frame = 346; image_output = 'Fig5G.png';
x_min = 330; x_max = 900;  y_min = 150; y_max = 440;
%%
plot_window = [x_min,x_max,y_min,y_max];
% calculation: 128 - 256
map_size = [42, 84]; % 10 pixel gap, this depends on the vector dimension
image_name          =   'ChanA';
image_path          =   './ChanA/';
image_data_path     =   './results_velocity-data_w128256_contrast-50';
image_output_path   =   './';
pixelSize           =   0.73; % unit: um,10X,air,NA:0.5, fluorescence (calibrated)
vector_plot_gap     =   8; % plot every number of vectors
%%
result = zeros(length(image_frame),4);
for image_index = 1:length(image_frame)
    count_t = image_frame(image_index);
    disp(count_t);
    image_name_temp = fileName(image_name,count_t,'.tif',1);
    frame = imread(fullfile(image_path,image_name_temp));
    data_name_temp = fileName(image_name,count_t,'.txt',2);
    data = importdata(fullfile(image_data_path,data_name_temp));
    xs = data(:,1);         ys = data(:,2);
    dxs = data(:,3);        dys = data(:,4);
    theta = atan2(dys,dxs); ds = sqrt(dxs.^2 + dys.^2);
    xs_2D = reshape(xs,map_size);   ys_2D = reshape(ys,map_size);
    dxs_2D = reshape(dxs,map_size); dys_2D = reshape(dys,map_size);
    ds_2D = reshape(ds,map_size);   theta_2D = reshape(theta,map_size);
    %% select the region of ploting
    list_temp_x = and(xs>x_min,xs<x_max);
    list_temp_y = and(ys>y_min,ys<y_max);
    list_temp = and(list_temp_x,list_temp_y);
    theta = theta(list_temp); ds = ds(list_temp);
    xs = xs(list_temp); ys = ys(list_temp);
    dxs = dxs(list_temp); dys = dys(list_temp);
    theta_cos = mean(cos(theta)); theta_sin = mean(sin(theta));
    result(image_index,:) = [count_t, mean(ds),std(ds),atan2(theta_sin,theta_cos)];
%% remove the global translation in this field of view
    %%
    fig = figure(1);clf;
    Lx = x_max - x_min; Ly = y_max - y_min;
    screensize = get( groot, 'Screensize' ); Sx = screensize(3);Sy = screensize(4);
    set(fig,'Position', [floor(Sx/2-Lx/2) floor(Sy/2-Ly/2) Lx Ly]);
%     set(gca,'units','normalized','Position',[0 0 1 1]);
%%  plot the image overlaied with long axis and trajectories
    fig_position = [0, 0, 1, 1];
    h1 = axes('Position', fig_position);
%     imagesc(frame);colormap("gray"); clim([500,850]); colormap('gray');
%     frame = zeros(size(frame)); imagesc(frame); clim([0,1]); colormap('gray');
    total_color = length(hsv); Colors = hsv;
    [count_i,count_j] = size(theta_2D);
    angle_color_2D = zeros(count_i,count_j,3);
    list_temp_x = and(xs_2D>x_min,xs_2D<x_max);
    list_temp_y = and(ys_2D>y_min,ys_2D<y_max);
    list_temp = and(list_temp_x,list_temp_y);
    [row_indices, col_indices] = find(list_temp);
    for i = 1 : count_i
        for j = 1 : count_j
            angle_color_2D(i,j,1:3) = Colors(floor((theta_2D(i,j)+pi)/(2*pi)*(total_color-1))+1,1:3);
            temp_color = [angle_color_2D(i,j,1),angle_color_2D(i,j,2),angle_color_2D(i,j,3)];
            factor = ds_2D(i,j)/(20/0.73); 
            angle_color_2D(i,j,:) = temp_color .* factor + [0,0,0] .* (1-factor); % black
        end
    end
    angle_color_2D = angle_color_2D(min(row_indices):max(row_indices),min(col_indices):max(col_indices),:);
    imshow(angle_color_2D); axis ij; axis equal;
    hold on;
    plotVectorField(xs(1:vector_plot_gap:end),ys(1:vector_plot_gap:end), ...
        dxs(1:vector_plot_gap:end),dys(1:vector_plot_gap:end),fig_position,plot_window);
    hold off;
    %%
    saveas(fig,fullfile(image_output_path,image_output));
end
%%
function plotVectorField(vel_x_all,vel_y_all,vel_ux_all,vel_uy_all,axis_location,plot_window)
x_min = plot_window(1); x_max = plot_window(2);
y_min = plot_window(3); y_max = plot_window(4);
Lx = x_max - x_min; Ly = y_max - y_min;
for count = 1 : nnz(vel_x_all)
%% size scale with velocity
    vel_x = vel_x_all(count) - x_min; % relative to image size
    vel_y = vel_y_all(count) - y_min;
    vel_ux = vel_ux_all(count);  vel_uy = vel_uy_all(count);
    theta = atan2(vel_uy,vel_ux); vel_u = sqrt(vel_ux^2 + vel_uy^2);
    if vel_u == 0
        continue;
    end
    arrow_head_length = 8;
    arrow_length = vel_u + arrow_head_length;
    temp_color = [0.95,0.95,0.95]; % white
    ax = ([vel_x,vel_x+arrow_length*cos(theta)]/Lx)*axis_location(3)+axis_location(1);
    ay = [vel_y,vel_y+arrow_length*sin(theta)]/Ly*axis_location(4)+axis_location(2);
    a = annotation('arrow');
    a.X = ax; a.Y = 1 - ay; % inversed, Y-direction
    a.Color = temp_color;
    a.HeadStyle = 'vback1';
    a.HeadLength = arrow_head_length;
    a.HeadWidth = 8;
    a.LineWidth = 4;
end
end