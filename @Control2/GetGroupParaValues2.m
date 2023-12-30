%ControlParas���ڷ���
%���ܣ���ȡָ�����Ƶ���Ĳ���ֵ��
%20190426
%���룺groupName�������������ƣ�channel����ͨ��

function groupValues = GetGroupParaValues2(obj,num,groupName,channel)
    if num == 1     
        names = obj.paras1.names;
        values = obj.paras1.values;
%         channels = obj.paras1.types(:,3);
%         groupOrder = obj.paras1.types(:,5);
        channels = obj.paras1.channels;
        

    else
        names = obj.paras2.names;
        values = obj.paras2.values;
%         channels = obj.paras2.types(:,3);
%         groupOrder = obj.paras2.types(:,5);

        channels = obj.paras2.channels;
       
    end
    
    %΢������
    if strcmp(groupName,'shape') == 1
        strs = {'active_shape_D','frequency_peak','frequency_bw','weight'};
        groupValues = cell(1,2);
        tempValue = [];
        for iS = 1:length(groupValues)
            for iN = 1:length(strs)
                str = strs{iN};
%                 location = intersect(strmatch(str,names),find(groupOrder == iS & channels == channel)); 

                location = strmatch([str num2str(iS) '_' channels{channel}],names);
                
                tempValue = setfield(tempValue,str,values(location));
            end
            groupValues{1,iS} = tempValue;
        end
    end
    
    %�˲���
    if strcmp(groupName,'filter') == 1
        groupValues = cell(1,8);
        strs = {'active_f','frequency_f','bandwidth_f','Rs_f'};
        tempValue = [];
        for iS = 1:length(groupValues)
            for iN = 1:length(strs)
                str = strs{iN};
%                 location = intersect(strmatch(str,names),find(groupOrder == iS & channels == channel)); 

                location = strmatch([str num2str(iS) '_' channels{channel}],names);
                tempValue = setfield(tempValue,str,values(location));
            end
            groupValues{1,iS} = tempValue;
        end
    end
end