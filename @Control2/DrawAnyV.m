%生成吸引任意方向任意电压的控制参数
%20200909
%输入参数: 
%num——为1时paras1，为2时paras2
%st为N*2的矩阵，每一行为[d,v],d为方向1-10分别代表，x1+,y1+,x2+,y2+,z+,x1-,y1-,x2-,y2-,z-，v代表电压0~10V
%v——为电压数值，0-10V
%direction——为吸引方向，x+，x-，y+，y-，z+，z-分别为1-6

function fileName = DrawAnyV(obj,num,st)
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    values = paras.values;
    types = paras.types;
    names = paras.names;
    
    channels = paras.channels;
      
    baseName1 = 'volt_out_P_';
    baseName2 = 'volt_out_N_';
    baseName3 = 'channel_on_';
    
    %清除所有volt_out通道的电压,设定为不悬浮
    for iC = 1:length(channels)
        channel = channels{iC};
        
        %所有正向吸引通道均设置为0
        tempName = [baseName1 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = 0;
        
        %所有负向吸引通道均设置为0
        tempName = [baseName2 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = 0; 
        
        %悬浮通道设置为0
        tempName = [baseName3 channel];
        temp = strcmp(tempName,names);
        values(find(temp == 1)) = 0; 
    end
    
    %给指定通道赋值
    finalName = [];
    for iD = 1:length(st)
        tempD = st(iD,1);
        tempV = st(iD,2);
        
        if tempV ~= 0
            if tempD <= 5
                baseName = baseName1;
                channel = channels{tempD};
                finalName1 = '正';
            else
                baseName = baseName2;
                channel = channels{tempD - 5};
                finalName1 = '负';
            end

            finalName = [finalName '_' channel finalName1 num2str(tempV) 'V']
            temp = strcmp([baseName channel],names);
            values(temp) = tempV;   
        end
    end
    
    paras.values = values;
    fileName = [paras.path '吸' finalName '.csv'];
    obj.Save2CSV(fileName,paras)
end