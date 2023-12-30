%�����������ⷽ�������ѹ�Ŀ��Ʋ���
%20200909
%�������: 
%num����Ϊ1ʱparas1��Ϊ2ʱparas2
%stΪN*2�ľ���ÿһ��Ϊ[d,v],dΪ����1-10�ֱ����x1+,y1+,x2+,y2+,z+,x1-,y1-,x2-,y2-,z-��v�����ѹ0~10V
%v����Ϊ��ѹ��ֵ��0-10V
%direction����Ϊ��������x+��x-��y+��y-��z+��z-�ֱ�Ϊ1-6

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
    
    %�������volt_outͨ���ĵ�ѹ,�趨Ϊ������
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
    
    %��ָ��ͨ����ֵ
    finalName = [];
    for iD = 1:length(st)
        tempD = st(iD,1);
        tempV = st(iD,2);
        
        if tempV ~= 0
            if tempD <= 5
                baseName = baseName1;
                channel = channels{tempD};
                finalName1 = '��';
            else
                baseName = baseName2;
                channel = channels{tempD - 5};
                finalName1 = '��';
            end

            finalName = [finalName '_' channel finalName1 num2str(tempV) 'V']
            temp = strcmp([baseName channel],names);
            values(temp) = tempV;   
        end
    end
    
    paras.values = values;
    fileName = [paras.path '��' finalName '.csv'];
    obj.Save2CSV(fileName,paras)
end