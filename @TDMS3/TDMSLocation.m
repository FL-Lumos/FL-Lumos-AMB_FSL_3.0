%2022.7.6
%TDMS3类
%函数功能：确定TDMS文件的在整个数据中的位置
%w1,w2分别是百分比，fileNum是tdms文件号

function [w1,w2] = TDMSLocation(obj,fileNum)
    if fileNum == 1
        st = 1;
        ed = obj.filePoints(fileNum);
    else
        st = sum(obj.filePoints(1:fileNum-1)) + 1;
        ed = st + obj.filePoints(fileNum);
    end
    w1 = st / sum(obj.filePoints);
    w2 = ed / sum(obj.filePoints);
end