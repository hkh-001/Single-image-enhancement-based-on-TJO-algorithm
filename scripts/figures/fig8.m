function [H0_out, Residual_out] = SMADE2(image)
% SOA1.m (已修改)
% -------------------------------------------------------------------------
% 描述: 
% 此版本已根据论文《海鸥迁徙行为启发的...》中的描述进行了修改。
% 主要改动：
% 1. 采用 (1.4.5) 节 的 "if/else 切换" 机制代替 "平均值"。
% 2. 采用 (1.4.6) 节 的 "弹性反射" 边界约束代替 "钳位"。
% 3. 采用 (1.4.7) 节 的 "个体保留" 精英策略。
% -------------------------------------------------------------------------

    % --- 1. 算法核心参数 ---
    % (这些参数与你论文 3.1.3 节 和你代码 保持一致)
    Search_Agents = 5;   % N: 种群规模
    Max_iterations = 7;  % T_max: 最大迭代次数
    fc = 2;               % f_c (finit=2)
    search_radius = 3;   % 非局部搜索半径
    u = 1;              % 螺旋攻击参数 u
    v = 1;              % 螺旋攻击参数 v
    lambda_g = 0.02;     % 梯度权重
    lambda_t = 0.03;    % 纹理权重
    bilinear_factor = 1.25;% 插值因子
    patch_size = 3;       % 匹配块大小
    aggregation_size = 3; % 聚合窗口大小
    hfs_pad = 20;         % padding 大小
    
    % --- 【修改点】在这里调节切换阈值 ---
    theta_switch = 1;   % 1.4.5 节 定义的切换阈值 (建议范围 0~2)
    % ------------------------

    I0 = image;        
    patch_radius = floor(patch_size / 2);
    aggregation_radius = floor(aggregation_size / 2);

    % --- 1.3 节: 初始残差特征 ---
    L1 = imresize(I0, bilinear_factor, 'bilinear');
    L0 = imresize(L1, size(I0), 'bilinear');
    H0 = I0 - L0; % 这就是初始残差 H0
    
    largeL1 = padarray(L1, [hfs_pad hfs_pad], 'symmetric');
    largeL0 = padarray(L0, [hfs_pad hfs_pad], 'symmetric');
    largeH0 = padarray(H0, [hfs_pad hfs_pad], 'symmetric');
    
    % --- 1.2 节: 特征图 ---
    grad_largeL1 = grad(largeL1);  
    grad_largeL0 = grad(largeL0);  
    texture_largeL1 = texture(largeL1);
    texture_largeL0 = texture(largeL0);
    sumh0 = zeros(size(largeL1));  
    

    [h_large_L1, w_large_L1] = size(sumh0); 
    
    counth0 = zeros(size(largeL1));
    
    [newh1, neww1] = size(L1);   
    [newh1x, neww1x] = size(image);
    coef = newh1x / newh1;        
    dim = 2;
    [h_large, w_large] = size(largeH0); % 这是 读取(Read) 缓冲区的尺寸

    % --- 1.4 节: TJO 核心 ---
    for centerx = 1:newh1    
        for centery = 1:neww1
            p_L1 = largeL1(hfs_pad + centerx - patch_radius : hfs_pad + centerx + patch_radius, ...
                           hfs_pad + centery - patch_radius : hfs_pad + centery + patch_radius);
            p_grad_L1 = grad_largeL1(hfs_pad + centerx - patch_radius : hfs_pad + centerx + patch_radius, ...
                                      hfs_pad + centery - patch_radius : hfs_pad + centery + patch_radius);
            p_texture_L1 = texture_largeL1(hfs_pad + centerx - patch_radius : hfs_pad + centerx + patch_radius, ...
                                            hfs_pad + centery - patch_radius : hfs_pad + centery + patch_radius);
           
            newx = floor(centerx * coef);
            newy = floor(centery * coef);
            
            % 1.4.1 节: 初始化种群
            LB = [max(1, newx - search_radius), max(1, newy - search_radius)];    
            UB = [min(newh1x, newx + search_radius), min(neww1x, newy + search_radius)];
                           
            Positions = LB + (UB - LB) .* rand(Search_Agents, dim);
            Best_Pos = zeros(1, dim); Best_Fit = inf;         
            
            % 为 1.4.7 节的精英保留策略 存储每个个体的旧适应度
            Fit_old = inf(Search_Agents, 1);
            
            for iter = 1:Max_iterations
                
                % --- 1.4.2/1.4.7 (循环 1): 计算当前适应度并找到 Best_Pos ---
                for i = 1:Search_Agents
                    % (移除原代码中的钳位约束，因为 1.4.1 和 1.4.6 已确保位置合法)
                    x = round(Positions(i,1));
                    y = round(Positions(i,2));

                    % (为安全起见，检查边界。如果越界，则不更新 Best_Fit)
                    if x < LB(1) || x > UB(1) || y < LB(2) || y > UB(2)
                        current_fit = inf;
                    else
                        p_L0 = largeL0(hfs_pad + x - patch_radius : hfs_pad + x + patch_radius, ...
                                       hfs_pad + y - patch_radius : hfs_pad + y + patch_radius);
                        p_grad_L0 = grad_largeL0(hfs_pad + x - patch_radius : hfs_pad + x + patch_radius, ...
                                                  hfs_pad + y - patch_radius : hfs_pad + y + patch_radius);
                        p_texture_L0 = texture_largeL0(hfs_pad + x - patch_radius : hfs_pad + x + patch_radius, ...
                                                        hfs_pad + y - patch_radius : hfs_pad + y + patch_radius);
                        
                        % 1.2 节: 复合适应度函数
                        fit_pixel = sum(abs(p_L1(:) - p_L0(:)));
                        fit_grad = sum(abs(p_grad_L1(:) - p_grad_L0(:)));
                        fit_texture = sum(abs(p_texture_L1(:) - p_texture_L0(:)));
                        current_fit = fit_pixel + lambda_g * fit_grad + lambda_t * fit_texture;
                    end
                    
                    Fit_old(i) = current_fit; % 存储旧适应度，用于 1.4.7 节
                                  
                    if current_fit < Best_Fit
                        Best_Fit = current_fit;
                        Best_Pos = Positions(i,:);
                    end
                end
                
                % --- 【核心修改点】---
                % (移除原代码 的 "平均值" 逻辑)
                
                % --- 1.4.3 / 1.4.4 / 1.4.5: 计算新位置 (循环 2) ---
                Fc = fc - iter*(fc/Max_iterations);
                
                % [已修改] theta_switch 已移动到代码开头统一定义，此处直接使用
                
                new_Positions = zeros(size(Positions)); % 缓冲区

                for i = 1:Search_Agents
                    X_it = Positions(i, :);
                    X_it_new = X_it; % 默认为旧位置
                    
                    % --- 1.4.5: 探索与开发的切换机制 ---
                    if Fc > theta_switch % 迭代前期
                        % --- 1.4.3: 全局迁徙 ---
                        A = 2*Fc*rand() - Fc;
                        B = 2*A^2*rand();
                        
                        Mit = B .* (Best_Pos - X_it);
                        Cit = A .* X_it;
                        
                        X_it_new = X_it + (Cit + Mit) .* rand(1, dim);

                    else % 迭代后期
                        % --- 1.4.4: 螺旋攻击 ---
                        k = rand() * 2 * pi; % 论文 定义 k 为 [0, 2pi]
                        R = u * exp(k * v);
                        
                        theta = rand() * 2 * pi; % 论文 定义 theta 为 [0, 2pi]
                        Dx = R * cos(theta);
                        Dy = R * sin(theta);
                        Dattack = [Dx, Dy];
                        
                        X_it_new = Best_Pos + Dattack;
                    end
                    
                    % --- 1.4.6: 边界约束 (弹性反射法) ---
                    for d = 1:dim
                        if X_it_new(d) < LB(d)
                            X_it_new(d) = LB(d) + (LB(d) - X_it_new(d));
                        elseif X_it_new(d) > UB(d)
                            X_it_new(d) = UB(d) - (X_it_new(d) - UB(d));
                        end
                    end
                    % (反射后可能再次越界，使用钳位法兜底)
                    X_it_new = max(min(X_it_new, UB), LB);
                    
                    
                    % --- 1.4.7: 最佳位置保留 (竞争选择) ---
                    % (为新位置计算适应度)
                    x = round(X_it_new(1));
                    y = round(X_it_new(2));

                    p_L0 = largeL0(hfs_pad + x - patch_radius : hfs_pad + x + patch_radius, ...
                                   hfs_pad + y - patch_radius : hfs_pad + y + patch_radius);
                    p_grad_L0 = grad_largeL0(hfs_pad + x - patch_radius : hfs_pad + x + patch_radius, ...
                                              hfs_pad + y - patch_radius : hfs_pad + y + patch_radius);
                    p_texture_L0 = texture_largeL0(hfs_pad + x - patch_radius : hfs_pad + x + patch_radius, ...
                                                    hfs_pad + y - patch_radius : hfs_pad + y + patch_radius);
                    
                    fit_pixel = sum(abs(p_L1(:) - p_L0(:)));
                    fit_grad = sum(abs(p_grad_L1(:) - p_grad_L0(:)));
                    fit_texture = sum(abs(p_texture_L1(:) - p_texture_L0(:)));
                    Fit_new = fit_pixel + lambda_g * fit_grad + lambda_t * fit_texture;
                    
                    % (应用精英保留策略)
                    if Fit_new < Fit_old(i)
                        new_Positions(i, :) = X_it_new; % 接受新位置
                    else
                        new_Positions(i, :) = X_it; % 保留旧位置
                    end
                end
                
                Positions = new_Positions; % 更新种群所有位置
                % --- 结束【核心修改点】---
                
            end 
            
            retrievex = round(Best_Pos(1));
            retrievey = round(Best_Pos(2));
            
            % ---【修改点】鲁棒的聚合边界处理 ---
            % (这部分聚合逻辑 与论文无关，属于工程实现，予以保留)
            agg_x_start_ideal = hfs_pad + retrievex - aggregation_radius;
            agg_x_end_ideal   = hfs_pad + retrievex + aggregation_radius;
            agg_y_start_ideal = hfs_pad + retrievey - aggregation_radius;
            agg_y_end_ideal   = hfs_pad + retrievey + aggregation_radius;
            center_x_start_ideal = hfs_pad + centerx - aggregation_radius;
            center_x_end_ideal   = hfs_pad + centerx + aggregation_radius;
            center_y_start_ideal = hfs_pad + centery - aggregation_radius;
            center_y_end_ideal   = hfs_pad + centery + aggregation_radius;
            
            % (读取边界检查 - 使用 largeH0 的尺寸: h_large, w_large)
            agg_x_start_valid = max(1, agg_x_start_ideal);
            agg_x_end_valid   = min(h_large, agg_x_end_ideal);
            agg_y_start_valid = max(1, agg_y_start_ideal);
            agg_y_end_valid   = min(w_large, agg_y_end_ideal);
            
            % (写入边界检查 - 已被移除，在下面用新的 if 代替)
            % center_x_start_valid = max(1, center_x_start_ideal);
            % center_x_end_valid   = min(h_large, center_x_end_ideal); % <- 错误
            % center_y_start_valid = max(1, center_y_start_ideal);
            % center_y_end_valid   = min(w_large, center_y_end_ideal); % <- 错误
            
            copy_height = agg_x_end_valid - agg_x_start_valid + 1;
            copy_width  = agg_y_end_valid - agg_y_start_valid + 1;
            
            if copy_height > 0 && copy_width > 0
                offset_x_read = agg_x_start_valid - agg_x_start_ideal;
                offset_y_read = agg_y_start_valid - agg_y_start_ideal;
                write_x_start = center_x_start_ideal + offset_x_read;
                write_y_start = center_y_start_ideal + offset_y_read;
                write_x_end = write_x_start + copy_height - 1;
                write_y_end = write_y_start + copy_width - 1;
                
                % 【【【 BUG 2 修复点 2/2 】】】
                % 检查 写入(Write) 坐标是否在 写入缓冲区 (sumh0) 的界限内
                % (使用 h_large_L1 和 w_large_L1)
                if write_x_start >= 1 && write_x_end <= h_large_L1 && ...
                   write_y_start >= 1 && write_y_end <= w_large_L1
                    
                    q_p_H0_valid = double(largeH0(agg_x_start_valid:agg_x_end_valid, agg_y_start_valid:agg_y_end_valid));
                    
                    sumh0(write_x_start:write_x_end, write_y_start:write_y_end) = ...
                        sumh0(write_x_start:write_x_end, write_y_start:write_y_end) + q_p_H0_valid;
                    
                    counth0(write_x_start:write_x_end, write_y_start:write_y_end) = ...
                        counth0(write_x_start:write_x_end, write_y_start:write_y_end) + 1;
                end
            end
            % --- 结束【修改点】---
        end
    end

    % --- 输出结果 ---
    counth0(counth0 == 0) = 1; % 避免除零
    averageh0 = sumh0 ./ counth0;
    
    H0_out = H0; % 初始残差 (第一个返回值)
    
    % 优化后的残差 (第二个返回值)
    Residual_L1_size = averageh0(hfs_pad+1 : end-hfs_pad, hfs_pad+1 : end-hfs_pad);
    if isempty(Residual_L1_size)
         warning('裁剪后的优化残差为空，可能 L1 尺寸过小。');
         Residual_out = zeros(newh1x, neww1x);
    else
         Residual_out = imresize(Residual_L1_size, [newh1x, neww1x], 'bilinear');
    end
end

% --- 辅助函数 ---
% (与 1.2 节 的 ∇(·) 和 T(·) 对应)
function G = grad(img)
    [Gx, Gy] = imgradientxy(img, 'sobel'); G = sqrt(Gx.^2 + Gy.^2);
end
function T = texture(img)
    T = stdfilt(img, ones(3));
end