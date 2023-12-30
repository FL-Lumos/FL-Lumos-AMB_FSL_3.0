%Control2�����ڷ���
%�������ۿ���ϵͳ���ȶ���
%���������flag��ʾ�Ƿ�ͼ��0Ϊ����ͼ
%20190611
%���������Ⱥ���
%20200528

function obj = EvalModel(obj,chn,flag)
    if nargin < 2
        chn = [1 2 3 4 5];
    end
    if nargin < 3
        flag = 1;
    end
    
    %����ÿ��ͨ��
    labels = {'X1','Y1','X2','Y2','Z'};
    for iC = 1:length(chn)
        %��ֵ����
        ch = chn(iC);
        op = obj.openlp{1,ch};  %��chͨ���Ŀ�������
        
        %����Margin
        mg = obj.Margin2(op);
        
%         %���������Ⱥ���
%         st = 1/(1 + op);    
% 
%         f = st.f/(2*pi);                    %������Ƶ��ֵ
%         r = st.ResponseData;
%         r = reshape(r,size(f));
%         m = 20*log10(abs(r));      %��Ӧ��ֵ
%         p = angle(r)*180/pi;  %��Ӧ��λ
%         [maxSt l] = max(m);
%         fSt = f(l);
        
%         obj.stab{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm;fSt maxSt];
%         
%         info = ['��ֵԣ�ȣ�' num2str(mg.Af) 'Hz' ' ' num2str(mg.Am) 'dB;'...
%             10 '���ԣ�ȣ�' num2str(mg.Pf) 'Hz' ' ' num2str(mg.Pm) '��;'...
%             10 '�����Ⱥ������ֵ��' num2str(fSt) 'Hz' ' ' num2str(maxSt) 'dB;'];
    
%         obj.stab{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm];
%         
%         info = ['��ֵԣ�ȣ�' num2str(mg.Af) 'Hz' ' ' num2str(mg.Am) 'dB;'...
%             10 '���ԣ�ȣ�' num2str(mg.Pf) 'Hz' ' ' num2str(mg.Pm) '��'];

        obj.stab{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm; mg.Sf mg.Sm];
        
        info = ['��ֵԣ�ȣ�' num2str(mg.Af) 'Hz' ' ' num2str(mg.Am) 'dB;'...
            10 '���ԣ�ȣ�' num2str(mg.Pf) 'Hz' ' ' num2str(mg.Pm) '��;'...
            10 '�����Ⱥ�����' num2str(mg.Sf) 'Hz' ' ' num2str(mg.Sm) '��;'];

%         disp(info)
        
        if flag == 1
            %����ͼ����
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
            title([labels{1,ch} ' ' '�������ݺ���' 10 info]);

    %         figure
    %         subplot(1,2,2)
    %         bodeplot(st,bp)
    % %         bodeplot2(st)
    %         title([labels{1,ch} ' ' '�����Ⱥ���']);      
        end
    end
end