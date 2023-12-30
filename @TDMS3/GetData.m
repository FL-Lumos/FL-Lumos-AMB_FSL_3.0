%��дʱ�䣺20190702
%�������ܣ���Tdms�����л�ȡָ��ͨ��������
%���������
%1. fileNum����obj.fileNames�е���ţ�Ĭ��Ϊ1������Ϊ����ļ���Ҳ������һ���µ��ļ�������+·��
%2. chn����ָ����ͨ����Ĭ��Ϊȫ��������ͨ����
%���������
%1. data����chn*N�����ݾ���
%2. channelNames����chn��Ӧ����������

function [data channelNames] = GetData(obj,fileNum,chn)
    try
        channelFlag = obj.channelFlag;
        if nargin < 3
            chn = find(channelFlag == 1);
        end

        %flagΪ1ʱ����fileNames����ȡ�ļ���Ϊ0��fileNum��Ϊ�µ��ļ���
        if nargin > 1
            %��fileNumΪ�ļ���ʱ
            if isstr(fileNum) == 1
                fileNames{1,1} = fileNum;
                fileNum = 1;
                flag = 0;
            %��fileNumΪ�ļ���
            else
                flag = 1;
            end
        end
        
        if nargin < 2
            fileNum = 1;
            flag = 1;
        end

        %������ȡ����
        data = [];
        for iF = 1:length(fileNum)
            if flag == 1
                fileName = obj.fileNames{1,fileNum(iF)};
                filePath = obj.filePath;
                fileName = [filePath fileName];
            else
                fileName = fileNames{1,1};
            end
                
            tempData = [];
            if fileName(end-2:end) == 'dms'
                [a,b] = TDMS_readTDMSFile(fileName); %a,b�д���tdms���ݵ���Ϣ
                %channelData channeNames����cell��ʽ
                [channelData channelNames2] = TDMS_readChannelOrGroup(fileName,a.groupNames);
            elseif fileName(end-2:end) == 'txt'
                [channelData channelNames2] = TXT_readChannelOrGroup(fileName);
            else

            end

            if flag == 0
                num = length(channelData);
                channels = zeros(1,num);
%                 channelNames = cell(1,num);
                for iC = 1:num
                    tempData = channelData{1,iC};
                    if isempty(tempData) ~= 1
                        channels(1,iC) = 1;
                        data = [data;tempData];
                    end
                end   
                channelNames = channelNames2(1,find(channels == 1));
            else
                for iC = 1:length(chn)
                    ch = chn(iC);

                    if channelFlag(ch) == 1
                        tempData = [tempData;channelData{1,ch}];
                    else
                        msgbox('ָ������ͨ���д洢������ͨ����')
                    end
                end
                data = [data tempData];     
                channelNames = obj.channelNames(1,chn);
            end
        end
    catch
        data = [];
        channelNames = [];
        msgbox('�ļ�����ʵ���ļ�����Ӧ������ͨ�����ڷ�Χ�ڣ�')
    end
end