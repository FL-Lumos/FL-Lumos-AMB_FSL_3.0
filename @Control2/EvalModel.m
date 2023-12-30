%Control2的类内方法
%用于评价开环系统的稳定性
%输入参数：flag表示是否画图，0为不画图
%20190611
%加入灵敏度函数
%20200528

function obj = EvalModel(obj,chn,flag)
    if nargin < 2
        chn = [1 2 3 4 5];
    end
    if nargin < 3
        flag = 1;
    end
    
    %评估每个通道
    labels = {'X1','Y1','X2','Y2','Z'};
    for iC = 1:length(chn)
        %数值评估
        ch = chn(iC);
        op = obj.openlp{1,ch};  %第ch通道的开环对象
        
        %评估Margin
        mg = obj.Margin2(op);
        
%         %评估灵敏度函数
%         st = 1/(1 + op);    
% 
%         f = st.f/(2*pi);                    %横坐标频率值
%         r = st.ResponseData;
%         r = reshape(r,size(f));
%         m = 20*log10(abs(r));      %响应幅值
%         p = angle(r)*180/pi;  %响应相位
%         [maxSt l] = max(m);
%         fSt = f(l);
        
%         obj.stab{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm;fSt maxSt];
%         
%         info = ['幅值裕度：' num2str(mg.Af) 'Hz' ' ' num2str(mg.Am) 'dB;'...
%             10 '相角裕度：' num2str(mg.Pf) 'Hz' ' ' num2str(mg.Pm) '°;'...
%             10 '灵敏度函数最大值：' num2str(fSt) 'Hz' ' ' num2str(maxSt) 'dB;'];
    
%         obj.stab{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm];
%         
%         info = ['幅值裕度：' num2str(mg.Af) 'Hz' ' ' num2str(mg.Am) 'dB;'...
%             10 '相角裕度：' num2str(mg.Pf) 'Hz' ' ' num2str(mg.Pm) '°'];

        obj.stab{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm; mg.Sf mg.Sm];
        
        info = ['幅值裕度：' num2str(mg.Af) 'Hz' ' ' num2str(mg.Am) 'dB;'...
            10 '相角裕度：' num2str(mg.Pf) 'Hz' ' ' num2str(mg.Pm) '°;'...
            10 '灵敏度函数：' num2str(mg.Sf) 'Hz' ' ' num2str(mg.Sm) '°;'];

%         disp(info)
        
        if flag == 1
            %波特图描述
            bp=bodeoptions;
            bp.FreqUnits='Hz';
            bp.IOGrouping='outputs';
            bp.Grid='on';
            bp.PhaseWrapping ='on';        
            bp.Xlim = [0.1 2000];

            figure
    %         subplot(1,2,1)
    %         bodeplot2(op)
            bodeplot(op,bp)
            title([labels{1,ch} ' ' '开环传递函数' 10 info]);

    %         figure
    %         subplot(1,2,2)
    %         bodeplot(st,bp)
    % %         bodeplot2(st)
    %         title([labels{1,ch} ' ' '灵敏度函数']);      
        end
    end
end