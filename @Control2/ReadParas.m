%Control2�еĳ�ʼ����������ļ�
%2019-04-25
%����ʱ��Ϊ20190606
%20210415 ���Ӷ��°��������ģ�壩��֧��

function obj = ReadParas(obj,num,parasFile)
%     parasFile = obj.parasFile;
    paraTemplate = obj.paraTemplate;
    if nargin < 3
        parasFile = [];
        if nargin == 1
            num = 1;
        end
    end
    
    %����������parasFile��[]���򵯳��Ի���������
    if isempty(parasFile) == 1
        [fileName,pathName] = uigetfile({'*.csv'},'ѡ����Ʋ����ļ�');
        parasFile = [pathName fileName];  
    end
    
    %���¿��Ʋ����ļ��ж���
    try 
        tempData = importdata(parasFile);
    catch
        return
    end
    
    paraNames = tempData.textdata;
    paraValues = tempData.data;
    
    paraTypes = zeros(length(paraValues),5);
    
    %ΪparaTypes��ֵ
    templateNames = paraTemplate.str(:,1);
    templateTypes = paraTemplate.type;
    paraOrder = zeros(size(paraValues));
    
    
    %20210415 ���Ӷ��°������֧�֣������ж��Ƿ��Ǿɰ����
    num1 = length(paraValues);    %����Ĳ�������
    num2 = length(templateTypes); %�ɰ�ģ��Ĳ�������
    
    if num1 == num2    
        for iT = 1:length(templateNames)
            tempName = paraNames(iT,1);  %ѡȡ���ļ��е�һ������
            paraOrder(iT,1) = strmatch(tempName,templateNames,'exact'); %��ģ����ƥ��
        end

        paraTypes = templateTypes(paraOrder,:); 

        paras.names = paraNames;
        paras.types = paraTypes;
        paras.values = paraValues;
        paras.channels = paraTemplate.channels;
        paras.dataTypes = paraTemplate.dataTypes;
        paras.paraTypes = paraTemplate.paraTypes;
        paras.info = ['namesΪ�������ƣ�' 10 'type�зֱ��ǲ�����š��������͡�ͨ�����͡��������͡�������ţ�' 10 'channelsΪtype�����ֶ�Ӧ��ͨ�����ƣ�' 10 'paraTypesΪtype�����ֶ�Ӧ�Ĳ������ͣ�' 10 'dataTypesΪtype�����ֶ�Ӧ���������ͣ�' 10 'fileΪ�����ļ���·�����ļ���'];
    else
        paras.names = paraNames;
        paras.values = paraValues;
        paras.channels = paraTemplate.channels;
    end
      
    %20190606
    paras.file = parasFile;
    %20190807 ����·��ʶ��
    p1 = find(parasFile == '\');
    if isempty(p1) == 1
        paras.path = [cd '\'];
    else
        p2 = p1(end);
        paras.path = parasFile(1:p2);
    end
    

    %20190606����
    if num == 1
        obj.paras1 = paras;
        obj = GetModel(obj,'pid');
    else
        obj.paras2 = paras;
        obj = GetModel(obj,'pid',2);
    end
%     obj.paras = paras;
end