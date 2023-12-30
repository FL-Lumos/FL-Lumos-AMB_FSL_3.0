%经过传感器标定后的数据
%20210508
%将数据转化为传感器标定后的数据
%输入data：必须是m*N的数据
%    chnOrder:
%    sensorOrder:通道顺序是通道顺序是X1,Y1,X2,Y2,Z，需要调整为与data一致，譬如data是2*N的数据，第1个通道是X2，第2个通道是Y2，则chnOrder为[3 4]
%输出newdata：传感器标定后转化的数据

function newdata = DataAfterSensor2(obj,data,sensorOrder)
    sensors = obj.sensors;
    if isempty(sensors) ~= 1
        for iC = 1:length(sensorOrder)
            ch = sensorOrder(iC); 
            data(iC,:) = (data(iC,:) + sensors(ch,2))* (-sensors(ch,1));
        end
    end
    newdata = data;
end