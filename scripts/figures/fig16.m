clc; clear; close all;

% ===== Font / Interpreter settings =====
set(groot,'defaultAxesFontName','Microsoft YaHei');
set(groot,'defaultTextFontName','Microsoft YaHei');
set(groot,'defaultTextInterpreter','none');
set(groot,'defaultLegendInterpreter','none');
set(groot,'defaultAxesTickLabelInterpreter','none');

% ===== Fixed texture weight =====
wt = 0.001;

% ===== wg parameter =====
wg = [0.001 0.003 0.007 0.012 0.02];

% ===== Experimental results =====
psnr_val = [28.66 28.65 28.64 28.62 28.61];
ssim_val = [0.9685 0.9684 0.9684 0.9683 0.9682];

% ===== Plot =====
figure('Color','w');
hold on;

% Left axis: PSNR
yyaxis left
plot(wg, psnr_val, 'ks-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','k');
ylabel('PSNR (dB)','FontSize',13);
ax = gca;
ax.YAxis(1).Color = 'k';

% Right axis: SSIM
yyaxis right
plot(wg, ssim_val, 'rd-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','r');
ylabel('SSIM','FontSize',13);
ax.YAxis(2).Color = 'r';

% Labels
xlabel('Gradient Weight w_g','FontSize',13);
title(sprintf('PSNR and SSIM versus Gradient Weight w_g (w_t = %.3f)', wt), 'FontSize',14);

% Grid
grid on;
ax.GridLineStyle = '--';
ax.GridAlpha = 0.6;

legend('T91-PSNR','T91-SSIM','Location','southwest');
set(gca,'FontSize',12);

% Optional save
% exportgraphics(gcf, 'ablation_wg.png', 'Resolution', 300);