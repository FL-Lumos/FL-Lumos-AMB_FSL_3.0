%20190806
%���������浽csv�ļ���ȥ
%fileName�����Զ���������ƣ�ȱʡʱ����Ϊ���ڣ�Ʃ��20190806140511����ȷ����
%num/paras����ȱʡʱΪ1������Ϊ2����ֻ��Ӧ��paras1,paras2,����Ϊ�ṹ��paras

function Save2CSV(obj,fileName,num)
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
    
    %��ԭ·���£�����paras1������csv��������ΪfileName
    %�ж�fileName�Ƿ��Ѿ�������·��
    if isempty(find(fileName == ':'))
        fullName = [obj.paras1.path fileName];
    else
        fullName = fileName;
    end
    copyfile(obj.paras1.file,fullName);
    [values names]= xlsread(fullName);
    
    newNames = paras.names;
    newValues = paras.values;
    
    tempValue = zeros(size(values));
    for iN = 1:length(names)
        tempName = names{iN};
        temp = strcmp(tempName,newNames);
        tempLocation = find(temp == 1);
        tempValue(iN,1) = newValues(tempLocation);
    end
    
    xlswrite(fullName,tempValue,1,'B1')
end