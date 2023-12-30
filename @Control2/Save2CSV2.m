%20210315
%���������浽csv�ļ���ȥ�����н�����д��csv�ļ��У���������ģ�壻��ͬ��Save2CSV��Save2CSV�ǿ������в��������²���д�����С�
%fileName�����Զ���������ƣ�ȱʡʱ����Ϊ���ڣ�Ʃ��20190806140511����ȷ����
%num/paras����ȱʡʱΪ1������Ϊ2����ֻ��Ӧ��paras1,paras2,����Ϊ�ṹ��paras

function Save2CSV2(obj,fileName,num)
    if nargin < 2
        fileName = [datestr(now,'yyyymmddhhMMSS') '.csv'];
    end
    if nargin < 3
        num = 1;
    end
    
    %��3������Ϊparasʱ��Ϊ������������
    if isstruct(num) == 1
        paras = num;
    else 
        if num == 1
            paras = obj.paras1;
        else
            paras = obj.paras2;
        end
    end
    
    pT = table(paras.names,paras.values);
    writetable(pT,fileName,'WriteVariableNames',false);
end