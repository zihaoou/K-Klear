% Read imaginary refractive index and calculate real part
% HISTORY: written by zihao, 2021-07-14
clc; clear;
%% generate a hypothetic profile 
% Calculation wavelength range
lambda = 200:1:1000; lambda = lambda';
% Hypothetic Gaussian absorption peak 
mu = 428; sigma = 40;
imag_n_1 = 0.1*exp(-(lambda-mu).^2/2/sigma^2);
imag_n_2 = 0.2*exp(-(lambda-mu).^2/2/sigma^2);
imag_n_3 = 0.5*exp(-(lambda-mu).^2/2/sigma^2);
imag_n_4 = 1.0*exp(-(lambda-mu).^2/2/sigma^2);
%% calculation and plotting
result_1 = kk_lambda_n(lambda,imag_n_1);
result_2 = kk_lambda_n(lambda,imag_n_2);
result_3 = kk_lambda_n(lambda,imag_n_3);
result_4 = kk_lambda_n(lambda,imag_n_4);
figure(1);clf;
subplot(1,2,1)
hold on
plot(result_1.lambda,result_1.n_imag,'-','Color',[0,0,0.6],'Linewidth',2);
plot(result_2.lambda,result_2.n_imag,'-','Color',[0.6,0,0.6],'Linewidth',2);
plot(result_3.lambda,result_3.n_imag,'-','Color',[0.8,0.4,0.4],'Linewidth',2);
plot(result_4.lambda,result_4.n_imag,'-','Color',[1.0,0.8,0.2],'Linewidth',2);
legend('peak = 0.1','peak = 0.2','peak = 0.5','peak = 1.0');
xlabel('Wavelength \lambda (nm)');
ylabel('\it{n"}');
axis([250,850,-0.1,1.1]);
set(gca,'Fontsize',15);
hold off
subplot(1,2,2)
hold on
plot(result_1.lambda,result_1.n_real - 1,'-','Color',[0,0,0.6],'Linewidth',2);
plot(result_2.lambda,result_2.n_real - 1,'-','Color',[0.6,0,0.6],'Linewidth',2);
plot(result_3.lambda,result_3.n_real - 1,'-','Color',[0.8,0.4,0.4],'Linewidth',2);
plot(result_4.lambda,result_4.n_real - 1,'-','Color',[1.0,0.8,0.2],'Linewidth',2);
xlabel('Wavelength \lambda (nm)');
ylabel('\it{n''}');
axis([250,850,-0.6,0.8]);
set(gca,'Fontsize',15);
hold off

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