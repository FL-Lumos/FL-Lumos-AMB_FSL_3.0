%编写时间：20190702
%函数功能：从Tdms数据中获取指定通道的数据
%输入变量：
%1. fileNum——obj.fileNames中的序号，默认为1，可以为多个文件，也可以是一个新的文件的名称+路径
%2. chn——指定的通道，默认为全部有数据通道；
%输出变量：
%1. data——chn*N的数据矩阵
%2. channelNames——chn对应的数据名称

function [data channelNames] = GetData(obj,fileNum,chn)
    try
        channelFlag = obj.channelFlag;
        if nargin < 3
            chn = find(channelFlag == 1);
        end

        %flag为1时，从fileNames中提取文件，为0是fileNum即为新的文件名
        if nargin > 1
            %当fileNum为文件名时
            if isstr(fileNum) == 1
                fileNames{1,1} = fileNum;
                fileNum = 1;
                flag = 0;
            %当fileNum为文件号
            else
                flag = 1;
            end
        end
        
        if nargin < 2
            fileNum = 1;
            flag = 1;
        end

        %轮流提取数据
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
                [a,b] = TDMS_readTDMSFile(fileName); %a,b中存有tdms数据的信息
                %channelData channeNames都是cell格式
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
                        msgbox('指定数据通道中存储无数据通道！')
                    end
                end
                data = [data tempData];     
                channelNames = obj.channelNames(1,chn);
            end
        end
    catch
        data = [];
        channelNames = [];
        msgbox('文件数与实际文件不对应！或者通道不在范围内！')
    end
end