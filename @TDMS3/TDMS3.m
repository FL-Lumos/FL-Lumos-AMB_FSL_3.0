classdef TDMS3
    %TDMS3 �˴���ʾ�йش����ժҪ
    %2023.12.26�����Ӷ�txt�ļ���֧�֣����ļ�����Ҫ����Ӷ�txt�ļ��Ķ�ȡѡ���ܣ�Ҫ�ĵ���Ҫ�������tdms������Ϣ��ȡ���Ӻ�����


    %20200520
    %   �˴���ʾ��ϸ˵��
    %��Ҫ����
    %1. �����ظ����и�TDMS�ļ���ȡ���ظ��Թ�����
    %2. ȥ����TMDS��ȡ���Լ���UI��صĲ���������Ҫ����
    %3. Ϊ�����н������������У��������е�TDMS�ļ����д����������̵棻

    properties
        %������Ϣ
        sampling;     %������
        %��Ϊ�ļ��������Ϣ
        date;         %�ļ�����
        fileNames;    %�ļ����ƣ�cell��ʽ
        filePath;     %·��
        fileNum;      %�ļ���Ŀ
        matNames;     %mat�ļ�����
        %�����ļ�����Ϣ����Ϊ1*N�ı�����NΪͨ����
        channelNames; %��ͨ�����ƣ�����������ͨ��
        channelFlag;  %��ͨ����־��1Ϊ������ͨ����0Ϊ������ͨ��
        
        totalTime;    %��ʱ��
        filePoints;   %1*fileNum��ÿ��Ԫ��Ϊ�ļ�����
        
        sensors;      %�������궨��Ϣ
    end
    
    methods
        function obj = TDMS3(fileName,fileName_temp_1,filepath_temp,tempPara)  %2022.4.13���ӵ�2������
            %�ޱ������Ի�����뵥��/����ļ�
            
            %��Ա������ʼ��
            obj.sampling = 0;
            obj.totalTime = 0;
            obj.date = '1984-01-06 00:00:00';
            obj.channelFlag = [];
            obj.channelNames = [];
            obj.sensors = [];  %2021.6.9���
            
            try % �����ִ�й����з������쳣����ֱ����ת�� catch ����       
                if nargin == 0 % =0�������ļ�ѡ��Ի�������ļ���nargin���Զ������˺�������Ĳ���������
    %                 [fileName,pathName] = uigetfile({'*.tdms'},'ѡ��.tdms�ļ�');
                    [fileName,filePath] = uigetfile({'*.txt;*.tdms'},'ѡ���ļ�','MultiSelect','on');
                    % ����uigetfile()��������MATLAB��������ʾ��׼�ļ�ѡ��Ի���File Open dialog���ĺ������������û����ļ�ϵͳ��ѡ��һ�������ļ�����������ѡ�ļ���·�������ơ�
                    
                    if isequal(filePath,0)% ���ûѡ���ļ����ͽ�filePath��fileName���
                       filePath = [];
                       fileName = [];
                    else % ���ѡ�����ļ�
                        %�����ļ�
                        if iscell(fileName) == 0 %���fileName�Ƿ�Ϊ cell ���飬ֻ�ж������ļ�ʱ��fileName����һ��cell���飬������һ���ַ���
                            obj.fileNames{1,1} = fileName; % �ѷ����еľֲ�����"�ļ���"���뵽ȫ�ֵ������ԣ���һ��cell����
                        %����ļ�
                        else
                            obj.fileNames = fileName;
                        end
                        obj.filePath = filePath;% �ѷ����еľֲ�����"·����"���뵽ȫ�ֵ������ԣ���һ��cell����
                    end
                end
                if nargin == 1 % =1�����ֻ�������ļ���
                    z = fileName(end); % ��ȡfileName�����һλ�����ں������ж�
                    %fileNameֻ��·����
                    if z == '\'
                        obj.filePath = fileName;
                        f = dir([fileName '*.tdms']); % ͨ��dir����ȡ����ļ��������е�tdms�ļ�
                        if length(f) > 0
                            for iF = 1:length(f)
                                obj.fileNames{1,iF} = f(iF).name;
                            end
                        end
                    %fileName�ǰ������ļ������ڵľ����ļ���
                    else
                        s = find(fileName == '\'); 
                        s = s(end);
                        obj.fileNames{1,1} = fileName(s+1:end); % ��ȡ���ļ���
                        obj.filePath = fileName(1:s); % ��ȡ���ļ�·��
                    end               
                end
                %2022.4.13����Ĭ��·��
                if nargin == 2 % =2������������ļ�·��fileNam=filePath��
                    [fileName,filePath] = uigetfile([fileName '*txt;*.tdms'],'ѡ��tdms�ļ�','MultiSelect','on'); % �����ļ�ѡ��Ի�������ļ���Ĭ�ϴ򿪵�λ����filePath���ڵ�·��λ�ã�
                    % �����ļ���ȡ����ͬ =0
                    if isequal(filePath,0)
                       filePath = [];
                       fileName = [];
                    else
                        %�����ļ�
                        if iscell(fileName) == 0
                            obj.fileNames{1,1} = fileName;
                        %����ļ�
                        else
                            obj.fileNames = fileName;
                        end
                        obj.filePath = filePath;
                    end
                end 
                if nargin == 3 % ѭ���������Ϊд���ļ���RealTimeData_xxx.tdms�ļ���xxx������ļ����еı�ţ�
                    % ʹ��forѭ�����ӱ���a��ֵ��ʼ��ÿ�μ�1��ֱ������b��ֵΪֹ
                    fileName_temp_0 = fileName;
                    fileName = {}
                    for i = fileName_temp_0 : fileName_temp_1
                        % ʹ��num2str��������iת��Ϊ�ַ���,����ָ����ʽΪ4λ��ǰ����0���
                        num = num2str(i, '%04d');
                        
                        % ʹ��strcat��������'RealTimeData_00'��num��'.tdms'ƴ�ӳ�һ���ַ��� 'RealTimeData_0027.tdms'
                        str = strcat('RealTimeData_', num, '.tdms');
                        
                        % ʹ��end+1��������str��ӵ�fileName��ĩβ
                        fileName{end+1} = str;
                    end
                     

                     filePath = filepath_temp;

                    if isequal(filePath,0)
                       filePath = [];
                       fileName = [];
                    else
                        %�����ļ�
                        if iscell(fileName) == 0
                            obj.fileNames{1,1} = fileName;
                        %����ļ�
                        else
                            obj.fileNames = fileName;
                        end
                        obj.filePath = filePath;
                    end
                end
                

                %����1���ļ�����Ϣ��������
                obj = TDMSInfo(obj);
                
%                 obj = SensorInfo(obj); 
                
                %20200814��ȥ������mat�ļ�
%                 %���������Ӧ��mat�ļ��������в������ɣ��Խ�Լʱ��
%                 TDMS2Mat(obj,1);
                for iF = 1:obj.fileNum
                    obj.matNames{1,iF} = [obj.fileNames{1,iF}(1:end-4) 'mat'];
%                     p = load([obj.filePath obj.matNames{1,iF}]);
%                     obj.filePoints(1,iF) = length(p.data);
                end

%                 obj.totalTime =  sum(obj.filePoints)/obj.sampling; 
            catch
                msgbox('�ļ���������')
            end
        end
        %��0���֣�����
        Help(obj);        
        
        %��1���֣�������Ϣ
        obj = TDMSInfo(obj);
        TDMS2Mat(obj,mode,fileOrder);                                      %��TDMS����ת��Ϊmat�ļ�������info,data������
        Slice2Mat(obj,mode,fileNum,chnOrder,val1,val2,saveNames);          %������ͨ�������ⳤ�ȵ�����ת��Ϊmat�ļ�
        
        %��2���֣����ݲ���      
        [data,channelNames] = GetData(obj,fileNum,chn);                    %fileName��chn�������Ƕ��,��Ե���TDMS�ļ�
        [data,mark]= GetSlice(obj,fileNum,chn,stNum,ptNum,flag);           %���.mat�ļ�����ȡ����Ƭ��
        [fileLocation,ptLocation] = Location(obj,value);                   %����һ���ٷֱȣ���λ���ļ��ź͵���
        [fileLocation,ptLocation] = Location2(obj,value);                  %����һ����������λ���ļ��ź͵���
        data = WLocation(obj,w1,w2,chn);                                   %���������ٷֱȣ�ȷ���м����ֵ
        [w1,w2] = TDMSLocation(obj,fileNum);                               %��ȡָ��TDMS�ļ��ŵ���ʼ����ֹ�ٷֱ�λ��
                
        obj = SensorInfo(obj,xlsFile);                                     %��TDMS�ļ����ж�ȡSensor��Ϣ�����������ַ�ʽ
        newdata = DataAfterSensor(obj,data);                               %�����������궨�������
        newdata = DataAfterSensor2(obj,data,chnOrder);                     %����ͨ���ľ����������궨�������
        [newdata,obj] = SensorData(obj,fileNum,chnOrder);                  %���Ϻ�����ֱ�Ӷ�ȡ���봫�����궨��Ľ��,2021.6.8
        
        speed = Trans2Speed(obj,fileNum,chn,plusLength);                   %�������ź�ת��Ϊת��ֵ
        [locations,fData] = FindFirstFDValue(obj,fileNum,chn,value,sensorOrder,numPts);%���������ҵ����ڵ���value��ֵ��λ�ã���Ҫ���ڲ��ҹ�������
        
        %��3���֣����ݴ��������
        [T,Fs,SPs,channelNames] = WaterFallPlot(obj,fileNum,chns,DrawFlag,figureTitle,Fs); %���ٲ�ͼ��20200810�޸ı���˳��
        LocalWaterFallPlot(obj,data,DrawFlag,figureTitle,Fs);                              %�ֲ����ݻ��ٲ�ͼ��2022.7.11
        [fMax,f,A] = FFTPlot(obj,fileNum,chns,DrawFlag);                                   %��FFTͼ
        [fMax,f,A] = FFTPlot2(obj,data,sp,DrawFlag,fRange);                                %�������һ������
        
        %��4���֣�������ʾ
        Orbit(obj,chnOrder,numPt,maxLimit);                                %�������Ĺ켣
        PlotX(obj,figType,fileNum,chn,flag);                               %����������      
    end   
end

