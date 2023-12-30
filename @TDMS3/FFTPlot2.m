%��������һ�����ݵ�FFT
%20200521
%���룺
%data�������ݿ飬ÿ�д���һ·�źţ�
%sp���������ʣ�������Ĭ�ϵĲ����ʣ�
%DrawFlag������ͼ��1Ϊ��ͼ��0Ϊ����ͼ��
%fRange����ΪƵ�������ʾ��Χ��
%���
%fMax����ÿ·�źŵ�����ֵ��Ӧ��Ƶ�ʣ�
%f����Ƶ�ʺ����ꣻ
%A����Ƶ�ʶ�Ӧ�ķ�ֵ��

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
            xlabel('Ƶ�ʣ�Hz��');ylabel('��ֵ');
        end
        
        As(iC,:) = A;
        fMaxs(iC,1) = fMax;
    end
    fMax = median(fMaxs);
end