classdef Control2
    %ControlParas 此处显示有关此类的摘要
    %对控制参数进行相应的操作
    %   此处显示详细说明   
    properties
        paraTemplate;   %参数模板
        paras1;         %第1组参数
        paras2;         %第2组参数
        
        %以下参数均为cell格式，1*5
        freqs;          %扫频数据模型
        pid1;           %第1组PID模型
        pid2;           %第2组PID模型
        rotor;          %转子模型
        rotorX;         %全转子模型，包括了交叉项；20200506
        openlp;         %开环模型
        stab;           %稳定性指标
        st;             %灵敏度函数
   
%         parasFile;  %控制参数名，包括路径
%         paras;      %存储控制参数
%         paraTemplate; %参数模板·
    end
    
    methods
        function obj = Control2(parasFile)
            %第1种情况，无参数输入，弹出对话框选中；
            %第2种情况，输入文件的全路径和文件名；
            %第3种情况，输入任意1个数字，点选文件夹，控制参数与扫频文件；
            if nargin == 0
                [fileName,pathName] = uigetfile({'*.csv'},'选择控制参数文件');
                parasFile = [pathName fileName];
            end
            load('paraTemplate.mat') 
            obj.paraTemplate = paraTemplate;
            
            obj.pid1 = cell(1,5);       %第1个pid
            obj.pid2 = cell(1,5);       %第2个pid
            obj.rotor = cell(1,5);      %转子模型
            obj.rotorX = cell(1,3);     %包括交叉项的转子模型
            obj.freqs = cell(1,5);      %闭环/扫频频率模型
            obj.openlp = cell(1,5);     %开环模型
            obj.stab = cell(1,5);       %
            obj.st = cell(1,5);         
            
            flag = 0;
            if nargin == 1 
                if ischar(parasFile) == 0
                    flag = 1;
                    filePath = uigetdir(pwd,'扫频文件路径');
                    filePath = [filePath '\'];
                    files = dir([filePath '*.csv']);
                    fileName = files(1).name;
                    parasFile = [filePath fileName];
                    obj = GetFreqs(obj,filePath);           %获取频率模型

                end
            end
            
            obj = ReadParas(obj,1,parasFile);
            if flag == 1
                obj = GetModel(obj,'rotor');            %获取rotor模型
                obj = GetModel(obj,'open');             %获取开环模型
            end 
        end
        
        %加入★的方法，需要修改内部的成员变量，故返回值必须用对象，例如obj = fun(obj)
        %第0部分：帮助函数
        Help(obj);                              %帮助文件
        
        %第1部分★：核心操作，读入文件基本操作
        obj = ReadParas(obj,num,paraFile);      %读入控制参数，可以初始化paras1或者paras2        
        obj = ReadFreqs(obj);                   %读入扫频文件，可以初始化freqs

        %第2部分★：核心函数，获取模型
        obj = GetModel(obj,type,num,chn)        %获取模型，包括pid,rotor,open三类模型      
        obj = GetFreqs(obj,filePath,chnType);   %从扫频数据中获取闭环频率模型      
        obj = GetRotor(obj,num,chnType);        %获取转子模型
        value = GetParaValue2(obj,num,paraName,channel); %获取控制参数值
        obj = GetPID(obj,num,channel);          %获取单通道的PID模型  
        obj = Refresh(obj,num,values);          %参数更新,20200528
        
        [value,finalParaNames] = GetParaValueX(obj,paraName,channel,num);  %获取某一个或者某一组参数
        
        [obj, values, paraNames] = SetParaValue(obj,num,value,str,chn);    %设置具体某个参数的数值，20210415
        [value, name] = GetParaValue(obj,num,str,chn);                    %获取具体某个参数的数值，20210415
        
        %第3部分：保存到参数文件
        Save2CSV(obj,fileName,num);             %将参数保存CSV文件中
        Save2CSV2(obj,fileName,num);
        
        %第4部分：调试相关操作
        SP(obj,num);                            %生成扫频参数
        fileName = Sensor(obj,num,sensorFile);  %生成传感器标定后控制参数，20200417更新
        fileName = DrawV(obj,num,v,direction);             %给定电压，生成指定方向的吸引控制参数
        fileName = DrawAnyV(obj,num,st);
        result = VF(obj,num);                   %确认控制参数是否符合写入要求
        result = CP(obj,num);                   %将控制参数进行校核，并生成新的控制参数，将悬浮通道，扫频通道，电压通道设置为正常
        [obj,result] = CP2(obj,num,pr);         %关闭控制参数中的滤波器通道，微分整形通道
  
        %第5部分★：求解控制参数，模型评价
        p = Margin2(obj,chn);                   %求开环函数裕度信息,灵敏度最大值
        obj = EvalModel2(obj,pid,channel,flag,figType,handle); %★评估开环模型 
        
        %第6部分：显示
        BDPlot(obj,type,channel,titleName);     %画出不同组件的波特图
        BDPlot2(obj,mds,names,titleName);       %画出不同组件的波特图,画在同一个图上

        %其他操作
        obj = Commission(obj,channel);          %调试paras2，同时生成新的参数和模型评价
        scores = LossFun(obj,num,chn);          %评价控制器性能的损失函数，也是评价性能的依据
        obj = Auto(obj,chn);                    %基于pid1的参数，自动计算pid2
        obj = Auto2(obj,chn);                   %自动计算pid参数，并保存在pid2中   
        obj = Auto3(obj,chns)                   %优化        
    end
end