%20200520
%20200814 ��mat��ʽ��Ϊֱ�Ӵ�tdms�ļ��ж�ȡ
%�������ܣ���TDMS�ļ��л�ȡ����Ƭ�Σ�TDMS3���ں��ĺ���
%���룺
%fileNum��������Ƭ�������ļ���
%chn��������ͨ���������Ƕ��ͨ���ţ�e.g. [2 3 1 2]
%stNum������ʼ����
%ptNum��������Ƭ�ε���
%flag�����Ƿ���ļ�ȡ���ݣ�������ʼλ��λ���ļ���ĩ�ˣ�����Ƭ�ο��ܿ�Խ�ļ�
%flag = 0������Խ�ļ��������ݵ㲻�㣬����ʣ��Ƭ��
%flag = 1, �ɿ�Խ�ļ���ֱ�����һ���ļ����򷵻�ʣ��Ƭ�Σ�
%flag = 2������Խ�ļ������ļ��������������ݵ�����������һ������ǰ����ptNum�����ݵ㣻
%�����
%data�������ص�����Ƭ��
%mark��������״̬��־
%mark = 0��������ȡƬ��
%mark = 1����Խ�ļ�ȡ����
%mark = 2, �ӽ�β��ʼ�������ݵ���
%mark = -1, ���ݵ�������ptNum

function [data mark] = GetSlice(obj,fileNum,chn,stNum,ptNum,flag)    %���.mat�ļ�����ȡ����Ƭ��   
%     f1 = load([obj.filePath obj.matNames{1,fileNum}]);
    %20200814
    [tempData channelNames] = GetData(obj,fileNum);
    f1.data = tempData;
    f1.info = channelNames;
    
    totalNum = length(f1.data); %�ļ����ܵ���
%     totalNum = obj.filePoints(1,fileNum);

    if ptNum > totalNum        
        msgbox('�����ļ������ݵ��� С�� �趨�ĵ����������ݵ�����');
    end
    
    
    if stNum + ptNum - 1 > totalNum
        switch flag
            case 0
                endNum = totalNum;  %��ȡʣ��Ƭ��
                mark = -1;
            case 2
                endNum = totalNum;
                stNum = totalNum - ptNum + 1;  %��ǰ����
                mark = 2;
            case 1
                %���ļ������������һ���ļ�
                if fileNum == obj.fileNum
                    endNum = totalNum;  %��ȡʣ��Ƭ��
                    mark = -1;               
                %���ļ�
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