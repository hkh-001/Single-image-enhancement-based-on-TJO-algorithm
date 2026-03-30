%% ===================== 局部图版本 =====================
clear; clc; close all;

%% 1. 路径与基础配置
work_dir = 'C:\Users\huang\Desktop\program\fft';
cd(work_dir);
addpath(genpath(work_dir));

img_name = 'tt19';   % 原图名（不带扩展名）
fontName = 'Times New Roman';
fontSize = 12; 
display_limit = 80;

font_normal = {'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'normal'};
font_bold   = {'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold'};

% 保存路径
save_root = work_dir;
if ~exist(save_root, 'dir')
    mkdir(save_root);
end

%% 2. 方法配置
methods = {'CSGIS', 'WGIF', 'TH', 'ZF', 'TJO (Ours)'};
suffixes = {'_x2_CSGIS', '_WGIF', '_TH', '_X2_ZF', '_tjo'};

%% 3. 读取原图
gt_path = fullfile(work_dir, [img_name, '.png']);
if ~exist(gt_path, 'file')
    error('未找到原图文件：%s', gt_path);
end

img_GT_raw = imread(gt_path);
if size(img_GT_raw, 3) == 3
    img_GT_gray = double(rgb2gray(img_GT_raw));
else
    img_GT_gray = double(img_GT_raw);
end

%% 4. 检查各方法结果图是否存在
num_methods = length(methods);
for i = 1:num_methods
    method_path = fullfile(work_dir, [img_name, suffixes{i}, '.png']);
    if ~exist(method_path, 'file')
        error('未找到方法图像文件：%s', method_path);
    end
end

%% 5. 手动框选局部区域
fprintf('>>> 请在弹出图中框选【局部区域】，用于计算傅里叶频谱。双击确认。\n');
h_fig = figure('Name', 'Select Region for Spectrum Analysis', 'Color', 'w');
imshow(img_GT_raw);
title('Drag and Double-click to select a region', 'FontSize', 14);
rect = getrect(h_fig);
crop_rect = round(rect);
close(h_fig);

%% 6. 计算全图残差与局部频谱 + 频谱能量
res_maps_full = cell(1, num_methods);
spec_maps_local = cell(1, num_methods);
spec_energy = zeros(1, num_methods + 1);  % 第1个位置留给GT

% --- GT局部频谱 ---
patch_GT = imcrop(img_GT_gray, crop_rect);
spec_GT = fftshift(fft2(patch_GT));
spec_GT_local = log(1 + abs(spec_GT));
spec_energy(1) = sum(sum(abs(spec_GT).^2));

% --- 各方法 ---
for i = 1:num_methods
    method_path = fullfile(work_dir, [img_name, suffixes{i}, '.png']);
    img_temp_raw = imread(method_path);

    if size(img_temp_raw, 3) == 3
        img_temp_gray = double(rgb2gray(img_temp_raw));
    else
        img_temp_gray = double(img_temp_raw);
    end

    % 第一行：全图残差
    res_maps_full{i} = abs(img_temp_gray - img_GT_gray);

    % 第二行：局部频谱
    patch_temp = imcrop(img_temp_gray, crop_rect);
    spec_temp = fftshift(fft2(patch_temp));
    spec_maps_local{i} = log(1 + abs(spec_temp));
    spec_energy(i+1) = sum(sum(abs(spec_temp).^2));
end

%% 7. 输出并保存频谱能量结果
fprintf('===================== 傅里叶频谱能量 =====================\n');
fprintf('GT 频谱能量：%.4e\n', spec_energy(1));
for i = 1:num_methods
    fprintf('%s 频谱能量：%.4e\n', methods{i}, spec_energy(i+1));
end

energy_save_name = fullfile(save_root, [img_name, '_spectrum_energy.txt']);
fid = fopen(energy_save_name, 'w');
fprintf(fid, '傅里叶频谱能量计算结果（局部区域：[%d, %d, %d, %d]）\n', ...
    crop_rect(1), crop_rect(2), crop_rect(3), crop_rect(4));
fprintf(fid, 'GT,%.4e\n', spec_energy(1));
for i = 1:num_methods
    fprintf(fid, '%s,%.4e\n', methods{i}, spec_energy(i+1));
end
fclose(fid);
fprintf('>>> 频谱能量结果已保存至：%s\n', energy_save_name);

%% 8. 提前保存基础数据
% 8.1 保存GT原图（带红框）
h_gt_fig = figure('Visible', 'off', 'Color', 'w');
imshow(img_GT_raw); hold on;
rectangle('Position', crop_rect, 'EdgeColor', 'r', 'LineWidth', 4.5);
axis off; axis image;
exportgraphics(h_gt_fig, fullfile(save_root, [img_name, '_GT_with_rect.png']), 'Resolution', 300);
close(h_gt_fig);
fprintf('>>> 已保存：%s\n', fullfile(save_root, [img_name, '_GT_with_rect.png']));

% 8.2 保存GT局部频谱图
h_gt_spec_fig = figure('Visible', 'off', 'Color', 'w');
imagesc(spec_GT_local);
colormap(jet);
axis off; axis image;
exportgraphics(h_gt_spec_fig, fullfile(save_root, [img_name, '_GT_local_spectrum.png']), 'Resolution', 300);
close(h_gt_spec_fig);
fprintf('>>> 已保存：%s\n', fullfile(save_root, [img_name, '_GT_local_spectrum.png']));

% 8.3 保存每个方法的残差图 + 局部频谱图
for i = 1:num_methods
    % 残差图
    h_res_fig = figure('Visible', 'off', 'Color', 'w');
    imagesc(res_maps_full{i});
    colormap(jet);
    caxis([0, display_limit]);
    axis off; axis image;
    res_save_name = [img_name, '_', methods{i}, '_residual.png'];
    exportgraphics(h_res_fig, fullfile(save_root, res_save_name), 'Resolution', 300);
    close(h_res_fig);
    fprintf('>>> 已保存：%s\n', fullfile(save_root, res_save_name));

    % 频谱图
    h_spec_fig = figure('Visible', 'off', 'Color', 'w');
    imagesc(spec_maps_local{i});
    colormap(jet);
    axis off; axis image;
    spec_save_name = [img_name, '_', methods{i}, '_local_spectrum.png'];
    exportgraphics(h_spec_fig, fullfile(save_root, spec_save_name), 'Resolution', 300);
    close(h_spec_fig);
    fprintf('>>> 已保存：%s\n', fullfile(save_root, spec_save_name));
end

%% 9. 主图：极致紧凑布局
figWidth = 24; 
figHeight = 6.5; 
h_main_fig = figure('Units', 'centimeters', ...
    'Position', [1, 1, figWidth, figHeight], ...
    'Color', 'w');

% 布局参数
left_margin   = 0.02; 
right_margin  = 0.10;   % 稍微加大，给 colorbar 留空间
bottom_margin = 0.15; 
top_margin    = 0.08; 
row_spacing   = 0.10; 
col_spacing   = 0.01;

available_w = 1 - left_margin - right_margin - (6-1)*col_spacing;
available_h = 1 - top_margin - bottom_margin - row_spacing;
patch_w = available_w / 6;
patch_h = available_h / 2;

for row = 1:2
    for col = 1:6
        x_pos = left_margin + (col-1) * (patch_w + col_spacing);
        y_pos = 1 - top_margin - row * patch_h - (row-1) * row_spacing;

        ax = axes('Position', [x_pos, y_pos, patch_w, patch_h]);

        idx = col - 1;
        if row == 1
            % 第一行：GT + 全图残差
            if idx == 0
                imshow(img_GT_raw);
                hold on;
                rectangle('Position', crop_rect, 'EdgeColor', 'r', 'LineWidth', 1.5);
                t_str = 'GT';
            else
                imagesc(res_maps_full{idx});
                colormap(ax, jet);
                caxis([0, display_limit]);
                t_str = methods{idx};
            end
        else
            % 第二行：GT局部频谱 + 方法局部频谱
            if idx == 0
                imagesc(spec_GT_local);
                colormap(ax, jet);
                t_str = 'Local GT Spectrum';
            else
                imagesc(spec_maps_local{idx});
                colormap(ax, jet);
                t_str = methods{idx};
            end
        end

        axis off;
        axis image;

        if idx == 5
            tt = title(t_str, font_bold{:});
        else
            tt = title(t_str, font_normal{:});
        end

        tt.Units = 'normalized';
        tt.Position(2) = -0.18;
        tt.HorizontalAlignment = 'center';
    end
end

%% 10. 添加 Colorbar
cb = colorbar;
cb.Position = [0.92, 0.15, 0.015, 0.77];
cb.TickLabels = {};
cb.Label.String = 'Residual Strength';
cb.Label.FontName = fontName;
cb.FontSize = 10;

%% 11. 保存主图
main_fig_name = fullfile(save_root, [img_name, '_fft_comparison.png']);
exportgraphics(h_main_fig, main_fig_name, 'Resolution', 600);
fprintf('>>> 主对比图已保存至：%s\n', main_fig_name);

%% 12. 单独保存 Colorbar
h_cb_fig = figure('Visible', 'off', 'Color', 'w', ...
    'Units', 'centimeters', 'Position', [0, 0, 4, 10]);

ax_hidden = axes('Visible', 'off');
colormap(ax_hidden, jet);
caxis(ax_hidden, [0, display_limit]);

cb_only = colorbar(ax_hidden, 'Location', 'west');
cb_only.Label.String = 'Residual Strength';
cb_only.Label.FontName = fontName;
cb_only.Label.FontSize = fontSize;
cb_only.FontSize = 10;

try
    exportgraphics(cb_only, fullfile(save_root, 'colorbar_only.png'), ...
        'Resolution', 300, 'BackgroundColor', 'none');
catch
    set(cb_only, 'Units', 'normalized', 'Position', [0.3, 0.1, 0.2, 0.8]);
    exportgraphics(h_cb_fig, fullfile(save_root, 'colorbar_only.png'), ...
        'Resolution', 300, 'BackgroundColor', 'none');
end

close(h_cb_fig);

fprintf('>>> 单独的 Colorbar 已保存至：%s\n', fullfile(save_root, 'colorbar_only.png'));
fprintf('>>> 所有结果已保存至：%s\n', save_root);
fprintf('>>> 第二行展示的是红框内区域 [%d, %d, %d, %d] 的傅里叶频谱。\n', ...
    crop_rect(1), crop_rect(2), crop_rect(3), crop_rect(4));