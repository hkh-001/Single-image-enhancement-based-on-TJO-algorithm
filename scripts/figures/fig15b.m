clc; clear; close all;

% ===== Anti-garbled text (keep your settings) =====
set(groot,'defaultAxesFontName','Microsoft YaHei');
set(groot,'defaultTextFontName','Microsoft YaHei');
set(groot,'defaultTextInterpreter','none');
set(groot,'defaultLegendInterpreter','none');
set(groot,'defaultAxesTickLabelInterpreter','none');

% ===== Population size =====
N = [6 12 15 24];

% ===== Total runtime (minutes) =====
time_min = [271.17 107.75 442.85 612.87];

% ===== Plot =====
figure('Color','w');
plot(N, time_min, 'bo-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','b');

xlabel('Population Size N','FontSize',13);
ylabel('Total Runtime (min)','FontSize',13);
title('Total Runtime versus Population Size N','FontSize',14);

grid on;
ax = gca;
ax.GridLineStyle = '--';   % dashed grid
ax.GridAlpha = 0.6;

set(gca,'FontSize',12);

% ===== Value annotations =====
for i = 1:length(N)
    text(N(i), time_min(i), sprintf('  %.1f', time_min(i)), ...
        'FontSize',11, 'Color','b', 'VerticalAlignment','bottom');
end

% ===== Save (optional) =====
% exportgraphics(gcf, 'ablation_popsize_time.png', 'Resolution', 300);