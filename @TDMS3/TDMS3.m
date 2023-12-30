classdef TDMS3
    %TDMS3 此处显示有关此类的摘要
    %2023.12.26：增加对txt文件的支持（本文件中主要是添加对txt文件的读取选择功能，要改的主要其余对于tdms各种信息读取的子函数）


    %20200520
    %   此处显示详细说明
    %主要功能
    %1. 不再重复进行跟TDMS文件读取的重复性工作；
    %2. 去除与TMDS读取、以及跟UI相关的操作；功能要精简；
    %3. 为电磁轴承健康估计任务中，对于现有的TDMS文件进行处理，做代码铺垫；

    properties
        %整体信息
        sampling;     %采样率
        %作为文件整体的信息
        date;         %文件日期
        fileNames;    %文件名称，cell格式
        filePath;     %路径
        fileNum;      %文件数目
        matNames;     %mat文件名称
        %单个文件的信息，均为1*N的变量，N为通道数
        channelNames; %各通道名称，包括空数据通道
        channelFlag;  %各通道标志，1为有数据通道，0为无数据通道
        
        totalTime;    %总时间
        filePoints;   %1*fileNum，每个元素为文件点数
        
        sensors;      %传感器标定信息
    end
    
    methods
        function obj = TDMS3(fileName,fileName_temp_1,filepath_temp,tempPara)  %2022.4.13增加第2个参数
            %无变量，对话框读入单个/多个文件
            
            %成员变量初始化
            obj.sampling = 0;
            obj.totalTime = 0;
            obj.date = '1984-01-06 00:00:00';
            obj.channelFlag = [];
            obj.channelNames = [];
            obj.sensors = [];  %2021.6.9添加
            
            try % 如果在执行过程中发生了异常，将直接跳转到 catch 语句块       
                if nargin == 0 % =0：调用文件选择对话框读入文件（nargin中自动包含了函数输入的参数个数）
    %                 [fileName,pathName] = uigetfile({'*.tdms'},'选择.tdms文件');
                    [fileName,filePath] = uigetfile({'*.txt;*.tdms'},'选择文件','MultiSelect','on');
                    % 调用uigetfile()函数，是MATLAB中用于显示标准文件选择对话框（File Open dialog）的函数。它允许用户从文件系统中选择一个或多个文件，并返回所选文件的路径和名称。
                    
                    if isequal(filePath,0)% 如果没选择文件，就将filePath、fileName清空
                       filePath = [];
                       fileName = [];
                    else % 如果选择了文件
                        %单个文件
                        if iscell(fileName) == 0 %检查fileName是否为 cell 数组，只有读入多个文件时，fileName才是一个cell数组，否则是一个字符串
                            obj.fileNames{1,1} = fileName; % 把方法中的局部变量"文件名"传入到全局的类属性（是一个cell）中
                        %多个文件
                        else
                            obj.fileNames = fileName;
                        end
                        obj.filePath = filePath;% 把方法中的局部变量"路径名"传入到全局的类属性（是一个cell）中
                    end
                end
                if nargin == 1 % =1：如果只输入了文件名
                    z = fileName(end); % 读取fileName的最后一位，用于后续的判断
                    %fileName只是路径名
                    if z == '\'
                        obj.filePath = fileName;
                        f = dir([fileName '*.tdms']); % 通过dir，读取这个文件夹下所有的tdms文件
                        if length(f) > 0
                            for iF = 1:length(f)
                                obj.fileNames{1,iF} = f(iF).name;
                            end
                        end
                    %fileName是包含了文件名在内的绝对文件名
                    else
                        s = find(fileName == '\'); 
                        s = s(end);
                        obj.fileNames{1,1} = fileName(s+1:end); % 截取出文件名
                        obj.filePath = fileName(1:s); % 截取出文件路径
                    end               
                end
                %2022.4.13增加默认路径
                if nargin == 2 % =2：如果输入了文件路径fileNam=filePath和
                    [fileName,filePath] = uigetfile([fileName '*txt;*.tdms'],'选择tdms文件','MultiSelect','on'); % 调用文件选择对话框读入文件（默认打开的位置是filePath对于的路径位置）
                    % 后续文件读取过程同 =0
                    if isequal(filePath,0)
                       filePath = [];
                       fileName = [];
                    else
                        %单个文件
                        if iscell(fileName) == 0
                            obj.fileNames{1,1} = fileName;
                        %多个文件
                        else
                            obj.fileNames = fileName;
                        end
                        obj.filePath = filePath;
                    end
                end 
                if nargin == 3 % 循环逐个的人为写入文件名RealTimeData_xxx.tdms文件（xxx代表的文件名中的编号）
                    % 使用for循环，从变量a的值开始，每次加1，直到变量b的值为止
                    fileName_temp_0 = fileName;
                    fileName = {}
                    for i = fileName_temp_0 : fileName_temp_1
                        % 使用num2str函数，将i转换为字符串,并且指定格式为4位，前面用0填充
                        num = num2str(i, '%04d');
                        
                        % 使用strcat函数，将'RealTimeData_00'和num和'.tdms'拼接成一个字符串 'RealTimeData_0027.tdms'
                        str = strcat('RealTimeData_', num, '.tdms');
                        
                        % 使用end+1索引，将str添加到fileName的末尾
                        fileName{end+1} = str;
                    end
                     

                     filePath = filepath_temp;

                    if isequal(filePath,0)
                       filePath = [];
                       fileName = [];
                    else
                        %单个文件
                        if iscell(fileName) == 0
                            obj.fileNames{1,1} = fileName;
                        %多个文件
                        else
                            obj.fileNames = fileName;
                        end
                        obj.filePath = filePath;
                    end
                end
                

                %将第1个文件的信息赋给属性
                obj = TDMSInfo(obj);
                
%                 obj = SensorInfo(obj); 
                
                %20200814，去掉生成mat文件
%                 %如果存在相应的mat文件，则另行不再生成，以节约时间
%                 TDMS2Mat(obj,1);
                for iF = 1:obj.fileNum
                    obj.matNames{1,iF} = [obj.fileNames{1,iF}(1:end-4) 'mat'];
%                     p = load([obj.filePath obj.matNames{1,iF}]);
%                     obj.filePoints(1,iF) = length(p.data);
                end

%                 obj.totalTime =  sum(obj.filePoints)/obj.sampling; 
            catch
                msgbox('文件读入有误！')
            end
        end
        %第0部分：帮助
        Help(obj);        
        
        %第1部分：基本信息
        obj = TDMSInfo(obj);
        TDMS2Mat(obj,mode,fileOrder);                                      %将TDMS数据转换为mat文件，包含info,data两部分
        Slice2Mat(obj,mode,fileNum,chnOrder,val1,val2,saveNames);          %将任意通道、任意长度的数据转化为mat文件
        
        %第2部分：数据操作      
        [data,channelNames] = GetData(obj,fileNum,chn);                    %fileName，chn都可以是多个,针对的是TDMS文件
        [data,mark]= GetSlice(obj,fileNum,chn,stNum,ptNum,flag);           %针对.mat文件，获取数据片段
        [fileLocation,ptLocation] = Location(obj,value);                   %给出一个百分比，定位在文件号和点数
        [fileLocation,ptLocation] = Location2(obj,value);                  %给定一个整数，定位在文件号和点数
        data = WLocation(obj,w1,w2,chn);                                   %给定两个百分比，确定中间的数值
        [w1,w2] = TDMSLocation(obj,fileNum);                               %获取指定TDMS文件号的起始、终止百分比位置
                
        obj = SensorInfo(obj,xlsFile);                                     %从TDMS文件夹中读取Sensor信息，并保留两种方式
        newdata = DataAfterSensor(obj,data);                               %经过传感器标定后的数据
        newdata = DataAfterSensor2(obj,data,chnOrder);                     %任意通道的经过传感器标定后的数据
        [newdata,obj] = SensorData(obj,fileNum,chnOrder);                  %复合函数，直接读取加入传感器标定后的结果,2021.6.8
        
        speed = Trans2Speed(obj,fileNum,chn,plusLength);                   %将脉冲信号转换为转速值
        [locations,fData] = FindFirstFDValue(obj,fileNum,chn,value,sensorOrder,numPts);%在数据中找到大于等于value数值的位置，主要用于查找故障数据
        
        %第3部分：数据处理与分析
        [T,Fs,SPs,channelNames] = WaterFallPlot(obj,fileNum,chns,DrawFlag,figureTitle,Fs); %画瀑布图，20200810修改变量顺序
        LocalWaterFallPlot(obj,data,DrawFlag,figureTitle,Fs);                              %局部数据画瀑布图，2022.7.11
        [fMax,f,A] = FFTPlot(obj,fileNum,chns,DrawFlag);                                   %画FFT图
        [fMax,f,A] = FFTPlot2(obj,data,sp,DrawFlag,fRange);                                %针对任意一段数据
        
        %第4部分：数据显示
        Orbit(obj,chnOrder,numPt,maxLimit);                                %画出轴心轨迹
        PlotX(obj,figType,fileNum,chn,flag);                               %画各种曲线      
    end   
end

