%�����������궨�������
%20200531
%������ת��Ϊ�������궨�������
%����data��������5*N�����ݣ���ͨ��˳����X1,Y1,X2,Y2,Z
%���newdata���������궨��ת��������

function newdata = DataAfterSensor(obj,data)
    sensors = obj.sensors;
    if isempty(sensors) ~= 1
        for iC = 1:5
            data(iC,:) = (data(iC,:) + sensors(iC,2))* (-sensors(iC,1));
        end
    end
    newdata = data;
end