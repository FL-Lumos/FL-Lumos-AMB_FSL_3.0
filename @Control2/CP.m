%�������ܣ��������Ʋ����еĵ����Ϊ������ͨ�����ر�ɨƵͨ�����رյ�ѹͨ��,������д��ȡClean Parameters����д����
%20190823��20190903����
%���������num����������pid1��pid2��1ΪĬ�ϲ���������Ϊ1��2��
%���������result: flag����1Ϊ���ã�0Ϊ������,str������������

function result = CP(obj,num)
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
        values(d) = 1;
    end
    %S2: ɨƵͨ���Ƿ�ȫ���ر�
    target = [40796:40805];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  'ɨƵͨ��δȫ�����㣡'];
        flag = 0;
        values(d) = 0;
    end
    
    %S3: ��ѹͨ���Ƿ�����
    target = [40751:40760];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  '��ѹ���ͨ��δȫ�����㣡'];
        flag = 0;
        values(d) = 0;
    end
    
    if flag == 1
        str = ['����������ȷ��δ�޸ģ�������д��DSP�У�'];
    else
        str = ['�������ô���'  str '�Ѹ�����']; 
        if num == 1
            obj.paras1.values = values;
            fileName = obj.paras1.file;
        else
            obj.paras2.values = values;
            fileName = obj.paras2.file;
        end
        fileName = [fileName(1:end-4) '_Modified.csv'];
        Save2CSV(obj,fileName,num)
        msgbox(str)
    end
    
    result.flag = flag;
    result.str = str;
end
    