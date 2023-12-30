%画出任意一段数据的FFT
%20200521
%输入：
%data——数据块，每行代表一路信号；
%sp——采样率，可以由默认的采样率；
%DrawFlag——画图，1为画图，0为不画图；
%fRange——为频率最大显示范围；
%输出
%fMax——每路信号的最大幅值对应的频率；
%f——频率横坐标；
%A——频率对应的幅值；

function [fMax,f,As] = FFTPlot2(obj,data,sp,DrawFlag,fRange)
    if nargin < 4
        DrawFlag = 1;
    end
    if nargin < 3
        WindowWidth = obj.sampling;
    else
        WindowWidth = sp;
    end
    
    cN = size(data,1);
    
    for iC = 1:cN      
        [fMax f A] = Signal2Speed2(data(iC,:),WindowWidth);
        if DrawFlag == 1
            if nargin == 5
                fx = f(find(f <= fRange));
                Ax = A(find(f <= fRange));
            else
                fx = f;
                Ax = A;
            end
            
            figure;
            plot(fx,Ax);
            title(['FFT']);
            grid on
            xlabel('频率（Hz）');ylabel('幅值');
        end
        
        As(iC,:) = A;
        fMaxs(iC,1) = fMax;
    end
    fMax = median(fMaxs);
end