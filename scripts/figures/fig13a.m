clc; clear; close all;

% ===== Font / Interpreter settings =====
set(groot,'defaultAxesFontName','Microsoft YaHei');
set(groot,'defaultTextFontName','Microsoft YaHei');
set(groot,'defaultTextInterpreter','none');
set(groot,'defaultLegendInterpreter','none');
set(groot,'defaultAxesTickLabelInterpreter','none');

% ===== Step size =====
step_size = [1 2 3 4];

% ===== Step-size ablation results (T91) =====
psnr_val = [27.8927 27.5755 27.0500 26.5684];    
ssim_val = [0.966530 0.963242 0.957500 0.951405];

% ===== Plot =====
figure('Color','w');
hold on;

% Left axis: PSNR
yyaxis left
plot(step_size, psnr_val, 'ks-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','k');
ylabel('PSNR (dB)','FontSize',13);
ax = gca;
ax.YAxis(1).Color = 'k';

% Right axis: SSIM
yyaxis right
plot(step_size, ssim_val, 'rd-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','r');
ylabel('SSIM','FontSize',13);
ax.YAxis(2).Color = 'r';

% Labels
xlabel('Step size','FontSize',13);
title('PSNR and SSIM versus Step Size','FontSize',14);

% Dashed grid
grid on;
ax.GridLineStyle = '--';
ax.GridAlpha = 0.6;

legend('T91-PSNR','T91-SSIM','Location','southwest');
set(gca,'FontSize',12);

% Optional save
% exportgraphics(gcf, 'ablation_stepsize_quality.png', 'Resolution', 300);