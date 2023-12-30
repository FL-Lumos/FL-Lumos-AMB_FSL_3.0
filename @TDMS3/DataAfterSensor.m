%经过传感器标定后的数据
%20200531
%将数据转化为传感器标定后的数据
%输入data：必须是5*N的数据，且通道顺序是X1,Y1,X2,Y2,Z
%输出newdata：传感器标定后转化的数据

function newdata = DataAfterSensor(obj,data)
    sensors = obj.sensors;
    if isempty(sensors) ~= 1
        for iC = 1:5
            data(iC,:) = (data(iC,:) + sensors(iC,2))* (-sensors(iC,1));
        end
    end
    newdata = data;
end