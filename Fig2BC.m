% Read imaginary refractive index and calculate real part
% HISTORY: written by zihao, 2021-07-14
clc; clear;
%% Figure 2B&C - generate a hypothetic profile based on Lorentz model
% Calculation wavelength range
lambda = 1:1:1000; lambda = lambda';
% Hypothetic oschillation wavelength, unit: nm
lambda_1 = 100;
lambda_2 = 250;
lambda_3 = 400;
%% calculation and plotting
result_1 = lorentzModel(lambda,lambda_1);
result_2 = lorentzModel(lambda,lambda_2);
result_3 = lorentzModel(lambda,lambda_3);
figure(1);clf;
subplot(1,2,1)
hold on
plot(result_1.lambda,result_1.n_imag,'-','Color',[0.2,0.6,1.0],'Linewidth',2);
plot(result_2.lambda,result_2.n_imag,'-','Color',[0.4,0.8,0.4],'Linewidth',2);
plot(result_3.lambda,result_3.n_imag,'-','Color',[1.0,0.4,0.4],'Linewidth',2);
legend('\omega_0 = 100 nm','\omega_0 = 250 nm','\omega_0 = 400 nm');
xlabel('Wavelength \lambda (nm)');
ylabel('\it{n"}');
axis([0,750,-0.025,0.25]);
set(gca,'Fontsize',15);
hold off
subplot(1,2,2)
hold on
plot(result_1.lambda,result_1.n_real,'-','Color',[0.2,0.6,1.0],'Linewidth',2);
plot(result_2.lambda,result_2.n_real,'-','Color',[0.4,0.8,0.4],'Linewidth',2);
plot(result_3.lambda,result_3.n_real,'-','Color',[1.0,0.4,0.4],'Linewidth',2);
xlabel('Wavelength \lambda (nm)');
ylabel('\Delta\it{n''}');
axis([0,750,-0.125,0.175]);
set(gca,'Fontsize',15);
hold off

function result = lorentzModel(lambda,lambda_0)
%% calculation initialization
w_p = 5e6; 
w_0 = 2*pi / (lambda_0 * 1e-9);
gamma = w_0/5;
epsilon_real = zeros(size(lambda));
epsilon_imag = zeros(size(lambda));
RefractiveIndex_real = zeros(size(lambda));
RefractiveIndex_imag = zeros(size(lambda));
for count = 1:length(lambda)
    w = 2*pi / (lambda(count) * 1e-9);
    epsilon = 1 + w_p^2 / (w_0^2 - w^2 - 1i* gamma * w);
    RefractiveIndex = sqrt(epsilon);
    epsilon_real(count) = real(epsilon);
    epsilon_imag(count) = imag(epsilon);
    RefractiveIndex_real(count) = real(RefractiveIndex);
    RefractiveIndex_imag(count) = imag(RefractiveIndex);
end
result = struct;
result.lambda = lambda;
result.n_real = RefractiveIndex_real-1;
result.n_imag = RefractiveIndex_imag;
end