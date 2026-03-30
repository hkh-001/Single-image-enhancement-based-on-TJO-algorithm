clc; clear; close all;

% ====== Fix font and interpreter issues ======
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');
set(groot,'defaultTextInterpreter','none');
set(groot,'defaultLegendInterpreter','none');
set(groot,'defaultAxesTickLabelInterpreter','none');

% ====== Population size N ======
N = [6 12 15 24];

% ====== Experimental results ======
psnr_val = [28.40 33.59 27.37 27.02];
ssim_val = [0.9684 0.9895 0.9617 0.9589];

% ====== Plot ======
figure('Color','w');
hold on;

% Left axis: PSNR (solid line)
yyaxis left
plot(N, psnr_val, 'ks-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','k');
ylabel('PSNR (dB)','FontSize',13);

% Right axis: SSIM (solid line)
yyaxis right
plot(N, ssim_val, 'rs-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','r');
ylabel('SSIM','FontSize',13);

% X-axis and title
xlabel('Population Size N','FontSize',13);
title('PSNR and SSIM versus Population Size N','FontSize',14);

% Grid (dashed style)
grid on;
ax = gca;
ax.GridLineStyle = '--';
ax.GridAlpha = 0.6;

legend('T91 PSNR','T91 SSIM','Location','southwest');
set(gca,'FontSize',12);

% ====== Optional: annotate values ======
yyaxis left
for i = 1:numel(N)
    text(N(i), psnr_val(i), sprintf('  %.2f', psnr_val(i)), ...
        'FontSize',11, 'Color','k', 'VerticalAlignment','bottom');
end

yyaxis right
for i = 1:numel(N)
    text(N(i), ssim_val(i), sprintf('  %.4f', ssim_val(i)), ...
        'FontSize',11, 'Color','r', 'VerticalAlignment','top');
end

% ====== Optional: save ======
% exportgraphics(gcf, 'ablation_population_size.png', 'Resolution', 300);