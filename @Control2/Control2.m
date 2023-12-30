classdef Control2
    %ControlParas �˴���ʾ�йش����ժҪ
    %�Կ��Ʋ���������Ӧ�Ĳ���
    %   �˴���ʾ��ϸ˵��   
    properties
        paraTemplate;   %����ģ��
        paras1;         %��1�����
        paras2;         %��2�����
        
        %���²�����Ϊcell��ʽ��1*5
        freqs;          %ɨƵ����ģ��
        pid1;           %��1��PIDģ��
        pid2;           %��2��PIDģ��
        rotor;          %ת��ģ��
        rotorX;         %ȫת��ģ�ͣ������˽����20200506
        openlp;         %����ģ��
        stab;           %�ȶ���ָ��
        st;             %�����Ⱥ���
   
%         parasFile;  %���Ʋ�����������·��
%         paras;      %�洢���Ʋ���
%         paraTemplate; %����ģ�塤
    end
    
    methods
        function obj = Control2(parasFile)
            %��1��������޲������룬�����Ի���ѡ�У�
            %��2������������ļ���ȫ·�����ļ�����
            %��3���������������1�����֣���ѡ�ļ��У����Ʋ�����ɨƵ�ļ���
            if nargin == 0
                [fileName,pathName] = uigetfile({'*.csv'},'ѡ����Ʋ����ļ�');
                parasFile = [pathName fileName];
            end
            load('paraTemplate.mat') 
            obj.paraTemplate = paraTemplate;
            
            obj.pid1 = cell(1,5);       %��1��pid
            obj.pid2 = cell(1,5);       %��2��pid
            obj.rotor = cell(1,5);      %ת��ģ��
            obj.rotorX = cell(1,3);     %�����������ת��ģ��
            obj.freqs = cell(1,5);      %�ջ�/ɨƵƵ��ģ��
            obj.openlp = cell(1,5);     %����ģ��
            obj.stab = cell(1,5);       %
            obj.st = cell(1,5);         
            
            flag = 0;
            if nargin == 1 
                if ischar(parasFile) == 0
                    flag = 1;
                    filePath = uigetdir(pwd,'ɨƵ�ļ�·��');
                    filePath = [filePath '\'];
                    files = dir([filePath '*.csv']);
                    fileName = files(1).name;
                    parasFile = [filePath fileName];
                    obj = GetFreqs(obj,filePath);           %��ȡƵ��ģ��

                end
            end
            
            obj = ReadParas(obj,1,parasFile);
            if flag == 1
                obj = GetModel(obj,'rotor');            %��ȡrotorģ��
                obj = GetModel(obj,'open');             %��ȡ����ģ��
            end 
        end
        
        %�����ķ�������Ҫ�޸��ڲ��ĳ�Ա�������ʷ���ֵ�����ö�������obj = fun(obj)
        %��0���֣���������
        Help(obj);                              %�����ļ�
        
        %��1���֡���Ĳ����������ļ���������
        obj = ReadParas(obj,num,paraFile);      %������Ʋ��������Գ�ʼ��paras1����paras2        
        obj = ReadFreqs(obj);                   %����ɨƵ�ļ������Գ�ʼ��freqs

        %��2���֡���ĺ�������ȡģ��
        obj = GetModel(obj,type,num,chn)        %��ȡģ�ͣ�����pid,rotor,open����ģ��      
        obj = GetFreqs(obj,filePath,chnType);   %��ɨƵ�����л�ȡ�ջ�Ƶ��ģ��      
        obj = GetRotor(obj,num,chnType);        %��ȡת��ģ��
        value = GetParaValue2(obj,num,paraName,channel); %��ȡ���Ʋ���ֵ
        obj = GetPID(obj,num,channel);          %��ȡ��ͨ����PIDģ��  
        obj = Refresh(obj,num,values);          %��������,20200528
        
        [value,finalParaNames] = GetParaValueX(obj,paraName,channel,num);  %��ȡĳһ������ĳһ�����
        
        [obj, values, paraNames] = SetParaValue(obj,num,value,str,chn);    %���þ���ĳ����������ֵ��20210415
        [value, name] = GetParaValue(obj,num,str,chn);                    %��ȡ����ĳ����������ֵ��20210415
        
        %��3���֣����浽�����ļ�
        Save2CSV(obj,fileName,num);             %����������CSV�ļ���
        Save2CSV2(obj,fileName,num);
        
        %��4���֣�������ز���
        SP(obj,num);                            %����ɨƵ����
        fileName = Sensor(obj,num,sensorFile);  %���ɴ������궨����Ʋ�����20200417����
        fileName = DrawV(obj,num,v,direction);             %������ѹ������ָ��������������Ʋ���
        fileName = DrawAnyV(obj,num,st);
        result = VF(obj,num);                   %ȷ�Ͽ��Ʋ����Ƿ����д��Ҫ��
        result = CP(obj,num);                   %�����Ʋ�������У�ˣ��������µĿ��Ʋ�����������ͨ����ɨƵͨ������ѹͨ������Ϊ����
        [obj,result] = CP2(obj,num,pr);         %�رտ��Ʋ����е��˲���ͨ����΢������ͨ��
  
        %��5���֡�����Ʋ�����ģ������
        p = Margin2(obj,chn);                   %�󿪻�����ԣ����Ϣ,���������ֵ
        obj = EvalModel2(obj,pid,channel,flag,figType,handle); %����������ģ�� 
        
        %��6���֣���ʾ
        BDPlot(obj,type,channel,titleName);     %������ͬ����Ĳ���ͼ
        BDPlot2(obj,mds,names,titleName);       %������ͬ����Ĳ���ͼ,����ͬһ��ͼ��

        %��������
        obj = Commission(obj,channel);          %����paras2��ͬʱ�����µĲ�����ģ������
        scores = LossFun(obj,num,chn);          %���ۿ��������ܵ���ʧ������Ҳ���������ܵ�����
        obj = Auto(obj,chn);                    %����pid1�Ĳ������Զ�����pid2
        obj = Auto2(obj,chn);                   %�Զ�����pid��������������pid2��   
        obj = Auto3(obj,chns)                   %�Ż�        
    end
end