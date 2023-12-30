%编写时间：20200524
%函数功能：定位，根据一个百分比，定位数据点在多个Tdms文件中的位置
%输入：value——百分比，范围[0,1]
%输出：fileLocation——定位在某个文件号
%输出：ptLocation——定位在文件的点

function [fileLocation ptLocation] = Location(obj,value)
    totalTime = obj.totalTime;
    sampling = obj.sampling;
    totalNum = sum(obj.filePoints);
    
    location = floor(totalNum * value);
    
    %2023.5.25
    if location > totalNum
        location = totalNum;
    end
    
    if location == 0
        location = 1;
    end
    
    temp = location;
    
    fileLocation = 1;
    ptLocation = 1;

    for iF = 1:obj.fileNum
        t = obj.filePoints(1,iF);
        if temp <= t
            fileLocation = iF;
            ptLocation = temp;
            return;
        else
            temp = temp - t;
        end 
    end
end