%20200520
%20200814 将mat格式改为直接从tdms文件中读取
%函数功能：从TDMS文件中获取数据片段，TDMS3类内核心函数
%输入：
%fileNum——数据片段起点的文件号
%chn——数据通道，可以是多个通道号，e.g. [2 3 1 2]
%stNum——起始点数
%ptNum——数据片段点数
%flag——是否跨文件取数据，例如起始位置位于文件的末端，数据片段可能跨越文件
%flag = 0，不跨越文件，若数据点不足，返回剩余片段
%flag = 1, 可跨越文件，直到最后一个文件，则返回剩余片段；
%flag = 2，不跨越文件，若文件点数超出了数据点数，则从最后一个点往前计数ptNum个数据点；
%输出：
%data——返回的数据片段
%mark——数据状态标志
%mark = 0，正常截取片段
%mark = 1，跨越文件取数据
%mark = 2, 从结尾开始计算数据点数
%mark = -1, 数据点数不足ptNum

function [data mark] = GetSlice(obj,fileNum,chn,stNum,ptNum,flag)    %针对.mat文件，获取数据片段   
%     f1 = load([obj.filePath obj.matNames{1,fileNum}]);
    %20200814
    [tempData channelNames] = GetData(obj,fileNum);
    f1.data = tempData;
    f1.info = channelNames;
    
    totalNum = length(f1.data); %文件的总点数
%     totalNum = obj.filePoints(1,fileNum);

    if ptNum > totalNum        
        msgbox('错误：文件总数据点数 小于 设定的单个样本数据点数！');
    end
    
    
    if stNum + ptNum - 1 > totalNum
        switch flag
            case 0
                endNum = totalNum;  %截取剩余片段
                mark = -1;
            case 2
                endNum = totalNum;
                stNum = totalNum - ptNum + 1;  %往前计数
                mark = 2;
            case 1
                %跨文件，但是是最后一个文件
                if fileNum == obj.fileNum
                    endNum = totalNum;  %截取剩余片段
                    mark = -1;               
                %跨文件
                else
                    mark = 1;
                    endNum = ptNum - (totalNum - stNum + 1);
                end   
        end
    else
%         data = f1.data(chn,[stNum:stNum+ptNum-1]);
        endNum = stNum + ptNum - 1;
        mark = 0;
    end
    
    if mark ~= 1
%         [stNum,endNum,length(f1.data)]
        data = f1.data(chn,[stNum:endNum]);
    else
        data1 = f1.data(chn,[stNum:totalNum]);
%         f2 = load([obj.filePath obj.matNames{1,fileNum+1}]);

        %20200814
        [tempData channelNames] = GetData(obj,fileNum);
        f2.data = tempData;
        f2.info = channelNames;
        
        %20200602
        if length(f2.data) >= endNum
            data2 = f2.data(chn,[1:endNum]);
        else
            data2 = f2.data(chn,:);
        end
        data = [data1 data2];
    end
end