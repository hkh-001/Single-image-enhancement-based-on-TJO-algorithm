function Residual = TJO(image)
% TJO图像细节增强
    hfs_y1 = 40;  % 搜索窗口
    I0 = image;
    
    % 多尺度图像分解
    L1 = imresize(I0, 1.3, 'bilinear');
    L2 = imresize(L1, size(I0), 'bilinear'); 
    H0 = I0 - L2;

    % 图像填充
    largeL2 = padarray(L2, [hfs_y1, hfs_y1], 'replicate');
    largeL1 = padarray(L1, [hfs_y1, hfs_y1], 'replicate');
    largeH0 = padarray(H0, [hfs_y1, hfs_y1], 'replicate');

    % 特征计算
    grad_largeL1 = grad(largeL1);   
    grad_largeL2 = grad(largeL2);
    texture_largeL1 = texture(largeL1);   
    texture_largeL2 = texture(largeL2);

    sumh0 = zeros(size(largeL1));
    counth0 = zeros(size(largeL1));
    [newh1, neww1] = size(L1);
    [newh1x, neww1x] = size(image);
    coef = newh1x / newh1;
    
    % 采样
    step_size = 2;
    total_blocks = ceil(newh1/step_size) * ceil(neww1/step_size);
    current_block = 0;
    
    for centerx = 1:step_size:newh1
        for centery = 1:step_size:neww1
            current_block = current_block + 1;
            
            % 获取当前参考块5×5
            p_L1 = largeL1(hfs_y1 + centerx - 2:hfs_y1 + centerx + 2, ...
                           hfs_y1 + centery - 2:hfs_y1 + centery + 2);
            p_grad_L1 = grad_largeL1(hfs_y1 + centerx - 2:hfs_y1 + centerx + 2, ...
                                     hfs_y1 + centery - 2:hfs_y1 + centery + 2);
            p_texture_L1 = texture_largeL1(hfs_y1 + centerx - 2:hfs_y1 + centerx + 2, ...
                                           hfs_y1 + centery - 2:hfs_y1 + centery + 2);
            
            % 计算搜索范围
            newx = floor(centerx * coef);  newx(newx<1)=1;
            newy = floor(centery * coef);  newy(newy<1)=1;
            LB = [max(1, newx - 20), max(1, newy - 20)];  % 搜索范围
            UB = [min(size(L2,1), newx + 20), min(size(L2,2), newy + 20)];

            % 使用TJO优化器
            Best_Pos = TJO_optimizer_wrapper(largeL2, grad_largeL2, texture_largeL2, ...
                                           p_L1, p_grad_L1, p_texture_L1, hfs_y1, LB, UB);
            
            retrievex = round(Best_Pos(1));
            retrievey = round(Best_Pos(2));
            
            % 边界检查
            if retrievex < 3 || retrievex > size(L2,1)-2 || retrievey < 3 || retrievey > size(L2,2)-2
                continue;
            end
            
            % 更新高频细节累加器 
            q_p_H0 = double(largeH0(hfs_y1 + retrievex - 2:hfs_y1 + retrievex + 2, ...
                                   hfs_y1 + retrievey - 2:hfs_y1 + retrievey + 2));
            sumh0(hfs_y1 + centerx - 2:hfs_y1 + centerx + 2, ...
                  hfs_y1 + centery - 2:hfs_y1 + centery + 2) = ...
                sumh0(hfs_y1 + centerx - 2:hfs_y1 + centerx + 2, ...
                      hfs_y1 + centery - 2:hfs_y1 + centery + 2) + q_p_H0;
            counth0(hfs_y1 + centerx - 2:hfs_y1 + centerx + 2, ...
                    hfs_y1 + centery - 2:hfs_y1 + centery + 2) = ...
                counth0(hfs_y1 + centerx - 2:hfs_y1 + centerx + 2, ...
                        hfs_y1 + centery - 2:hfs_y1 + centery + 2) + 1;
        end
    end

    counth0(counth0 < 1) = 1;
    averageh0 = sumh0 ./ counth0;
    Residual = averageh0(hfs_y1 + 1:end - hfs_y1, hfs_y1 + 1:end - hfs_y1);
end

% TJO优化器封装函数
function Best_Pos = TJO_optimizer_wrapper(largeL2, grad_largeL2, texture_largeL2, ...
                                        p_L1, p_grad_L1, p_texture_L1, hfs_y1, LB, UB)
    
    % 定义适应度函数 - 与原始PIMO保持一致
    fitness_fun = @(x) block_matching_fitness(x, largeL2, grad_largeL2, texture_largeL2, ...
                                            p_L1, p_grad_L1, p_texture_L1, hfs_y1);
    
    % TJO参数设置 - 调整为适合块匹配问题的参数
   nvars = 2;
   options.CarNum = 8;           % 适中的种群大小
   options.MaxIterations = 15;   % 平衡精度和速度
   options.a = [0.8, 0.1];       % 调整参数范围
   options.c = [0.3, 0.05];      % 调整参数范围
        
    % 运行TJO优化
    [Best_Pos, ~, ~] = TJO_optimizer(fitness_fun, nvars, LB, UB, options);
end

function fitness = block_matching_fitness(pos, largeL2, grad_largeL2, texture_largeL2, ...
                                        p_L1, p_grad_L1, p_texture_L1, hfs_y1)
    
    x = round(pos(1)); 
    y = round(pos(2));
    
    
    original_rows = size(largeL2, 1) - 2 * hfs_y1;
    original_cols = size(largeL2, 2) - 2 * hfs_y1;
    
    % 正确的边界检查 - 检查在原始图像L2中是否能提取完整的5×5块
    if x < 3 || x > original_rows - 2 || ...
       y < 3 || y > original_cols - 2
        fitness = 1e10;  % 使用大数惩罚越界
        return;
    end
    
    try
        % 注意：在填充后的largeL2中提取块时，需要加上hfs_y1偏移
        % 原始坐标(x,y)在largeL2中对应(hfs_y1+x, hfs_y1+y)
        p_L2 = largeL2(hfs_y1 + x - 2 : hfs_y1 + x + 2, ...
                       hfs_y1 + y - 2 : hfs_y1 + y + 2);
        p_grad_L2 = grad_largeL2(hfs_y1 + x - 2 : hfs_y1 + x + 2, ...
                                 hfs_y1 + y - 2 : hfs_y1 + y + 2);
        p_texture_L2 = texture_largeL2(hfs_y1 + x - 2 : hfs_y1 + x + 2, ...
                                       hfs_y1 + y - 2 : hfs_y1 + y + 2);
        
        % 适应度计算
        intensity_diff = mean(abs(p_L1(:) - p_L2(:)));
        grad_diff = 0.001 * mean(abs(p_grad_L1(:) - p_grad_L2(:)));
        texture_diff = 0.001 * mean(abs(p_texture_L1(:) - p_texture_L2(:)));
        
        % 综合适应度
        fitness = intensity_diff + grad_diff + texture_diff;
        
    catch ME
        fitness = 1e10;  % 任何错误都返回大适应度值
    end
end

% TJO优化器核心
function [bestx, bestf, ConvergenceCurve] = TJO_optimizer(fun, nvars, lb, ub, options)

    %% 初始化
    N = options.CarNum;
    T = options.MaxIterations;

    ConvergenceCurve = zeros(1, T);
    
    % 初始化种群
    x = initialization(N, nvars, ub, lb);
    
    % 计算初始适应度
    f = zeros(N, 1);
    for i = 1:N
        f(i) = fun(x(i,:));
    end
    
    [bestf, index] = min(f);
    bestx = x(index,:);
    FlockMemoryF = f;
    FlockMemoryX = x;
    
    % 参数自适应调整
    a = linspace(options.a(1), options.a(2), T);
    c = linspace(options.c(1), options.c(2), T);
    
    %% 主循环
    for t = 1:T
        r = t/T;
        
        % 计算每个驾驶员的最佳位置
        BestX = (1-r).*FlockMemoryX + r.*bestx;
        
        % 驾驶员随机驾驶导致交通拥堵
        y = (1-r)*exp(-r)*sin(2*pi*rand(N,1)).*cos(2*pi*rand(N,1)).*c(t);
        x_new = BestX + y.*((ub-lb).*rand(N,nvars)+lb);
        
        % 驾驶员自我调整
        for i = 1:N
            if rand > 0.5
                x_new(i,:) = x_new(i,:) + c(t)*sin(pi*rand).*(x(randi(N),:) - x_new(i,:));
            else
                x_new(i,:) = x_new(i,:) + c(t)*sin(pi*rand).*(BestX(randi(N),:) - x_new(i,:));
            end
        end
        
        % 交通警察引导驾驶员行驶
        x_new = BestX + a(t)*sin(2*pi*rand(N,1)).*(BestX - x_new);
        
        % 边界处理 - 使用反射边界
        for i = 1:N
            x_new(i,:) = reflective_boundary_check(x_new(i,:), ub, lb);
        end
        
        % 计算适应度
        f_new = zeros(N, 1);
        for i = 1:N
            f_new(i) = fun(x_new(i,:));
        end

        % 更新记忆 - 只接受改进的解
        update_mask = f_new < FlockMemoryF;
        FlockMemoryF(update_mask) = f_new(update_mask);
        FlockMemoryX(update_mask,:) = x_new(update_mask,:);
        
        % 更新当前种群
        x = x_new;
        f = f_new;

        % 更新全局最优
        [current_bestf, idx] = min(f_new);
        if current_bestf < bestf
            bestf = current_bestf;
            bestx = x_new(idx,:);
        end

        % 记录收敛曲线
        ConvergenceCurve(t) = bestf;
    end
end

function new_pos = reflective_boundary_check(pos, UB, LB)
    new_pos = pos;
    dim = length(pos);
    
    for z = 1:dim
        if new_pos(z) < LB(z)
            new_pos(z) = 2 * LB(z) - new_pos(z);
        elseif new_pos(z) > UB(z)
            new_pos(z) = 2 * UB(z) - new_pos(z);
        end
    end
    
    % 确保仍在边界内
    new_pos = max(min(new_pos, UB), LB);
end

% 初始化函数
function X = initialization(N, Dim, UB, LB)
    if numel(UB) == 1
        X = rand(N, Dim) .* (UB - LB) + LB;
    else
        X = zeros(N, Dim);
        for i = 1:Dim
            X(:, i) = rand(N, 1) .* (UB(i) - LB(i)) + LB(i);
        end
    end
end

