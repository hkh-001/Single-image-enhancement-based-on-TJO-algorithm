clc; clear; close all;

% ====== Font settings (paper style) ======
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');

% Search radius
r = [10 15 20 25 30];

% PSNR
psnr_val = [26.54 30.20 33.59 30.60 28.37];

% SSIM
ssim_val = [0.955 0.972 0.989 0.979 0.968];

figure('Color','w');
hold on

% ===== Left axis: PSNR (solid line) =====
yyaxis left
plot(r, psnr_val, 'ks-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','k')
ylabel('PSNR (dB)','FontSize',13)

% ===== Right axis: SSIM (solid line) =====
yyaxis right
plot(r, ssim_val, 'rs-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','r')
ylabel('SSIM','FontSize',13)

% Axis labels and title
xlabel('Search Radius r','FontSize',13)
title('PSNR and SSIM versus Search Radius r','FontSize',14)

% ===== Dashed grid =====
grid on
ax = gca;
ax.GridLineStyle = '--';
ax.GridAlpha = 0.6;

legend('T91 PSNR','T91 SSIM','Location','southwest')
set(gca,'FontSize',12)