%�������ܣ��رղ��������е��˲�����΢�����Σ�
%��CP��ͬ���ǣ�
%20190903
%�������1��num����������pid1��pid2��1ΪĬ�ϲ���������Ϊ1��2��
%�������2��pr�����Ƿ���д�����Ʋ���csv�ļ��У�Ĭ��Ϊ0��0Ϊ����д��1Ϊ��д
%���������result: flag����1Ϊ���ã�0Ϊ������,str������������

function [obj,result] = CP2(obj,num,pr)
    %Step0: ����Ԥ����ֻ���浽��������д�뵽csv��
    %Ĭ����pid1
    if nargin < 2
        num = 1;
    end
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    %Ĭ�ϲ�д��csv�У�ֻ���浽paras��
    if nargin < 3
        pr = 0;
    else
        pr = 1;
    end
    
    %Step1: �ҵ��˲�����΢�����ο��ص�λ��
    values = paras.values; %����ֵ
    names = paras.names;   %������
    n1 = strmatch('active_f',names);   %�˲���λ��
    n2 = strmatch('active_shape_D',names);  %΢������λ��
    n = [n1;n2];   
    
    %Step2������Ӧλ�õ���ֵ��Ϊ0
    if isempty(find(values(n) == 1)) == 1
        result = 0;
    else
        result = 1;
        values(n) = 0;
        paras.values = values;
    end

    if num == 1
        obj.paras1 = paras;
    else
        obj.paras2 = paras;
    end
    
    if pr == 1
        if num == 1
            obj.paras1.values = values;
            fileName = obj.paras1.file;
        else
            obj.paras2.values = values;
            fileName = obj.paras2.file;
        end
        fileName = [fileName(1:end-4) '_Modified.csv'];
        Save2CSV(obj,fileName,num)    
    end
end
    