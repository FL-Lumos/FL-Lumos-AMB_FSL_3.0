%�������ã����������ҵ����ڵ���value��ֵ��λ�ã���Ҫ���ڲ��ҹ�������
%20210508
%���룺fileNum��TDMS���ж�Ӧ��TDMS�������
%      chns,��Ӧ������ͨ��
%      value���趨����ֵ�����ڵ���value
%      sensorOrder��Ϊ[]����Ҫ�����������궨������Ϊ��������ͨ��
%      numPts,����numPts������ж�
%      type,Ĭ��Ϊ1��ѡ���й��Ϸ�������ȫ��ͨ����Ϊ����
%�����location,����fileNum��chn������Ӧ��TDMS�ļ��еĵ���λ��
%���ӣ�[location,fData] = p.FindFirstFDValue([1:4],[2:6],4,[3 4 1 2 5],2)��
%1~4��TMDS�ļ�����2-6ͨ�����ݣ���ֵ��4��ͨ��˳���ǵ�3·������X1����4·��Y1...������2���㿪ʼ����

function [location,fData] = FindFirstFDValue(obj,fileNum,chn,value,sensorOrder,numPts)   
    if nargin < 5
        sensorOrder = 0;
    end
    if nargin < 6
        numPts = 1;
    end
    
    [data,channelNames] = GetData(obj,fileNum,chn);
    %ת��Ϊ�������궨������
    if isempty(sensorOrder) ~= 1
        newData = obj.DataAfterSensor2(data,sensorOrder);
        data = newData;
    end    

    [x,y] = find(data >= value | data <= -value);   %�ҵ����ϵ�
    %������ֻҪ��һ��ͨ����һ������ϣ�����ͬһʱ�̶�����
    if isempty(x) ~= 1
        len = size(data,2);
        newData = zeros(1,len);
        newData(1,y) = 1;          %���ù��ϵ��λ��Ϊ1
        s = conv2(newData,ones(1,numPts));
        
        s = s(1,numPts:numPts + len -1);

        [x1,y1] = find(s >= numPts);
        [z,p] = min(y1);  %��1������numPts��λ��x1(p),y1(p)
        
        if isempty(p) ~= 1
            [fileLocation,ptLocation] = obj.Location2(z);  
            location = [fileLocation,ptLocation]; 
            fData = data(:,[z:z+numPts-1]);
        else
            location = [];
            fData = [];
        end
    else
        location = [];
        fData = [];
    end

    
    