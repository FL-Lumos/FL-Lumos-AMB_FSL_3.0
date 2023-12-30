%��дʱ�䣺20210415
%�������ܣ���ȡĳһ�����߶��������ֵ���������ڻ�ȡ������������ͨ������ֵ
%���������
%num����1Ϊparas1��2Ϊparas2
%str�����������ƻ����ǲ������Ƶ�ǰ׺����������Ϊ�ַ����������������cell��ʽ����ʽ
%chn����ͨ���ţ�ȡֵ1~5
%���ز�����
%value��������ֵ��Ϊ������ʽ
%paraName�����������ƣ���Ӧ��values�ĸ�ʽ

function [values,paraNames] = GetParaValue(obj,num,str,chn)
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
    values = zeros(numStr,numChn);
    paraNames = cell(numStr,numChn);
    
    %Ѱ�Ҹ�������������ֵ
    for iS = 1:numStr
        if nargin < 4
            paraName = strNames{iS};
            location = strcmp(paraName,paras.names);
            values(iS,1) = paras.values(location);
            paraNames{iS,1} = paras.names{location};
        else        
            for iC = 1:numChn
                paraName = [strNames{iS} '_' paras.channels{chn(iC)}];
                location = strcmp(paraName,paras.names);
                values(iS,iC) = paras.values(location);
                paraNames{iS,iC} = paras.names{location};
            end
        end
    end
end