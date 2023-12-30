%��дʱ�䣺20200524
%�������ܣ���λ������һ���ٷֱȣ���λ���ݵ��ڶ��Tdms�ļ��е�λ��
%���룺value�����ٷֱȣ���Χ[0,1]
%�����fileLocation������λ��ĳ���ļ���
%�����ptLocation������λ���ļ��ĵ�

function [fileLocation ptLocation] = Location(obj,value)
    totalTime = obj.totalTime;
    sampling = obj.sampling;
    totalNum = sum(obj.filePoints);
    
    location = floor(totalNum * value);
    
    %2023.5.25
    if location > totalNum
        location = totalNum;
    end
    
    if location == 0
        location = 1;
    end
    
    temp = location;
    
    fileLocation = 1;
    ptLocation = 1;

    for iF = 1:obj.fileNum
        t = obj.filePoints(1,iF);
        if temp <= t
            fileLocation = iF;
            ptLocation = temp;
            return;
        else
            temp = temp - t;
        end 
    end
end