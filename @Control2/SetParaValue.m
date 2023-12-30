%��дʱ�䣺20210415
%�������ܣ�����ĳһ��������ֵ
%���������
%num����1Ϊparas1��2Ϊparas2
%value��������ֵ,�����Ǿ����������������ֵ
%str�����������ƻ����ǲ������Ƶ�ǰ׺
%chn����ͨ���ţ�ȡֵ1~5

function [obj values paraNames] = SetParaValue(obj,num,value,str,chn)
%     if num == 1     
%         paras = obj.paras1;
%     else
%         paras = obj.paras2;
%     end
%     
%     %�ϳɲ�������
%     if nargin < 5
%         paraName = str;
%     else
%         channel = paras.channels{chn};
%         paraName = [str '_' channel];
%     end
%     
%     %Ѱ�Ҳ����ò���
%     location = strcmp(paraName,paras.names);
%     paras.values(location) = value;
%     
%     if num == 1
%         obj.paras1 = paras;
%     else
%         obj.paras2 = paras;
%     end  

    if num == 1     
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    if iscell(str) == 0
        strNames{1} = str;
    else
        strNames = str;
    end
    
    if nargin < 4
        numChn = 1;
    else
        numChn = length(chn);
    end
    
    numStr = length(strNames);
    
    %�������ǲ�������������ͨ��
    paraNames = cell(numStr,numChn);
    if size(value,1) == numStr & size(value,2) == numChn
        values = value;
    
    %value�ĸ������ڲ������࣬������ͨ������ζ��ͬһ�ֲ�������ͨ������ֵ����ͬ
    elseif length(value) == numStr & length(value) ~= numChn
        value = reshape(value,numStr,1);
        values = value * ones(1,numChn);
    
    %value�ĸ�������ͨ�������������ڲ������࣬��ζ��ͬһ�ֲ�������ͨ������ֵ����ͬ
    elseif length(value) ~= numStr & length(value) == numChn
        value = reshape(value,1,numChn);
        values = ones(numStr,1) * value;
        
    %value�ĸ�������ͨ�������������ڲ������࣬��ζ��ͬһ�ֲ�������ͨ������ֵ����ͬ
    elseif length(value) ~= numStr & length(value) == numChn
        value = reshape(value,1,numChn);
        values = ones(numStr,1) * value;
        
    %value�ĸ�������ͨ��������Ҳ���ڲ������࣬��Ϊ1
    elseif length(value) == numStr & length(value) == numChn & numChn == 1
        values = value;
    
    elseif length(value) == 1
        values = value * ones(numStr,numChn);
        
    %value�ĸ�������ͨ��������Ҳ���ڲ������࣬��Ϊ1
    else
        msgbox('����ֵ���������壡');
        values = 0;
        paraNames = [];
        return
    end
             
    %Ѱ�Ҹ�������������ֵ
    for iS = 1:numStr
        if nargin < 4
            paraName = strNames{iS};
            location = strcmp(paraName,paras.names);
            paras.values(location) = values(iS,1);
            paraNames{iS,1} = paras.names{location};
        else        
            for iC = 1:numChn
                paraName = [strNames{iS} '_' paras.channels{chn(iC)}];
                location = strcmp(paraName,paras.names);
                paras.values(location) = values(iS,iC);
                paraNames{iS,iC} = paras.names{location};
            end
        end
    end
    
    if num == 1
        obj.paras1 = paras;
    else
        obj.paras2 = paras;
    end  
end