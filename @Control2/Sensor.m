%将传感器标定的数值写入到控制参数中
%20190806
%输入参数: num——为1时paras1，为2时paras2，缺省为1

function fileName = Sensor(obj,num,sensorFile)
    if nargin < 2
        num = 1;
    end
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    values = paras.values;
%     types = paras.types;
    names = paras.names;
    
    channels = paras.channels;
    
    %读入到标定数据
    if nargin == 3
        [data str] = xlsread(sensorFile,1);
        s = find(sensorFile == '\');
        pathName = sensorFile(1:s(end));
    else
        [sensorName,pathName] = uigetfile({'*.xls'},'选择传感器标定数据');
        
        sensorFile = [pathName sensorName];
        
        [data str] = xlsread(sensorFile);
    end
    
    %%%
%     sensorData = data([1:5],[4 5]);
% %     sensorData = sensorData([1 3 2 4 5],:);
%     %20200728，调整通道顺序，使程序适用于所有通道顺序
%     chns = {'X1','Y1','X2','Y2','Z'};
%     tempChn = str([2:6],1);
%     orders = zeros(1,5);
%     for iC = 1:5
%         orders(1,iC) = strmatch(chns{iC},tempChn);
%     end
%     sensorData = sensorData(orders,:);
    %%%
    
    %2021.6.18
    sensorData = GetSensorDataFromXLS(sensorFile);
    
    baseName1 = 'sensor_gain_';
    baseName2 = 'sensor_bias_';
    baseName3 = 'op_offset_';
    
    for iC = 1:length(channels)
        channel = channels{iC};
        
        tempName = [baseName1 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = sensorData(iC,1);
        
        tempName = [baseName2 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = sensorData(iC,2); 
        
        tempName = [baseName3 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = 0; 
    end
    
    %提炼出paras的名称
    tempName = paras.file;
    s = find(tempName == '\');
    tempName = tempName(s(end)+1:end-4);
    
    paras.values = values;
    fileName = [pathName tempName '_Sensors' datestr(now,'yyyymmdd') '.csv'];
    obj.Save2CSV(fileName,paras)
end