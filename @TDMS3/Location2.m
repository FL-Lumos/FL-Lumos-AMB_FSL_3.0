%编写时间：20210508
%函数功能：定位，根据定位数据点的点数，定位在某个Tdms文件中的位置
%输入：value——整数，范围[1,总点数]
%输出：fileLocation——定位在某个文件号
%输出：ptLocation——定位在文件的点

function [fileLocation,ptLocation] = Location2(obj,value)    
    for iF = 1:obj.fileNum
        if value <= sum(obj.filePoints(1:iF))
            fileLocation = iF;
            ptLocation = obj.filePoints(1,iF) - (sum(obj.filePoints(1:iF)) - value);
            return
        end
    end
    fileLocation = [];
    ptLocation = [];
end