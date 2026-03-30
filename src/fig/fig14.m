clc; clear; close all;

% ===== Font settings =====
set(groot,'defaultAxesFontName','Microsoft YaHei');
set(groot,'defaultTextFontName','Microsoft YaHei');
set(groot,'defaultTextInterpreter','none');
set(groot,'defaultLegendInterpreter','none');
set(groot,'defaultAxesTickLabelInterpreter','none');

% ===== Maximum Iterations =====
T = [10 15 20 30];

% ===== Experimental Results =====
psnr_val = [26.69 33.59 27.41 27.20];
ssim_val = [0.9564 0.9895 0.9620 0.9603];

figure('Color','w');
hold on;

% ===== Left axis: PSNR =====
yyaxis left
plot(T, psnr_val, 'ks-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','k');
ylabel('PSNR (dB)','FontSize',13);
ax = gca;
ax.YAxis(1).Color = 'k';

% ===== Right axis: SSIM =====
yyaxis right
plot(T, ssim_val, 'rd-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','r');
ylabel('SSIM','FontSize',13);
ax.YAxis(2).Color = 'r';

% ===== Labels & Title =====
xlabel('Maximum Iterations T','FontSize',13);
title('PSNR and SSIM versus Maximum Iterations T','FontSize',14);

% ===== Dashed Grid =====
grid on;
ax.GridLineStyle = '--';
ax.GridAlpha = 0.6;

legend('T91-PSNR','T91-SSIM','Location','southwest');
set(gca,'FontSize',12);

% ===== Optional Save =====
% exportgraphics(gcf, 'ablation_maxIter_T.png', 'Resolution', 300);