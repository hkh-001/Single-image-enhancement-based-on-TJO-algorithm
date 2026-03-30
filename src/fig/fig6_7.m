%% Initialization and Data Preparation
clear; clc; close all;
addpath(genpath('D:\Data'));
img_name = 'painting'; 

read_and_gray = @(suffix) double(rgb2gray(imread([img_name, suffix, '.png'])));
try
    img_GT = read_and_gray(''); 

    img_CSGIS = read_and_gray('_x2_CSGIS'); 
    img_WGIF  = read_and_gray('_WGIF');
    img_ILS   = read_and_gray('_ILS');
    img_TH    = read_and_gray('_TH');
    img_ZF    = read_and_gray('_X2_ZF');
    img_IPRH  = read_and_gray('_TJO'); 
catch ME
end
%% Calculate Residual Plot (Absolute Difference)
res_CSGIS = abs(img_CSGIS - img_GT);
res_WGIF  = abs(img_WGIF - img_GT);
res_ILS   = abs(img_ILS - img_GT);
res_TH    = abs(img_TH - img_GT);
res_ZF    = abs(img_ZF - img_GT);
res_IPRH  = abs(img_IPRH - img_GT);

max_residual_value = max([res_CSGIS(:); res_WGIF(:); res_ILS(:); res_TH(:); res_ZF(:); res_IPRH(:)]);
display_limit = 80; 
common_clim = [0, display_limit]; 
%% Graphic Design and Layout
figure('Units', 'centimeters', 'Position', [2, 2, 18, 10]);
t = tiledlayout(2, 3, 'TileSpacing', 'tight', 'Padding', 'compact');

font_settings = {'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'normal'};
font_setting = {'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold'};

font_en = 'Times New Roman';
nexttile; imagesc(res_CSGIS); 
title('CSGIS', font_settings{:}); axis off; axis image; caxis(common_clim);

nexttile; imagesc(res_WGIF); 
title('WGIF', font_settings{:}); axis off; axis image; caxis(common_clim);

nexttile; imagesc(res_ILS); 
title('ILS', font_settings{:}); axis off; axis image; caxis(common_clim);

nexttile; imagesc(res_TH); 
title('TH', font_settings{:}); axis off; axis image; caxis(common_clim);

nexttile; imagesc(res_ZF); 
title('ZF', font_settings{:}); axis off; axis image; caxis(common_clim);

nexttile; imagesc(res_IPRH); 
title('PCRH(Ours)', font_setting{:}); axis off; axis image; caxis(common_clim);

% 1. Set Global Chromatography
colormap(jet);

cb = colorbar; 
cb.Position = [0.92, 0.15, 0.02, 0.7]; 

% 4. Custom Color Bar Style
cb.Label.String = 'Residual Strength';
cb.Label.FontName = font_en; % 使用中文字体
cb.Label.FontSize = 10;

% 5. Set scale (low, medium, high)
cb.Ticks = [common_clim(1), mean(common_clim), common_clim(2)];
cb.TickLabels = {'Low', 'Medium', 'High'};
cb.FontName = font_en;
cb.FontSize = 20;
t.OuterPosition = [0, 0, 0.9, 1]; 
%% export
% exportgraphics(gcf, ['Residual_Heatmap_Comparison_', img_name, '.pdf'], 'ContentType', 'vector');
% exportgraphics(gcf, ['Residual_Heatmap_Comparison_', img_name, '.png'], 'Resolution', 600);
