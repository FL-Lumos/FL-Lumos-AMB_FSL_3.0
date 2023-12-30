%TDMS2�ຯ��
%�������ܣ���tdms�ļ�ת��Ϊ.mat�ļ�
%���룺fileOrder�����ļ����obj.fileNames�е���ţ�����[1 2 3]
%      mode����Ĭ��Ϊ1�������ļ���Ž���ת����mode=2ΪfilePath�����е��ļ���ת��Ϊ.mat�ļ�

function TDMS2Mat(obj,mode,fileOrder)
    try
        filePath = obj.filePath;
        fileNum = obj.fileNum;
        fileNames = obj.fileNames;

        if nargin < 3
            fileNum = obj.fileNum;
            fileOrder = [1:fileNum];
        end
        if nargin < 2
            mode = 1;
        end
        if mode == 1
            tempName = fileNames(1,fileOrder);
        else
            files = dir([filePath '*.tdms']);
            for iF = 1:length(files)
                tempName{1,iF} = files(iF).name;
            end       
        end

        for iF = 1:length(tempName)
            %���ļ�����ת��Ϊdata����
            temp = tempName{1,iF};
            fileName = [filePath temp(1:end-5) '.mat'];  %Mat����
            
            %���������.mat�ļ�
            if exist(fileName) ~= 2
                [data info] = GetData(obj,[filePath temp]);
                %20210419����/�޸� info������
                info = struct('sampling',obj.sampling,'filePath',obj.filePath,'channelNames',obj.channelNames);
                save(fileName,'data','info');
            end         
        end
    catch
        msgbox('ת�����ֹ��ϣ�')
    end
end