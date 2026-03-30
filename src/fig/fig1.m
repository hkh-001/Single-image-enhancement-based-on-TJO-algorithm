close all; clear all; clc; warning off; addpath(genpath(pwd))

L0 = randi(10,1,10);
L1 = imresize(L0,1.25,'bilinear');
L2 = imresize(L1,[1,10],'bilinear');
H0 = L0-L2;
num = 1:10;

temp = imresize(L0,[1,12],'bilinear');
Groudtruth = -diff(diff(temp));
TJO = imresize(imresize(Groudtruth,[1,12],'bilinear'),size(Groudtruth),'bicubic');

lineWidth_Main = 3;  
lineWidth_Alg = 3;  
markerSize = 10;      
fontSize_Label = 20;
fontSize_Legend = 15;  
fontName_EN = 'Times New Roman'; 
figure('Color', 'w', 'Position', [300, 300, 800, 600]);

plot(num,L0,'-o','color','k','MarkerSize',markerSize,'LineWidth',lineWidth_Main,'MarkerFaceColor','k'); hold on;
plot(num,L2,'-o','color',[30,144,255]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[30,144,255]./255);
plot(num,H0,'-o','color',[255,215,0]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[255,215,0]./255);
plot(num,Groudtruth,'-o','color',[50,205,50]./255,'MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor',[50,205,50]./255);
plot(num,TJO,'-o','color','r','MarkerSize',markerSize,'LineWidth',lineWidth_Alg,'MarkerFaceColor','r');
hold on; box on; grid on; 

xlabel('Number of sampling point', ...
       'FontSize', 25, ...
       'FontName', 'Times New Roman', ...
       'FontWeight', 'bold');

ylabel('Pixel value', ...
       'FontSize', 25, ...
       'FontName', 'Times New Roman', ...
       'FontWeight', 'bold');

legend('L_0','L_2','H_0','Ground Truth','TJO','Location', 'northwest', 'NumColumns', 1,'FontSize', fontSize_Legend, 'FontName', fontName_EN);

ax = gca;
ax.FontSize = 15;
ax.FontName = 'Times New Roman';
ax.FontWeight = 'bold';
ax.LineWidth = 1.5;      
ax.GridLineStyle = '--'; 
ax.GridAlpha = 0.3;     
set(ax, 'Clipping', 'off');
set(findall(ax, 'Type', 'line'), 'Clipping', 'off');
set(gcf, 'PaperPositionMode', 'auto');
hold off;
% exportgraphics(ax, 'fig3.pdf', 'ContentType', 'vector');
% exportgraphics(ax, 'fig3.png', 'Resolution', 600);
