%从信号中分析出最大幅值的主频,将其对应的频率返回，即转速
%20191226
%20210325 增加输出变量 AMax，即最大主频对应的幅值

function [fMax,f,A,AMax] = Signal2Speed2(signal,Fs)
    th = 0.01;
    N = length(signal);
    NFFT = 2^nextpow2(N); % Next power of 2 from length of y
    Y = fft(signal,NFFT)/N;
    f = Fs/2*linspace(0,1,NFFT/2+1); %频率
    A = 2*abs(Y(1:NFFT/2+1)); %对应的幅值
    
    %20200525,去掉基频
%     [x,y] = max(A);
%     fMax = f(y);
%     [B I]= sort(A,'descend');
    [peaks loc]= findpeaks(A);
    [B  Ix] = sort(peaks,'descend');
    if B(1) < th
        fMax = 0;
        AMax = A(1);
    else
        loc = loc(Ix(1));  
        fMax = f(loc); %peaks代表了幅值最大频率
        AMax = A(loc);
    end

%     if I(1) == 1
%         fMax = f(I(2));
%     else
%         fMax = f(I(1));
%     end
end