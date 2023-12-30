%编写时间：20210415
%函数功能：设置某一个参数的值
%输入参数：
%num——1为paras1，2为paras2
%value——参数值,可以是矩阵或者向量，单个值
%str——参数名称或者是参数名称的前缀
%chn——通道号，取值1~5

function [obj values paraNames] = SetParaValue(obj,num,value,str,chn)
%     if num == 1     
%         paras = obj.paras1;
%     else
%         paras = obj.paras2;
%     end
%     
%     %合成参数名称
%     if nargin < 5
%         paraName = str;
%     else
%         channel = paras.channels{chn};
%         paraName = [str '_' channel];
%     end
%     
%     %寻找并设置参数
%     location = strcmp(paraName,paras.names);
%     paras.values(location) = value;
%     
%     if num == 1
%         obj.paras1 = paras;
%     else
%         obj.paras2 = paras;
%     end  

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
    paraNames = cell(numStr,numChn);
    if size(value,1) == numStr & size(value,2) == numChn
        values = value;
    
    %value的个数等于参数种类，不等于通道，意味着同一种参数所有通道的数值都相同
    elseif length(value) == numStr & length(value) ~= numChn
        value = reshape(value,numStr,1);
        values = value * ones(1,numChn);
    
    %value的个数等于通道个数，不等于参数种类，意味着同一种参数所有通道的数值都相同
    elseif length(value) ~= numStr & length(value) == numChn
        value = reshape(value,1,numChn);
        values = ones(numStr,1) * value;
        
    %value的个数等于通道个数，不等于参数种类，意味着同一种参数所有通道的数值都相同
    elseif length(value) ~= numStr & length(value) == numChn
        value = reshape(value,1,numChn);
        values = ones(numStr,1) * value;
        
    %value的个数等于通道个数，也等于参数种类，都为1
    elseif length(value) == numStr & length(value) == numChn & numChn == 1
        values = value;
    
    elseif length(value) == 1
        values = value * ones(numStr,numChn);
        
    %value的个数等于通道个数，也等于参数种类，都为1
    else
        msgbox('参数值输入有歧义！');
        values = 0;
        paraNames = [];
        return
    end
             
    %寻找各个参数，并赋值
    for iS = 1:numStr
        if nargin < 4
            paraName = strNames{iS};
            location = strcmp(paraName,paras.names);
            paras.values(location) = values(iS,1);
            paraNames{iS,1} = paras.names{location};
        else        
            for iC = 1:numChn
                paraName = [strNames{iS} '_' paras.channels{chn(iC)}];
                location = strcmp(paraName,paras.names);
                paras.values(location) = values(iS,iC);
                paraNames{iS,iC} = paras.names{location};
            end
        end
    end
    
    if num == 1
        obj.paras1 = paras;
    else
        obj.paras2 = paras;
    end  
end