%2021.6.8
%函数功能：直接生成传感器标定后的数据，并且整合成[X1,Y1,X2,Y2,Z]的通道顺序，该函数是复合函数
%输入：chnOrder,原始数据中[X1,Y1,X2,Y2,Z]对应通道顺序号
%      fileNum,通道序号
%输出：newdata,转换后的数据，顺序为[X1,Y1,X2,Y2,Z]

function [newdata,obj] = SensorData(obj,fileNum,chnOrder)
    if nargin < 3
        chnOrder = [4 5 2 3 6];
    end
    if nargin < 2
        fileNum = [1:obj.fileNum];
    end
    if isempty(obj.sensors) == 1
        obj = obj.SensorInfo();   %读入传感器信息
    end
    data = obj.GetData(fileNum,chnOrder); %获取原始五个通道的数据
    newdata = obj.DataAfterSensor(data);  %把数据转化为标定后的数据
end
