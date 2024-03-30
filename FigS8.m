% Function: theoretical prediction of scattering prediction in relation to
% change of background refractive index
% Reference: Eq.6 (Pg.3) in Optical Clearing of Tissues and Blood, Tuchin
n_background = linspace(1.33,1.53,101);
n_silica = 1.43; % refractive index of silica
m = n_silica ./ n_background;
relative_mu_s = abs((m-1).^2.09) / abs((m(1)-1).^2.09);
%% Plotting
figure(1);clf;
plot(n_background,relative_mu_s,'--','Color',[0.6,0.6,0.6],'Linewidth',2);
xlabel('\it{n''}_{background}');
ylabel('\mu_t / \mu_{t, 0M}');
axis([1.32,1.53,-0.1,1.1]);
set(gca,'Fontsize',15);