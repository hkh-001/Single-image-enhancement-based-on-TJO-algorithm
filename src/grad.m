function out = grad(I)
    % 转换为灰度图像
    if size(I, 3) == 3
        I = rgb2gray(I);
    end
    % 转换为 double 类型
    I = double(I);
    [Gx, Gy] = imgradientxy(I, 'sobel');
    % 计算梯度幅值和方向
    out = sqrt(Gx.^2 + Gy.^2);
end