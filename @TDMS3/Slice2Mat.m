%TDMS3类函数
%2022.4.20
%函数功能：将tdms文件转换为.mat文件,可选通道、任意设置起点和终点
%模式：1——多个/单个TDMS完整文件转换为多个或者单个TDMS文件；
%      2——给定起点、终点
%输入：fileOrder——文件序号obj.fileNames中的序号，例如[1 2 3]
%      mode——默认为1，按照文件序号进行转换，mode=2为filePath下所有的文件均转换为.mat文件
%      va11,val2——均属于0-1

function Slice2Mat(obj,mode,fileNum,chnOrder,val1,val2,saveName)
    info.sampling = obj.sampling;
    info.filePath = obj.filePath;
    info.fileNames = obj.fileNames(fileNum);
    info.channelNames = obj.channelNames(chnOrder);
    info.sensors = obj.sensors;

    if mode == 1
        data = obj.GetData(fileNum,chnOrder);

        info.startPt = [fileNum(1),1];
        info.endPt = [fileNum(end),obj.filePoints(fileNum(end))];
        
        if nargin < 7
            saveName = ['Slice' obj.fileNames{fileNum(1)}(14:end-5) '-' obj.fileNames{fileNum(end)}(14:end-5) '.mat'];
        end  
    end
    
    if mode == 2
        [fileLocation1,ptLocation1] = obj.Location(val1);
        [fileLocation2,ptLocation2] = obj.Location(val2);
        filePoints = obj.filePoints;
        
%         %计算总点数
%         pts = 0;
%         if fileLocation1 == fileLocation2
%             %起点和终点在同一个文件上
%             pts = ptLocation2 - ptLocation1 + 1;
%         else
%             for iP = fileLocation1:fileLocation2
%                 if iP == fileLocation1
%                     pts = filePoints(fileLocation1) - ptLocation1 + 1; %第1个文件
%                 elseif iP == fileLocation2
%                     pts = pts + ptLocation2; %最后一个文件
%                 else
%                     pts = pts + filePoints(iP); %中间完整的文件
%                 end
%             end
%         end    
%         [data, ~] = obj.GetSlice(fileLocation1,chnOrder,ptLocation1,pts,1);   
        
        %2023.9.12修改
        data = obj.WLocation(val1,val2,chnOrder);
        
        info.startPt = [fileLocation1,ptLocation1];
        info.endPt = [fileLocation2,ptLocation2];
        
        if nargin < 7
            %saveName = ['Slice' obj.fileNames{fileLocation1}(14:end-5) '-' obj.fileNames{fileLocation2}(14:end-5) '.mat'];
            %saveName = ['Slice' obj.fileNames{fileLocation1}(14:end-5) '-' obj.fileNames{fileLocation2}(14:end-5) '-' num2str(ptLocation1) '-' num2str(ptLocation2) '.mat'];
            sum_filePoints = 0;
            for i = fileLocation1:fileLocation2
                sum_filePoints = sum_filePoints+obj.filePoints(i)
            end
            saveName = ['Slice' obj.fileNames{fileLocation1}(14:end-5) '-' obj.fileNames{fileLocation2}(14:end-5) '-' num2str(ptLocation1) '-' num2str(ptLocation2 + sum_filePoints - obj.filePoints(fileLocation2)) '-' num2str(sum_filePoints) '.mat'];
            % 2023.11.22修改，实现导出文件名为：tdms始-tdms终-起点数（相对于tdms始-tdms终的）-终点数（相对于tdms始-tdms终的）-总点数（相对于tdms始-tdms终的）
        end      
    end
    save([obj.filePath saveName],'data','info');    
end