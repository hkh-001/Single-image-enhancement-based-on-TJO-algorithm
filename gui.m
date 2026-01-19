function gui()
    % 创建GUI窗口
    fig = uifigure('Name', '基于TJO交通堵塞优化的图像细节增强', 'Position', [100 100 1000 600]);

    % 控件设置 - 四个主要按钮
    btnLoad = uibutton(fig, 'push', ...
        'Text', '载入单张图像', ...
        'Position', [30 550 120 30], ...
        'ButtonPushedFcn', @(btn,event) loadSingleImage());

    btnLoadDataset = uibutton(fig, 'push', ...
        'Text', '载入数据集', ...
        'Position', [160 550 120 30], ...
        'ButtonPushedFcn', @(btn,event) loadDataset());

    btnBatchProcess = uibutton(fig, 'push', ...
        'Text', '批量增强处理', ...
        'Position', [290 550 120 30], ...
        'Enable', 'off', ...
        'ButtonPushedFcn', @(btn,event) batchProcess());

    btnSave = uibutton(fig, 'push', ...
        'Text', '保存增强图像', ...
        'Position', [420 550 120 30], ...
        'Enable', 'off', ...
        'ButtonPushedFcn', @(btn,event) saveEnhancedImage());

    % 显示区域
    axOriginal = uiimage(fig, 'Position', [30 200 450 320], 'ScaleMethod', 'fit');
    uilabel(fig, 'Text', '原始图像', 'Position', [200 170 100 20], 'HorizontalAlignment', 'center');
    
    axEnhanced = uiimage(fig, 'Position', [520 200 450 320], 'ScaleMethod', 'fit');
    uilabel(fig, 'Text', 'TJO增强图像', 'Position', [690 170 100 20], 'HorizontalAlignment', 'center');

    % 信息显示区域
    lblPSNR = uilabel(fig, 'Text', 'PSNR: --', 'Position', [520 150 300 20], 'FontWeight', 'bold');
    lblSSIM = uilabel(fig, 'Text', 'SSIM: --', 'Position', [520 120 300 20], 'FontWeight', 'bold');
    
    % 数据集信息显示
    lblDatasetInfo = uilabel(fig, ...
        'Text', '数据集: 未加载', ...
        'Position', [30 150 400 20], ...
        'FontWeight', 'bold', ...
        'FontColor', [0.8 0.2 0.2]);

    % 批量处理结果统计
    lblBatchResults = uilabel(fig, ...
        'Text', '批量处理结果: 未开始', ...
        'Position', [30 120 400 20], ...
        'FontWeight', 'bold', ...
        'FontColor', [0.2 0.6 0.2]);

    lblAlgorithm = uilabel(fig, ...
        'Text', '算法: TJO交通堵塞优化方法优化器', ...
        'Position', [30 80 250 20], ...
        'FontWeight', 'bold', ...
        'FontColor', [0.2 0.4 0.8]);

    % 版权信息
    uilabel(fig, ...
        'Text', 'Copyright@中国矿业大学智能检测与模式识别研究所', ...
        'FontSize', 10, ...
        'Position', [700 570 280 20], ...
        'HorizontalAlignment', 'right', ...
        'FontAngle', 'italic');

    % 变量初始化
    originalImage = [];
    enhancedImage = [];
    datasetPath = '';
    imageFiles = [];
    batchResults = [];
    isDatasetLoaded = false;

    % 单张图像加载函数
    function loadSingleImage()
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tif','图像文件'});
        if isequal(file,0), return; end
        
        imgPath = fullfile(path, file);
        originalImage = imread(imgPath);
        
        % 转换为RGB格式显示
        if size(originalImage,3) == 1
            rgbImage = repmat(originalImage, [1 1 3]);
        else
            rgbImage = originalImage;
        end
        axOriginal.ImageSource = rgbImage;

        % 重置数据集状态
        isDatasetLoaded = false;
        lblDatasetInfo.Text = '数据集: 未加载';
        lblBatchResults.Text = '批量处理结果: 未开始';

        % 进度显示
        d = uiprogressdlg(fig, ...
            'Title', 'TJO算法处理', ...
            'Message', '正在进行多尺度细节增强...');

        % 执行TJO增强
        d.Value = 0.3;
        enhancedImage = tjo_enhance_process(rgbImage);
        
        d.Value = 0.8;
        axEnhanced.ImageSource = enhancedImage;

        % 计算质量指标
        psnrVal = psnr(enhancedImage, rgbImage);
        ssimVal = ssim(enhancedImage, rgbImage);
        
        lblPSNR.Text = sprintf('PSNR: %.2f dB', psnrVal);
        lblSSIM.Text = sprintf('SSIM: %.4f', ssimVal);
        
        btnSave.Enable = 'on';
        
        d.Value = 1.0;
        d.Message = 'TJO增强完成';
        pause(0.5);
        close(d);
    end

    % 数据集加载函数
    function loadDataset()
        try
            datasetPath = uigetdir('', '选择数据集文件夹');
            if isequal(datasetPath, 0)
                return; 
            end
            
            % 搜索支持的图像文件
            supportedFormats = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
            imageFiles = [];
            for i = 1:length(supportedFormats)
                files = dir(fullfile(datasetPath, supportedFormats{i}));
                if ~isempty(files)
                    imageFiles = [imageFiles; files];
                end
            end
            
            if isempty(imageFiles)
                uialert(fig, '在选择的文件夹中未找到支持的图像文件。', '提示');
                return;
            end
            
            % 更新界面状态
            isDatasetLoaded = true;
            lblDatasetInfo.Text = sprintf('数据集: %s (%d 张图像)', datasetPath, length(imageFiles));
            btnBatchProcess.Enable = 'on';
            
            % 显示第一张图像作为预览
            if ~isempty(imageFiles)
                previewImagePath = fullfile(datasetPath, imageFiles(1).name);
                try
                    originalImage = imread(previewImagePath);
                    if size(originalImage,3) == 1
                        rgbImage = repmat(originalImage, [1 1 3]);
                    else
                        rgbImage = originalImage;
                    end
                    axOriginal.ImageSource = rgbImage;
                catch ME
                    uialert(fig, sprintf('预览图像加载失败: %s', ME.message), '错误');
                end
            end
            
            % 清空增强图像显示
            axEnhanced.ImageSource = [];
            lblPSNR.Text = 'PSNR: --';
            lblSSIM.Text = 'SSIM: --';
            
            uialert(fig, sprintf('成功加载数据集！\n共找到 %d 张图像。', length(imageFiles)), '数据集加载完成');
            
        catch ME
            uialert(fig, sprintf('加载数据集时出错: %s', ME.message), '错误');
        end
    end

    % 批量处理函数
    function batchProcess()
        if ~isDatasetLoaded || isempty(imageFiles)
            uialert(fig, '请先载入数据集。', '提示');
            return;
        end
        
        try
            % 创建输出文件夹
            outputFolder = fullfile(datasetPath, '增强图像');
            if ~exist(outputFolder, 'dir')
                mkdir(outputFolder);
            end
            
            % 初始化结果统计
            totalPSNR = 0;
            totalSSIM = 0;
            batchResults = struct();
            batchResults.imageCount = length(imageFiles);
            batchResults.startTime = datetime('now');
            batchResults.details = [];
            
            % 创建进度对话框
            d = uiprogressdlg(fig, ...
                'Title', '批量处理进度', ...
                'Message', '正在初始化批量处理...', ...
                'ShowPercentage', 'on');
            
            % 批量处理每张图像
            processedCount = 0;
            for i = 1:length(imageFiles)
                try
                    % 更新进度
                    d.Message = sprintf('正在处理第 %d/%d 张图像: %s', i, length(imageFiles), imageFiles(i).name);
                    d.Value = i / length(imageFiles);
                    
                    % 读取图像
                    imgPath = fullfile(datasetPath, imageFiles(i).name);
                    originalImg = imread(imgPath);
                    
                    % 转换为RGB格式
                    if size(originalImg,3) == 1
                        rgbImg = repmat(originalImg, [1 1 3]);
                    else
                        rgbImg = originalImg;
                    end
                    
                    % TJO增强处理
                    enhancedImg = tjo_enhance_process(rgbImg);
                    
                    % 计算质量指标
                    psnrVal = psnr(enhancedImg, rgbImg);
                    ssimVal = ssim(enhancedImg, rgbImg);
                    
                    % 累加统计
                    totalPSNR = totalPSNR + psnrVal;
                    totalSSIM = totalSSIM + ssimVal;
                    processedCount = processedCount + 1;
                    
                    % 保存结果到结构体
                    resultDetail = struct();
                    resultDetail.filename = imageFiles(i).name;
                    resultDetail.psnr = psnrVal;
                    resultDetail.ssim = ssimVal;
                    resultDetail.processTime = datetime('now');
                    
                    if i == 1
                        batchResults.details = resultDetail;
                    else
                        batchResults.details(i) = resultDetail;
                    end
                    
                    % 保存增强图像
                    [~, name, ext] = fileparts(imageFiles(i).name);
                    outputFilename = [name '_enhanced' ext];
                    outputPath = fullfile(outputFolder, outputFilename);
                    imwrite(enhancedImg, outputPath);
                    
                    % 更新预览（显示最后处理的图像）
                    if i == length(imageFiles)
                        axOriginal.ImageSource = rgbImg;
                        axEnhanced.ImageSource = enhancedImg;
                        lblPSNR.Text = sprintf('PSNR: %.2f dB', psnrVal);
                        lblSSIM.Text = sprintf('SSIM: %.4f', ssimVal);
                    end
                    
                catch ME
                    uialert(fig, sprintf('处理图像 %s 时出错: %s', imageFiles(i).name, ME.message), '处理错误');
                    continue;
                end
            end
            
            % 计算平均指标
            if processedCount > 0
                avgPSNR = totalPSNR / processedCount;
                avgSSIM = totalSSIM / processedCount;
            else
                avgPSNR = 0;
                avgSSIM = 0;
            end
            
            batchResults.avgPSNR = avgPSNR;
            batchResults.avgSSIM = avgSSIM;
            batchResults.endTime = datetime('now');
            batchResults.totalTime = batchResults.endTime - batchResults.startTime;
            batchResults.processedCount = processedCount;
            
            % 生成处理报告
            generateBatchReport(outputFolder, batchResults);
            
            % 更新界面显示
            lblBatchResults.Text = sprintf('批量处理完成! 平均PSNR: %.2f dB, 平均SSIM: %.4f', avgPSNR, avgSSIM);
            
            close(d);
            uialert(fig, sprintf('批量处理完成！\n共处理 %d/%d 张图像\n平均PSNR: %.2f dB\n平均SSIM: %.4f\n结果保存在: %s', ...
                processedCount, length(imageFiles), avgPSNR, avgSSIM, outputFolder), '批量处理完成');
            
        catch ME
            uialert(fig, sprintf('批量处理过程中出错: %s', ME.message), '错误');
            if exist('d', 'var') && isvalid(d)
                close(d);
            end
        end
    end

    % 生成批量处理报告
    function generateBatchReport(outputFolder, results)
        reportPath = fullfile(outputFolder, '处理报告.txt');
        fid = fopen(reportPath, 'w', 'n', 'UTF-8');
        
        if fid == -1
            uialert(fig, '无法创建处理报告文件。', '错误');
            return;
        end
        
        try
            % 写入报告头部
            fprintf(fid, 'TJO图像增强批量处理报告\n');
            fprintf(fid, '==========================\n\n');
            fprintf(fid, '处理时间: %s\n', char(results.startTime));
            fprintf(fid, '完成时间: %s\n', char(results.endTime));
            fprintf(fid, '总处理时间: %s\n\n', char(results.totalTime));
            fprintf(fid, '总图像数量: %d\n', results.imageCount);
            fprintf(fid, '成功处理: %d\n', results.processedCount);
            fprintf(fid, '处理失败: %d\n\n', results.imageCount - results.processedCount);
            
            fprintf(fid, '总体质量指标:\n');
            fprintf(fid, '平均PSNR: %.2f dB\n', results.avgPSNR);
            fprintf(fid, '平均SSIM: %.4f\n\n', results.avgSSIM);
            
            fprintf(fid, '详细处理结果:\n');
            fprintf(fid, '%-30s %-12s %-12s %-20s\n', '文件名', 'PSNR(dB)', 'SSIM', '处理时间');
            fprintf(fid, '%s\n', repmat('-', 1, 80));
            
            % 写入每张图像的详细结果
            for i = 1:length(results.details)
                detail = results.details(i);
                fprintf(fid, '%-30s %-12.2f %-12.4f %-20s\n', ...
                    detail.filename, detail.psnr, detail.ssim, char(detail.processTime));
            end
            
            fclose(fid);
        catch ME
            fclose(fid);
            uialert(fig, sprintf('生成报告时出错: %s', ME.message), '错误');
        end
    end

    % 保存单张增强图像函数
    function saveEnhancedImage()
        if isempty(enhancedImage)
            uialert(fig, '请先载入图像并处理。', '提示');
            return;
        end
        [file, path] = uiputfile({'*.png','PNG图像'}, '保存增强图像');
        if isequal(file,0), return; end
        imwrite(enhancedImage, fullfile(path, file));
        uialert(fig, '图像保存成功！', '成功');
    end

    % TJO增强处理函数（需要您提供TJO函数的实现）
    function out = tjo_enhance_process(in)
        factor = 4; % tjo增强因子
        
        % 分通道处理
        out1 = double(in(:,:,1));
        out2 = double(in(:,:,2));
        out3 = double(in(:,:,3));
        
        % TJO多尺度细节提取 - 这里需要您提供TJO函数的实现
       
     
            H1_outimg1 = TJO(out1);
            H1_outimg2 = TJO(out2); 
            H1_outimg3 = TJO(out3);
            % 细节融合
        Details = zeros(size(in,1), size(in,2), 3);
        Details(:,:,1) = imresize(H1_outimg1, [size(in,1), size(in,2)], 'bilinear');
        Details(:,:,2) = imresize(H1_outimg2, [size(in,1), size(in,2)], 'bilinear');
        Details(:,:,3) = imresize(H1_outimg3, [size(in,1), size(in,2)], 'bilinear');
        
        % 增强叠加
        out1 = out1 + Details(:,:,1) * factor;
        out2 = out2 + Details(:,:,2) * factor;
        out3 = out3 + Details(:,:,3) * factor;
        
        % 像素值裁剪
        out1 = max(min(out1, 255), 0);
        out2 = max(min(out2, 255), 0);
        out3 = max(min(out3, 255), 0);
        
        out = uint8(cat(3, out1, out2, out3));
    end
end