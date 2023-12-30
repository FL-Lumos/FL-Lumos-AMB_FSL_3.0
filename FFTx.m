%����Ҷ�任20200810
%���룺dataΪ1ά����
%���1��FsΪ������
%���2��fRangeΪƵ����ʾ��Χ

function [fx Ax] = FFTx(data,Fs,fRange)
[fMax f A] = Signal2Speed2(data,Fs);
if nargin == 3
    fx = f(find(f <= fRange));
    Ax = A(find(f <= fRange));
else
    fx = f;
    Ax = A;
end