clc;clear;
%% Fig 5J - Rotation
image_frame         =   452;     plot_window_size = 250;
x_min = 430; x_max = x_min + plot_window_size;
y_min = 80; y_max = y_min + plot_window_size;
c_max = 0.15; c_min = -c_max;
image_output = 'Fig5J.png';
%%
plot_window = [x_min,x_max,y_min,y_max];
% calculation: 128 - 256
map_size = [42, 84]; % 10 pixel gap, this depends on the vector dimension
image_name          =   'ChanA';
image_path          =   './ChanA/';
image_data_path     =   './results_velocity-data_w128256_peak-50';
pixelSize           =   0.73; % unit: um,10X,air,NA:0.5, fluorescence (calibrated)
vector_plot_gap     =   7; % plot every number of vectors
%%
for count_t = image_frame
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
    ds_2D = reshape(ds,map_size);
    list_temp_x = and(xs>x_min,xs<x_max); list_temp_y = and(ys>y_min,ys<y_max);
    list_temp = and(list_temp_x,list_temp_y);
    xs = xs(list_temp); ys = ys(list_temp);
    dxs = dxs(list_temp); dys = dys(list_temp);
    dxs = dxs - mean(dxs);          dys = dys - mean(dys);
    dxs_2D = dxs_2D - mean(dxs);    dys_2D = dys_2D - mean(dys);
    theta = theta(list_temp); ds = ds(list_temp);
    [curlz,cav] = curl(xs_2D,ys_2D,dxs_2D,dys_2D);
    %%
    fig = figure(1);clf;
    Lx = x_max - x_min; Ly = y_max - y_min;
    screensize = get( groot, 'Screensize' ); Sx = screensize(3);Sy = screensize(4);
    set(fig,'Position', [floor(Sx/2-Lx/2) floor(Sy/2-Ly/2) Lx Ly]);
%%  plot the image overlaied with long axis and trajectories
    fig_position = [0, 0, 1, 1];
    h1 = axes('Position', fig_position);
    contourf(xs_2D,ys_2D,curlz,200, 'LineStyle','none'); axis equal; axis ij;
    load('cmap_curl_2023-10-19.mat','mycmap');
    ax = gca; colormap(ax,mycmap); clim([c_min,c_max]); axis off;
    xlim([x_min,x_max]); ylim([y_min,y_max]);
    hold on;
    plotVectorField(xs(1:vector_plot_gap:end),ys(1:vector_plot_gap:end), ...
        dxs(1:vector_plot_gap:end),dys(1:vector_plot_gap:end),fig_position,plot_window);
    hold off;
    %%
    saveas(fig,fullfile(image_output));
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
    arrow_head_length = 12;
    arrow_length = vel_u + arrow_head_length;
    temp_color = [0.2,0.2,0.2];
    ax = ([vel_x,vel_x+arrow_length*cos(theta)]/Lx)*axis_location(3)+axis_location(1);
    ay = [vel_y,vel_y+arrow_length*sin(theta)]/Ly*axis_location(4)+axis_location(2);
    a = annotation('arrow');
    a.X = ax; a.Y = 1 - ay; % inversed, Y-direction
    a.Color = temp_color;
    a.HeadStyle = 'vback1';
    a.HeadLength = arrow_head_length;
    a.HeadWidth = 12;
    a.LineWidth = 4;
end
end