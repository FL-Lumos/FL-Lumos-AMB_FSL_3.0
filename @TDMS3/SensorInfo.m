%SensorInfo
%2021.6.29
%函数功能：给sensor部分幅值，标定传感器数据，有两种方式
%第1种方式：从标定文件中获取
%第2种方式：从控制参数中获取，新增

%20200531
%可以用两种凡事，从xls文件中读取传感器的Sensor_Gain和Sensor_Bias信息，并传递给Sensor成员变量中；
%方式1，无参数传递时，在TDMS路径下找SensorInfo.csv文件，如果不存在文件，则为默认值;
%方式2，有参数传递时，fileName为文件的路径+文件名；
%xls的文件格式，必须为6*6格式，X1，X2，Y1，Y2，Z的顺序可变，第5、6列分别为Sensor_Gain,Sensor_Bias；

function obj = SensorInfo(obj,xlsFile)
    if nargin == 1
        %方式1
%         %如果不存在
%         fileName = [obj.filePath 'SensorInfo.xls'];
%         if exist(fileName,'file') == 2
%             sensor = SensorInfoRead2(fileName);
%         else
%             sensor = [];
%         end  

        %20210508 改为对话框读入，2021.6.29 增加csv读入,2023.5.29 增加txt
        [fileName,filePath] = uigetfile({'*.xls;*.csv;*.txt'},'选择传感器标定文件或者控制参数');
        
        %2021.6.18
        xlsFile = [filePath fileName];
%         sensor = SensorInfoRead2();   
%     else
%         %方式2
%         sensor = SensorInfoRead2(xlsFile);
    end

    %2022.4.13 路径
    if nargin == 2 && xlsFile(end) == '\'
        [fileName,filePath] = uigetfile([xlsFile '*.xls;*.csv;*.txt'],'选择传感器标定文件或者控制参数');
        xlsFile = [filePath fileName];
    end
    %2021.6.29 修改
    if xlsFile(end) == 's'
        sensorData = GetSensorDataFromXLS(xlsFile);  %从xls格式的传感器标定文件读取
    end
    if xlsFile(end) == 'v'
        sensorData = GetSensorDataFromParas(xlsFile);%从csv格式的控制参数读取
    end
    %2023.5.29 增加
    if xlsFile(end) == 't'
        sensorData = importdata(xlsFile);%从txt格式的控制参数读取
    end
    
    obj.sensors = sensorData;
end

% function sensor = SensorInfoRead(fileName)
%     [a b] = xlsread(fileName);
%     a = a(:,[4 5]);  %标定数据
%     b = b(:,1);  %通道名
%     orders1 = {'X1','Y1','X2','Y2','Z'};
%     orders2 = zeros(1,5);
%     for iC = 1:5
%         idx = find(ismember(b,orders1{iC}));
%         orders2(iC) = idx - 1;
%     end    
%     sensor = a(orders2,:); 
% end
% 
% %增加修改，20200810
% function sensorData = SensorInfoRead2(fileName)
%     [data str] = xlsread(fileName);
%     sensorData = data([1:5],[4 5]);
%     tempChn = str([2:6],1);
% 
% %     %2021.5.22 将xlsread更改为readtable
% %     p = readtable(fileName);
% %     sensorData = p{1:5,5:6};
% %     tempChn = p{1:5,1}
% 
%     %20200728，调整通道顺序，使程序适用于所有通道顺序
%     chns = {'X1','Y1','X2','Y2','Z'};  
%     orders = zeros(1,5);
%     for iC = 1:5
%         orders(1,iC) = strmatch(chns{iC},tempChn);
%     end
%     sensorData = sensorData(orders,:);   
%  end





