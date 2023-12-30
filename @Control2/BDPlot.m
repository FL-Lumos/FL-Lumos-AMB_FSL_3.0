%������ͬ����Ĳ���ͼ
%���������type����'rotor'ת��ģ�ͣ�������ȥ����������'open'����ģ�ͣ�'pid1','pid2'�ֱ��Ӧparas1��paras2��'close'Ϊ�ջ�ģ��
%20200505:����titleName
%20190808

function BDPlot(obj,type,channels,titleName)
    chNames = obj.paras1.channels;

    %����ͼ����
    bp=bodeoptions;
    bp.FreqUnits='Hz';
    bp.IOGrouping='outputs';
    bp.Grid='on';
    bp.PhaseWrapping ='on'; 
    bp.MagUnits = 'dB';
    bp.Xlim = [0.1 2000];
%     
%     bp.FreqScale = 'linear';
    
    %Ĭ��ͨ��Ϊ
    if nargin < 3
        channels = [1 2 3 4 5];
    end

    %����������
    if strcmp(type,'pid1') | strcmp(type,'P')
        baseName = '������';
        for iC = 1:length(channels)
            ch = channels(iC);
            chName = [baseName chNames{ch}];
            tfObj = obj.pid1{ch};
            
            figure('name',chName);
            bp.Title.String = chName;
            
            bodeplot(tfObj,bp)
        end
    end
    
    if strcmp(type,'pid2') | strcmp(type,'P2')
        baseName = '������';
        
        
        for iC = 1:length(channels)
            ch = channels(iC);
            chName = [baseName chNames{ch}];
            tfObj = obj.pid2{ch};
            
            figure('name',chName);
            bp.Title.String = chName;
            
            bodeplot(tfObj,bp)
        end
    end
    
    
    %ת��ģ��
    if strcmp(type,'rotor') | strcmp(type,'R')
        baseName = 'ת�Ӷ���ģ��';
        
        for iC = 1:length(channels)
            ch = channels(iC);
            chName = [baseName chNames{ch}];
            
            %20200504
            if nargin == 4
                chName = [titleName '-' chName];
            end
                        
            tfObj = obj.rotor{ch};
            
            figure('name',chName);
            bp.Title.String = chName;
            
            bodeplot(tfObj,bp)
        end
    end

    %ת��ģ�ͽ�����
    if strcmp(type,'rotorX') | strcmp(type,'RX')
        baseName = 'ת�Ӷ���ģ��';
        chNames = {'X','Y'};
        
        %channels = [1,2]
        for iC = 1:length(channels)
            ch = channels(iC);
            chName = [baseName chNames{ch}];
            
            %20200504
            if nargin == 4
                chName = [titleName '-' chName];
            end
                        
            tfObj = obj.rotorX{ch};
            figure('name',chName);
            title(chName)
            subplot(2,2,1)
            bp.Title.String = '1�˼�����1����Ӧ';
            bodeplot(tfObj(1,1),bp)
            
            subplot(2,2,2)
            bp.Title.String = '2�˼�����1����Ӧ';
            bodeplot(tfObj(1,2),bp)
            
            subplot(2,2,3)
            bp.Title.String = '1�˼�����2����Ӧ';
            bodeplot(tfObj(2,1),bp)
            
            subplot(2,2,4)
            bp.Title.String = '2�˼�����2����Ӧ';
            bodeplot(tfObj(2,2),bp)
        end
    end
      
    %�����Ⱥ���
    if strcmp(type,'sensitivity') | strcmp(type,'S')
        baseName = '�����Ⱥ���ģ��';
        for iC = 1:length(channels)
            ch = channels(iC);
            chName = [baseName chNames{ch}];
            
            tempObj = obj.openlp{ch};
            tfObj = 1/(1 + tempObj);
                   
            figure('name',chName);
            bp.Title.String = chName;
            
            bodeplot(tfObj,bp)
        end
    end
        
    %����ģ��,20191026
    if strcmp(type,'open') | strcmp(type,'O')
        baseName = '�������ݺ���';
        for iC = 1:length(channels)
            ch = channels(iC);
            chName = [baseName chNames{ch}];
            tfObj = obj.openlp{ch};
            
            figure('name',chName);
            bp.Title.String = chName;
            
            bodeplot(tfObj,bp)
        end
    end    
end