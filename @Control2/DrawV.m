%��������ָ������Ŀ��Ʋ���
%20190806
%�������: 
%num����Ϊ1ʱparas1��Ϊ2ʱparas2
%v����Ϊ��ѹ��ֵ��0-10V
%direction����Ϊ��������x+��x-��y+��y-��z+��z-�ֱ�Ϊ1-6

function fileName = DrawV(obj,num,v,direction)
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    values = paras.values;
%     types = paras.types;
    names = paras.names;
    
    channels = paras.channels;
       
    baseName1 = 'volt_out_P_';
    baseName2 = 'volt_out_N_';
    baseName3 = 'channel_on_';
      
    for iC = 1:length(channels)
        channel = channels{iC};
        
        %������������ͨ��������Ϊ0
        tempName = [baseName1 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = 0;
        
        %���и�������ͨ��������Ϊ0
        tempName = [baseName2 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = 0; 
        
        %����ͨ������Ϊ0
        tempName = [baseName3 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = 0; 
    end
    
    if mod(direction,2) == 0
        baseName = baseName2;
        finalName1 = '��';
    else
        baseName = baseName1;
        finalName1 = '��';
    end
    
    channelNames = {};
    if direction <= 2
        channelNames = {'x1','x2'};
        finalName2 = 'X';
    elseif direction <= 4
        channelNames = {'y1','y2'};
        finalName2 = 'Y';
    else
        channelNames{1} = 'z1';
        finalName2 = 'Z';
    end
    
    for iC = 1:length(channelNames)
        channel = channelNames{iC};
        tempName = [baseName channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = v;
    end
    finalName3 = num2str(v);

%     %������paras������
%     tempName = paras.file;
%     s = find(tempName == '\');
%     tempPath = tempName(1:s(end));
    
    paras.values = values;
%     fileName = [paras.path finalName2 finalName1 '��' finalName3 'V' datestr(now,'yyyymmdd') '.csv'];
    fileName = [paras.path finalName2 finalName1 '��' finalName3 'V.csv'];
    obj.Save2CSV(fileName,paras)
end