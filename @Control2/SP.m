%将控制参数转化为五个扫频参数
%20190806
%输入参数: num——为1时paras1，为2时paras2，缺省为1

function SP(obj,num)
    if nargin < 2
        num = 1;
    end
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    values = paras.values;
%     types = paras.types;
    names = paras.names;
    
    channels = paras.channels;
    baseName1 = 'FS_out_P_';
    baseName2 = 'FS_out_N_';
    
    %提炼出paras的名称
    tempName = paras.file;
    s = find(tempName == '\');
    tempName2 = tempName(s(end)+1:end-4);
        
    for iC = 1:length(channels)
        %将所有的扫频参数设置为0，20210415
        location = strmatch(baseName1,names);
        values(location) = 0;
        location = strmatch(baseName2,names);
        values(location) = 0;  
  
        channel = channels{iC};
%         values(find(types(:,2) == 4)) = 0;      
%         tempName = [baseName1 channel];
%         temp = strcmp(tempName,names);
%         values(find(temp == 1)) = 1;
%         
%         tempName = [baseName2 channel];
%         temp = strcmp(tempName,names);
%         values(find(temp == 1)) = 1; 
        
        tempPara1 = [baseName1 channel];
        lc1 = strmatch(tempPara1,names);
        values(lc1) = 1;
        tempPara2 = [baseName2 channel];
        lc2 = strmatch(tempPara2,names);
        values(lc2) = 1;
        
        paras.values = values;
        fileName = [tempName2 '扫频' channel '_' datestr(now,'yyyymmdd') '.csv'];
        obj.Save2CSV(fileName,paras)
    end
end