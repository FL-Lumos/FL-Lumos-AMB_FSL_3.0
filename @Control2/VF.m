%��֤���Ʋ����Ƿ�߱���д��DSP�Ĺ��ܣ�ȡverfication����д����
%20190822
%���������num����1ΪĬ�ϲ���������Ϊ1��2
%���������result: flag����1Ϊ���ã�0Ϊ������,str������������

function result = VF(obj,num)
    %Step0: ����Ԥ��
    if nargin < 2
        num = 1;
    end
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    values = paras.values; %����ֵ
    types = paras.types(:,1);   %����ֵ��Ӧ�Ĳ������͵ĵ�1�У�������ţ���������Ҫ���ڴ˽����ж�
    str = [];
    flag = 1;
    %Step1: ��ȡ��Ҫ��Ϣ�����ж�
    %S1: ����ͨ���Ƿ�ȫ���� 40001-40005
    target = [40001:40005];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if sum(tempValues) ~= 5
        str = [str  '����ͨ��δȫ���򿪣�'];
        flag = 0;
    end
    %S2: ɨƵͨ���Ƿ�ȫ���ر�
    target = [40796:40805];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  'ɨƵͨ��δȫ�����㣡'];
        flag = 0;
    end
    
    %S3: ��ѹͨ���Ƿ�����
    target = [40751:40760];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  '��ѹ���ͨ��δȫ�����㣡'];
        flag = 0;
    end
    
    if isempty(str) == 1
        str = ['����������ȷ��������д��DSP�У�'];
    else
        str = ['�������ô���'  str];
    end
    
    result = struct('flag',flag,'str',str);
    msgbox(str)
end