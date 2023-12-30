%Control2�����ڷ���
%20200528
%�������ۿ���ϵͳ���ȶ���
%��ͬ��EvalModel�������pid�������pidģ�ͣ�
%���������
%flag��ʾ�Ƿ�ͼ��0Ϊ����ͼ
%chn��ʾͨ����
%pid��ʾΪ1*5��cell��pidģ��
%flag��1��ʾ��ͼ��0��ʾ����ͼ��2��ʾ��handle�л�ͼ��20210324���ӣ���
%figtype��1Ϊ������2Ϊpid��3Ϊ�����Ⱥ�����4Ϊrotor
%handle����ͼ���
%���������
%resultΪ1*5��cell�����а�����ֵԣ�ȡ����ԣ�ȡ������Ⱥ���

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
    
    
    %����ÿ��ͨ��
    labels = {'X1','Y1','X2','Y2','Z'};
    result = cell(1,5);
    
    for iC = 1:length(chn)
        %��ֵ����
        ch = chn(iC);
        op = obj.rotor{1,ch}*pid{1,ch};  %��chͨ���Ŀ�������
        
        %����Margin
        mg = obj.Margin2(op);

        result{1,ch} = [mg.Af mg.Am; mg.Pf mg.Pm; mg.Sf mg.Sm];
        
        info = ['��ֵԣ�ȣ�  ' num2str(mg.Af) 'Hz' '   ' num2str(mg.Am) 'dB'...
            10 '���ԣ�ȣ�  ' num2str(mg.Pf) 'Hz' '   ' num2str(mg.Pm) '��'...
            10 '�����Ⱥ����� ' num2str(mg.Sf) 'Hz' '   ' num2str(mg.Sm) 'dB'];
        
        %����ͼ����
        bp=bodeoptions;
        bp.FreqUnits='Hz';
        bp.IOGrouping='outputs';
        bp.Grid='on';
        bp.PhaseWrapping ='on';        
        bp.Xlim = [0.1 2000];
        
        switch figType
            case 1
                target = op;
                figName = '�������ݺ���';
            case 2
                target = pid{1,ch};
                figName = '������';
            case 3
                target = 1/(1 + op);
                figName = '�����Ⱥ���';
            case 4
                target = obj.rotor{1,ch};
                figName = 'ת��ģ��';
            case 5
                target = obj.rotor{1,ch}/(1+op);
                figName = '�ջ�ģ��';
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