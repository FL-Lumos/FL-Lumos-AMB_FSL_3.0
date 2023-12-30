%傅里叶变换20200810
%输入：data为1维向量
%输出1：Fs为采样率
%输出2：fRange为频率显示范围

function [fx Ax] = FFTx(data,Fs,fRange)
[fMax f A] = Signal2Speed2(data,Fs);
if nargin == 3
    fx = f(find(f <= fRange));
    Ax = A(find(f <= fRange));
else
    fx = f;
    Ax = A;
end