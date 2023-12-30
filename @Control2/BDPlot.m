%画出不同组件的波特图
%输入参数：type——'rotor'转子模型（开环除去控制器），'open'开环模型，'pid1','pid2'分别对应paras1和paras2，'close'为闭环模型
%20200505:加入titleName
%20190808

function BDPlot(obj,type,channels,titleName)
    chNames = obj.paras1.channels;

    %波特图设置
    bp=bodeoptions;
    bp.FreqUnits='Hz';
    bp.IOGrouping='outputs';
    bp.Grid='on';
    bp.PhaseWrapping ='on'; 
    bp.MagUnits = 'dB';
    bp.Xlim = [0.1 2000];
%     
%     bp.FreqScale = 'linear';
    
    %默认通道为
    if nargin < 3
        channels = [1 2 3 4 5];
    end

    %控制器函数
    if strcmp(type,'pid1') | strcmp(type,'P')
        baseName = '控制器';
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
        baseName = '控制器';
        
        
        for iC = 1:length(channels)
            ch = channels(iC);
            chName = [baseName chNames{ch}];
            tfObj = obj.pid2{ch};
            
            figure('name',chName);
            bp.Title.String = chName;
            
            bodeplot(tfObj,bp)
        end
    end
    
    
    %转子模型
    if strcmp(type,'rotor') | strcmp(type,'R')
        baseName = '转子对象模型';
        
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

    %转子模型交叉项
    if strcmp(type,'rotorX') | strcmp(type,'RX')
        baseName = '转子对象模型';
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
            bp.Title.String = '1端激励，1端响应';
            bodeplot(tfObj(1,1),bp)
            
            subplot(2,2,2)
            bp.Title.String = '2端激励，1端响应';
            bodeplot(tfObj(1,2),bp)
            
            subplot(2,2,3)
            bp.Title.String = '1端激励，2端响应';
            bodeplot(tfObj(2,1),bp)
            
            subplot(2,2,4)
            bp.Title.String = '2端激励，2端响应';
            bodeplot(tfObj(2,2),bp)
        end
    end
      
    %灵敏度函数
    if strcmp(type,'sensitivity') | strcmp(type,'S')
        baseName = '灵敏度函数模型';
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
        
    %开环模型,20191026
    if strcmp(type,'open') | strcmp(type,'O')
        baseName = '开环传递函数';
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