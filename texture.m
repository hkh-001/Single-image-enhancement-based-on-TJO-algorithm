function out = texture(img)  
    % 转换为灰度图像（如果是彩色图）
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end
    % 将图像转换为 double 类型，避免负值截断
    img_gray = double(img_gray);
    % 定义拉普拉斯算子
    laplacian_kernel = [0 -1  0;
                       -1  4 -1;
                        0 -1  0];
    % 使用卷积计算拉普拉斯响应
    out = uint8(conv2(img_gray, laplacian_kernel, 'same'));
end