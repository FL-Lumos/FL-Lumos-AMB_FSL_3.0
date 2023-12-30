%SensorInfo
%2021.6.29
%�������ܣ���sensor���ַ�ֵ���궨���������ݣ������ַ�ʽ
%��1�ַ�ʽ���ӱ궨�ļ��л�ȡ
%��2�ַ�ʽ���ӿ��Ʋ����л�ȡ������

%20200531
%���������ַ��£���xls�ļ��ж�ȡ��������Sensor_Gain��Sensor_Bias��Ϣ�������ݸ�Sensor��Ա�����У�
%��ʽ1���޲�������ʱ����TDMS·������SensorInfo.csv�ļ�������������ļ�����ΪĬ��ֵ;
%��ʽ2���в�������ʱ��fileNameΪ�ļ���·��+�ļ�����
%xls���ļ���ʽ������Ϊ6*6��ʽ��X1��X2��Y1��Y2��Z��˳��ɱ䣬��5��6�зֱ�ΪSensor_Gain,Sensor_Bias��

function obj = SensorInfo(obj,xlsFile)
    if nargin == 1
        %��ʽ1
%         %���������
%         fileName = [obj.filePath 'SensorInfo.xls'];
%         if exist(fileName,'file') == 2
%             sensor = SensorInfoRead2(fileName);
%         else
%             sensor = [];
%         end  

        %20210508 ��Ϊ�Ի�����룬2021.6.29 ����csv����,2023.5.29 ����txt
        [fileName,filePath] = uigetfile({'*.xls;*.csv;*.txt'},'ѡ�񴫸����궨�ļ����߿��Ʋ���');
        
        %2021.6.18
        xlsFile = [filePath fileName];
%         sensor = SensorInfoRead2();   
%     else
%         %��ʽ2
%         sensor = SensorInfoRead2(xlsFile);
    end

    %2022.4.13 ·��
    if nargin == 2 && xlsFile(end) == '\'
        [fileName,filePath] = uigetfile([xlsFile '*.xls;*.csv;*.txt'],'ѡ�񴫸����궨�ļ����߿��Ʋ���');
        xlsFile = [filePath fileName];
    end
    %2021.6.29 �޸�
    if xlsFile(end) == 's'
        sensorData = GetSensorDataFromXLS(xlsFile);  %��xls��ʽ�Ĵ������궨�ļ���ȡ
    end
    if xlsFile(end) == 'v'
        sensorData = GetSensorDataFromParas(xlsFile);%��csv��ʽ�Ŀ��Ʋ�����ȡ
    end
    %2023.5.29 ����
    if xlsFile(end) == 't'
        sensorData = importdata(xlsFile);%��txt��ʽ�Ŀ��Ʋ�����ȡ
    end
    
    obj.sensors = sensorData;
end

% function sensor = SensorInfoRead(fileName)
%     [a b] = xlsread(fileName);
%     a = a(:,[4 5]);  %�궨����
%     b = b(:,1);  %ͨ����
%     orders1 = {'X1','Y1','X2','Y2','Z'};
%     orders2 = zeros(1,5);
%     for iC = 1:5
%         idx = find(ismember(b,orders1{iC}));
%         orders2(iC) = idx - 1;
%     end    
%     sensor = a(orders2,:); 
% end
% 
% %�����޸ģ�20200810
% function sensorData = SensorInfoRead2(fileName)
%     [data str] = xlsread(fileName);
%     sensorData = data([1:5],[4 5]);
%     tempChn = str([2:6],1);
% 
% %     %2021.5.22 ��xlsread����Ϊreadtable
% %     p = readtable(fileName);
% %     sensorData = p{1:5,5:6};
% %     tempChn = p{1:5,1}
% 
%     %20200728������ͨ��˳��ʹ��������������ͨ��˳��
%     chns = {'X1','Y1','X2','Y2','Z'};  
%     orders = zeros(1,5);
%     for iC = 1:5
%         orders(1,iC) = strmatch(chns{iC},tempChn);
%     end
%     sensorData = sensorData(orders,:);   
%  end





