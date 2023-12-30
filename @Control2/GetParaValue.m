%编写时间：20210415
%函数功能：获取某一个或者多个参数的值，可以用于获取多个参数，多个通道的数值
%输入参数：
%num——1为paras1，2为paras2
%str——参数名称或者是参数名称的前缀，单个参数为字符串，多个参数是以cell格式的形式
%chn——通道号，取值1~5
%返回参数：
%value——参数值，为矩阵形式
%paraName——参数名称，对应于values的格式

function [values,paraNames] = GetParaValue(obj,num,str,chn)
    if num == 1     
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    if iscell(str) == 0
        strNames{1} = str;
    else
        strNames = str;
    end
    
    if nargin < 4
        numChn = 1;
    else
        numChn = length(chn);
    end
    
    numStr = length(strNames);
    
    %纵坐标是参数，横坐标是通道
    values = zeros(numStr,numChn);
    paraNames = cell(numStr,numChn);
    
    %寻找各个参数，并赋值
    for iS = 1:numStr
        if nargin < 4
            paraName = strNames{iS};
            location = strcmp(paraName,paras.names);
            values(iS,1) = paras.values(location);
            paraNames{iS,1} = paras.names{location};
        else        
            for iC = 1:numChn
                paraName = [strNames{iS} '_' paras.channels{chn(iC)}];
                location = strcmp(paraName,paras.names);
                values(iS,iC) = paras.values(location);
                paraNames{iS,iC} = paras.names{location};
            end
        end
    end
end