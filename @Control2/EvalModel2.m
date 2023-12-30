%Control2的类内方法
%20200528
%用于评价开环系统的稳定性
%不同于EvalModel，这里的pid是任意的pid模型；
%输入参数：
%flag表示是否画图，0为不画图
%chn表示通道；
%pid表示为1*5的cell的pid模型
%flag：1表示画图，0表示不画图，2表示在handle中画图（20210324增加）；
%figtype：1为开环，2为pid，3为灵敏度函数，4为rotor
%handle：画图句柄
%输出参数：
%result为1*5的cell，其中包括幅值裕度、相角裕度、灵敏度函数

function result = EvalModel2(obj,pid,chn,flag,figType,handle)
    if nargin < 3
        chn = [1 2 3 4 5];
    end
    if nargin < 4
        flag = 1;
    end
    %20210325
    if nargin < 5
        figType = 1;
    end
    
    
    %评估每个通道
    labels = {'X1','Y1','X2','Y2','Z'};
    result = cell(1,5);
    
    for iC = 1:length(chn)
        %数值评估
        ch = chn(iC);
        op = obj.rotor{1,ch}*pid{1,ch};  %第ch通道的开环对象
        
        %评估Margin
        mg = obj.Margin2(op);

        result{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm; mg.Sf mg.Sm];
        
        info = ['幅值裕度：  ' num2str(mg.Af) 'Hz' '   ' num2str(mg.Am) 'dB'...
            10 '相角裕度：  ' num2str(mg.Pf) 'Hz' '   ' num2str(mg.Pm) '°'...
            10 '灵敏度函数： ' num2str(mg.Sf) 'Hz' '   ' num2str(mg.Sm) 'dB'];
        
        %波特图描述
        bp=bodeoptions;
        bp.FreqUnits='Hz';
        bp.IOGrouping='outputs';
        bp.Grid='on';
        bp.PhaseWrapping ='on';        
        bp.Xlim = [0.1 2000];
        
        switch figType
            case 1
                target = op;
                figName = '开环传递函数';
            case 2
                target = pid{1,ch};
                figName = '控制器';
            case 3
                target = 1/(1 + op);
                figName = '灵敏度函数';
            case 4
                target = obj.rotor{1,ch};
                figName = '转子模型';
            case 5
                target = obj.rotor{1,ch}/(1+op);
                figName = '闭环模型';
        end
 
        if flag == 1
            figure
            bodeplot(gca,target,bp)
            title([labels{1,ch} ' ' figName 10 info],'FontSize',10);  
        elseif flag == 2
            bodeplot(handle,target,bp)
            title([labels{1,ch} ' ' figName 10 info],'FontSize',10);  
        end
            
    end
end