%Control2类内方法
%时间：2021.6.29
%函数功能：获取控制参数数据值，可以是某一个参数的全称，也可以是某一个组参数所有的通道
%注意的是：为了函数使用的便利性，将Paras1，Paras2的参数num放置到最后一个

%输入：
%paraName——参数名/去掉通道的名称
%channel——数值/通道
%value——数值
%num——1表示paras1,2表示para2
%输出：
%value——控制参数数值
%finalParaNames——对应于value的控制参数名称

%1. 获取指定名称的控制参数值；
%2. 指定参数名和通道数，获取相应的参数值;
%20190606
%输入参数

function [value,finalParaNames] = GetParaValueX(obj,paraName,channel,num)
    %处理判断是Paras1还是paras2
    if nargin < 4
        num = 1;
    end
    if num == 1     
        paraNames = obj.paras1.names;
        values = obj.paras1.values;
        channels = obj.paras1.channels;
    else
        paraNames = obj.paras2.names;
        values = obj.paras2.values;
        channels = obj.paras2.channels;
    end
    
    %对参数名称进行处理
    z = strmatch(paraName,paraNames);
    if isempty(z) == 1
        msgbox('参数名称有误！');
        value = [];
        finalParaNames = [];
        return
    end
    
    tempValues = values(z);
    tempStr = paraNames(z);
    if nargin > 2
        numChn = length(channel);
        value = zeros(numChn,1);
        finalParaNames = cell(numChn,1);
        for iC = 1:numChn
            if paraName(end) ~= '_'
                paraName = [paraName  '_'];
            end
            tempParaName = [paraName channels{channel(iC)}];
            location = strmatch(tempParaName,tempStr);
            if isempty(location) == 1
                msgbox('参数名称不完整！');
                return;
            end
            value(iC) = tempValues(location);
            finalParaNames(iC) = tempStr(location);
        end
    else
        value = tempValues;
        finalParaNames = tempStr;
    end
end