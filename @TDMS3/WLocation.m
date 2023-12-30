%2022.7.5
%TDMS3成员函数
%函数功能：用w1、w2两个百分比，截取整段数据中的一部分

function data = WLocation(obj,w1,w2,chn)
    if w1 > w2
        w = w2;
        w2 = w1;
        w1 = w;
    end
    
    [fileLocation1,ptLocation1] = obj.Location(w1);
    [fileLocation2,ptLocation2] = obj.Location(w2);
    
    data = obj.GetData([fileLocation1:fileLocation2],chn);
    
    stNum = ptLocation1;
    edNum = sum(obj.filePoints(fileLocation1:fileLocation2)) + ptLocation2 - obj.filePoints(fileLocation2);
    
    data = data(:,[stNum:edNum]);
end