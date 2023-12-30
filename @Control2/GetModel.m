%Control2类中获取模型的函数
%20190606
%输入参数
%groupName——'open'为开环函数，'rotor’为转子模型，'pid'为PID模型
%num——1代表paras1,2代表paras2,空缺代表paras1
%chn——1~5，如果空缺，代表[1 2 3 4 5]

function obj = GetModel(obj,groupName,num,chns)
    if nargin < 4
        chns = [1 2 3 4 5];  %默认代表全部通道
    end
    if nargin < 3
        num = 1;            %默认代表paras1
    end

    if strcmp(groupName,'pid') == 1
        numChns = length(chns);
        for iC = 1:numChns
            obj = GetPID(obj,num,chns(iC));
        end
    end
    
    if strcmp(groupName,'rotor') == 1
        chnType = [];
        if isempty(find(chns == 1)) == 0 |  isempty(find(chns == 3)) == 0
            chnType = [chnType 'X'];
        end
        if isempty(find(chns == 2)) == 0 |  isempty(find(chns == 4)) == 0
            chnType = [chnType 'Y'];
        end        
        if isempty(find(chns == 5)) == 0 
            chnType = [chnType 'Z'];
        end
        
        obj = GetRotor(obj,num,chnType);
    end
    
    if strcmp(groupName,'open') == 1
        numChns = length(chns);
        
        openlp = cell(1,5);
        rotor = obj.rotor;
        if num == 1
            pid = obj.pid1;
        else
            pid = obj.pid2;
        end
        
        for iC = 1:numChns
            temp = chns(iC);
            openlp{1,temp} = rotor{1,temp}*pid{1,temp};
        end
        
        obj.openlp = openlp;
    end
    
    %20190830 构造灵敏度函数
    if strcmp(groupName,'sensitivity') | strcmp(groupName,'S')
        numChns = length(chns);
        
        %判断开环函数是否存在
        temp = chns(1);
        tempOpen = obj.openlp{1,temp};
        
        if isempty(tempOpen) == 1      
            openlp = cell(1,5);
            rotor = obj.rotor;
            if num == 1
                pid = obj.pid1;
            else
                pid = obj.pid2;
            end

            for iC = 1:numChns
                temp = chns(iC);
                openlp{1,temp} = rotor{1,temp}*pid{1,temp};
            end

            obj.openlp = openlp;
        end
        
        %构造灵敏度函数
        for iC = 1:numChns
            temp = chns(iC);
            op = obj.openlp{1,temp};
            st = 1/(1 + op);   
            
            obj.st{1,temp} = st;
        end        
    end     
end