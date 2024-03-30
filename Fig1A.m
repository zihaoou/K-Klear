% Read imaginary refractive index and calculate real part
% HISTORY: written by zihao, 2021-07-14
clc; clear;
%% generate a hypothetic profile 
n_real_water = importdata('water_RI-real.mat');
% Calculation wavelength range
lambda = 200:1:1000; lambda = lambda';
% Hypothetic Gaussian absorption peak 
mu = 428; sigma = 40;
imag_n = 0.5*exp(-(lambda-mu).^2/2/sigma^2);
%% calculation and plotting
result = kk_lambda_n(lambda,imag_n);
figure(1);clf;
hold on
yyaxis right
plot(n_real_water(:,1),n_real_water(:,2),'b-','Linewidth',2);
text(650,1.28,'Water \it{n''}','Color','b','FontSize',15);
plot(result.lambda,result.n_real - 1 + n_real_water(:,2),'-','Color',[0.4,0.8,0.4],'Linewidth',2);
text(600,1.58,'Dye solution \it{n''}','Color',[0.4,0.8,0.4],'FontSize',15);
xlabel('Wavelength \lambda (nm)');
ylabel('\it{n''}');
axis([250,850,1.0,1.75]);
ax = gca;
ax.YColor = 'k';
yyaxis left
plot(result.lambda,result.n_imag,'--','Color',[0.7,0.7,0.7],'Linewidth',2);
text(280,0.42,'Dye \it{n"}','Color', [0.7,0.7,0.7],'FontSize',15);
ylabel('\it{n"}');
axis([250,850,-0.05,0.55]);
ax = gca;
ax.YColor = [0.7,0.7,0.7];
set(gca,'Fontsize',15);

function result = kk_lambda_n(lambda,imag_n)
% FUNCTION: calculate the real part of refractive index based on the
% imaginary refractive index.
% HISOTRY: written by zihao, 2020-07-14
%% calculation initialization
result = struct;
g=length(lambda); % Size of the vectors.
real_n=zeros(g,1); % The output is initialized.
a=zeros(size(imag_n));
b=zeros(size(imag_n));
% Two vectors for intermediate calculations are initialized
% Two parts of the Cauchy value, before/after the singular point
delta_lambda = lambda(2)-lambda(1); % Here we compute the interval
if delta_lambda < 0
    % check the integration sign is correct
    lambda = flipud(lambda); imag_n = flipud(imag_n);
    delta_lambda = lambda(2)-lambda(1);
end
%% calculation detais
for k=2:g
    b(1)=b(1)+imag_n(k)/lambda(k)/(1-(lambda(k)^2/lambda(1)^2));
end
real_n(1)=2/pi*delta_lambda*b(1);
for k=1:g-1
    a(g)=a(g)+imag_n(k)/lambda(k)/(1-(lambda(k)^2/lambda(g)^2));
end
real_n(g)=2/pi*delta_lambda*a(g);
epsilon = 1;
for j=1+epsilon:g-epsilon
    for k=1:j-epsilon
        a(j)=a(j)+imag_n(k)/lambda(k)/(1-(lambda(k)^2/lambda(j)^2));
    end
    for k=j+epsilon:g
        b(j)=b(j)+imag_n(k)/lambda(k)/(1-(lambda(k)^2/lambda(j)^2));
    end
    real_n(j)=2/pi*delta_lambda*(a(j)+b(j));
end
result.lambda = lambda;
result.n_real = real_n + 1;
result.n_imag = imag_n;
end