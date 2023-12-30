%函数作用：在数据中找到大于等于value数值的位置，主要用于查找故障数据
%20210508
%输入：fileNum，TDMS类中对应的TDMS数据序号
%      chns,对应的数据通道
%      value，设定的阈值，大于等于value
%      sensorOrder，为[]不需要经过传感器标定，否则为传感器的通道
%      numPts,连续numPts个点才判断
%      type,默认为1，选择有故障发生，则全部通道均为故障
%输出：location,包括fileNum，chn，在相应的TDMS文件中的点数位置
%例子：[location,fData] = p.FindFirstFDValue([1:4],[2:6],4,[3 4 1 2 5],2)；
%1~4号TMDS文件，第2-6通道数据，阈值是4，通道顺序是第3路数据是X1，第4路是Y1...，连续2个点开始报警

function [location,fData] = FindFirstFDValue(obj,fileNum,chn,value,sensorOrder,numPts)   
    if nargin < 5
        sensorOrder = 0;
    end
    if nargin < 6
        numPts = 1;
    end
    
    [data,channelNames] = GetData(obj,fileNum,chn);
    %转换为传感器标定的数据
    if isempty(sensorOrder) ~= 1
        newData = obj.DataAfterSensor2(data,sensorOrder);
        data = newData;
    end    

    [x,y] = find(data >= value | data <= -value);   %找到故障点
    %规则是只要有一个通道的一个点故障，就算同一时刻都故障
    if isempty(x) ~= 1
        len = size(data,2);
        newData = zeros(1,len);
        newData(1,y) = 1;          %设置故障点的位置为1
        s = conv2(newData,ones(1,numPts));
        
        s = s(1,numPts:numPts + len -1);

        [x1,y1] = find(s >= numPts);
        [z,p] = min(y1);  %第1个大于numPts的位置x1(p),y1(p)
        
        if isempty(p) ~= 1
            [fileLocation,ptLocation] = obj.Location2(z);  
            location = [fileLocation,ptLocation]; 
            fData = data(:,[z:z+numPts-1]);
        else
            location = [];
            fData = [];
        end
    else
        location = [];
        fData = [];
    end

    
    