clear all;clc;close all;warning off;
%% 
addpath(genpath('C:\Users\huang\Desktop\program\program1\strong'));
name = '2092';
image_ori=rgb2ycbcr(imread(strcat(name,'.png')));
[rows, cols, ~] = size(image_ori); 
image_GIF=rgb2ycbcr(imread(strcat(name,'_GIF','.png')));
image_WGIF=rgb2ycbcr(imread(strcat(name,'_WGIF','.png')));
image_GGIF=rgb2ycbcr(imread(strcat(name,'_GGIF','.png')));

image_QWLS=rgb2ycbcr(imread(strcat(name,'_QWLS','.png')));
image_BFLS=rgb2ycbcr(imread(strcat(name,'_BFLS','.png')));
image_ILS=rgb2ycbcr(imread(strcat(name,'_ILS','.png')));
image_TH=rgb2ycbcr(imread(strcat(name,'_TH','.png')));
image_ZF=rgb2ycbcr(imread(strcat(name,'_X2_ZF','.png')));


image_IPRH=rgb2ycbcr(imread(strcat(name,'_IPRH','.png')));

image_CSGIS=rgb2ycbcr(imread(strcat(name,'_x2_CSGIS','.png')));
image_DeepFSPIS=rgb2ycbcr(imread(strcat(name,'_x2_DeepFSPIS','.png')));
if size(image_DeepFSPIS, 1) ~= rows || size(image_DeepFSPIS, 2) ~= cols
    image_DeepFSPIS = image_DeepFSPIS(1:rows, 1:cols, :);
end
image_DIP=rgb2ycbcr(imread(strcat(name,'_X2_DIP','.png')));
image_MGPNet=rgb2ycbcr(imread(strcat(name,'_MGPNet','.png')));
image_WLS=rgb2ycbcr(imread(strcat(name,'_WLS','.png')));
image_PTF=rgb2ycbcr(imread(strcat(name,'_PTF','.png')));

line = 150;  
img_ori_line = double(image_ori(line,:,1));
image_GIF_line = double(image_GIF(line,:,1));
image_WGIF_line = double(image_WGIF(line,:,1));
image_GGIF_line = double(image_GGIF(line,:,1));
image_IPRH_line = double(image_IPRH(line,:,1));
figure('Units', 'centimeters', 'Position', [2, 2, 30, 26]); 
t = tiledlayout(2, 2, 'TileSpacing', 'Compact', 'Padding', 'Compact');

lineWidth_Main = 3;   
lineWidth_Alg = 3;  
markerSize = 10;       
fontSize_Label = 20;
fontSize_Legend = 15;  
fontName_EN = 'Times New Roman'; 

%% ====================  (a) ====================
nexttile;
img= imread(strcat(name,'.png'));
imshow(img); 
hold on;
yline(line, 'Color', 'r', 'LineWidth', 2);
xlabel('BSD200:2092', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
title('(a)The red line marks the source of the 1D profile.', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
axis normal;

%% ====================  (b) ====================
nexttile; 
x = 1:size(img_ori_line,2);

plot(x,img_ori_line,'-o','color','k','MarkerSize',markerSize,'LineWidth',lineWidth_Main,'MarkerFaceColor','k'); hold on;
plot(x,image_GIF_line,'-o','color',[30,144,255]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[30,144,255]./255);
plot(x,image_WGIF_line,'-o','color',[255,215,0]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[255,215,0]./255);
plot(x,image_GGIF_line,'-o','color',[50,205,50]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[50,205,50]./255);
plot(x,image_IPRH_line,'-o','color','r','MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor','r');

axis([163 169 30 123]);
grid on; ax = gca; ax.GridLineStyle = '--'; ax.GridColor = [0.1 0.1 0.1];
set(gca, 'FontName', fontName_EN, 'FontSize', fontSize_Label);

xlabel('Spatial range', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
ylabel('Pixel value', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
title('(b) Comparison with local filters', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');

% legend
legend('GT','GIF','WGIF','GGIF','TJO','Location', 'northwest', 'NumColumns', 3,'FontSize', fontSize_Legend, 'FontName', fontName_EN);

%% =================== (c) ====================
nexttile;
img_ori_line = double(image_ori(line,:,1));
image_QWLS_line = double(image_QWLS(line,:,1));
image_ILS_line = double(image_ILS(line,:,1));
image_BFLS_line = double(image_BFLS(line,:,1));
image_TH_line = double(image_TH(line,:,1));
image_IPRH_line = double(image_IPRH(line,:,1));

plot(x,img_ori_line,'-o','color','k','MarkerSize',markerSize,'LineWidth',lineWidth_Main,'MarkerFaceColor','k'); hold on;
plot(x,image_QWLS_line,'-o','color',[30,144,255]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[30,144,255]./255);
plot(x,image_BFLS_line,'-o','color',[50,205,50]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[50,205,50]./255);
plot(x,image_ILS_line,'-o','color',[255,215,0]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[255,215,0]./255);
plot(x,image_TH_line,'-o','color',[128,42,42]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[128,42,42]./255);
plot(x,image_IPRH_line,'-o','color','r','MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor','r');

axis([163 169 30 123]);
grid on; ax = gca; ax.GridLineStyle = '--'; ax.GridColor = [0.1 0.1 0.1];
set(gca, 'FontName', fontName_EN, 'FontSize', fontSize_Label);

xlabel('Spatial range', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
ylabel('Pixel value', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
title('(c) Comparison with global filters', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');

legend('GT','QWLS','BFLS','ILS','TH','TJO','Location', 'northwest', 'NumColumns', 3,'FontSize', fontSize_Legend, 'FontName', fontName_EN);

%% ==================== (d) ====================
nexttile;
img_ori_line = double(image_ori(line,:,1));
image_DeepFSPIS_line = double(image_DeepFSPIS(line,:,1));
image_DIP_line = double(image_DIP(line,:,1));
image_ZF_line = double(image_ZF(line,:,1));
image_WLS_line = double(image_WLS(line,:,1));
image_IPRH_line = double(image_IPRH(line,:,1));

plot(x,img_ori_line,'-o','color','k','MarkerSize',markerSize,'LineWidth',lineWidth_Main,'MarkerFaceColor','k'); hold on;
plot(x,image_DeepFSPIS_line,'-o','color',[50,205,50]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[50,205,50]./255);
plot(x,image_DIP_line,'-o','color',[128,42,42]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[128,42,42]./255);
plot(x,image_WLS_line,'-o','color',[26, 148, 133]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[26, 148, 133]./255);
plot(x,image_ZF_line,'-o','color',[30,144,255]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[30,144,255]./255);
plot(x,image_IPRH_line,'-o','color','r','MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor','r');

axis([163 169 75 120]);
grid on; 
ax = gca; 
ax.GridLineStyle = '--'; 
ax.GridColor = [0.1 0.1 0.1];
set(gca, 'FontName', fontName_EN, 'FontSize', fontSize_Label);

xlabel('Spatial range', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
ylabel('Pixel value', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');
title('(d) Comparison with learning algorithms', 'FontName', fontName_EN, 'FontSize', fontSize_Label, 'FontWeight', 'normal');

legend('GT','DeepFSPIS','DIP','WLS','ZF','TJO', ...
    'Location', 'northwest', ...
    'NumColumns', 3, ...
    'FontSize', fontSize_Legend, ...
    'FontName', fontName_EN);
% exportgraphics(gcf, 'fig10.pdf', 'ContentType', 'vector');
% exportgraphics(gcf, 'Comparison_Plots.png', 'Resolution', 600);