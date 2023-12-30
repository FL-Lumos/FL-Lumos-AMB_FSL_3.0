%TDMS2类函数
%函数功能：将tdms文件转换为.mat文件
%输入：fileOrder——文件序号obj.fileNames中的序号，例如[1 2 3]
%      mode——默认为1，按照文件序号进行转换，mode=2为filePath下所有的文件均转换为.mat文件

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
            %将文件内容转换为data矩阵
            temp = tempName{1,iF};
            fileName = [filePath temp(1:end-5) '.mat'];  %Mat名称
            
            %如果不存在.mat文件
            if exist(fileName) ~= 2
                [data info] = GetData(obj,[filePath temp]);
                %20210419增加/修改 info的内容
                info = struct('sampling',obj.sampling,'filePath',obj.filePath,'channelNames',obj.channelNames);
                save(fileName,'data','info');
            end         
        end
    catch
        msgbox('转换出现故障！')
    end
end