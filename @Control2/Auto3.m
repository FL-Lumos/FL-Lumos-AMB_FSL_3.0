%函数基本功能：自动计算控制参数，基于pid1为初始参数，计算出最优参数，存储到pid2中;
%调整的控制参数范围 kp,kd,fd,ki,fi;
%20190909

function obj = Auto3(obj,chns)
    %Step0：参数设置
    if nargin < 2
        chns = [1,2,3,4,5];
    end  
    
    %Step1：利用pid2进行优化
    obj.pid2 = obj.pid1;
    obj.paras2 = obj.paras1;
    
    deta = 0.3;
    N = 100;
    %Stpe2：循环过程
    for iC = 1:length(chns)
        ch = chns(iC);        
        
        x0 = GetPIDValue(obj,2,ch);   %获取参数
        st = OPCriterion(obj,2,ch,x0); %判断标准
        stV = 1;
        
        flag = 1;
        while flag > 0
            flag = flag + 1
            neig = CalcNN(x0,deta,N);      %获取邻居

            results = zeros(N,1);
            tempCR = zeros(N,2);
            for iN = 1:N
                criterion = OPCriterion(obj,2,ch,neig(iN,:));
                tempCR(iN,:) = criterion;
                results(iN,1) = Target(criterion,st);
            end

            [maxV id] = max(results);
            [maxV tempCR(id,:)]

            if maxV > stV
                stV = maxV;
                x0 = neig(id,:)
            else
                flag = 0;
            end
        end
        obj = SetPIDValue(obj,2,ch,x0)
    end
    
    %保存参数
    Save2CSV(obj,'best.csv',2)
end

%计算领域
%x0为原始数据值
%deta为邻域比例半径
%N为样本组数
function neig = CalcNN(x0,deta,N)
    %每一行代表一个邻域样本
    temp = 1 + deta*(2*rand(N,length(x0))-1);  %样本增长比例
    neig = ones(N,1)*x0.*temp;
end

%获取指定通道的五个参数值
function x0 = GetPIDValue(obj,num,ch)
    orders = [40031 40036 40041 40151 40156
              40032 40037 40042 40152 40157
              40034 40039 40044 40154 40159
              40035 40040 40045 40155 40160
              40033 40038 40043 40153 40158];
    
    if num == 1
        values = obj.paras1.values;
    else
        values = obj.paras1.values;
    end
    
    types = obj.paras1.types(:,1);
    tempOrder = orders(ch,:);
    x0 = values(find(ismember(types,tempOrder) == 1));
    x0 = x0';
end

%设置指定通道的五个参数值
function obj = SetPIDValue(obj,num,ch,x0)
    orders = [40031 40036 40041 40151 40156
              40032 40037 40042 40152 40157
              40034 40039 40044 40154 40159
              40035 40040 40045 40155 40160
              40033 40038 40043 40153 40158];
    
    if num == 1
        values = obj.paras1.values;
    else
        values = obj.paras1.values;
    end
    
    types = obj.paras1.types(:,1);
    tempOrder = orders(ch,:);
    values(find(ismember(types,tempOrder) == 1)) = x0;
    obj = obj.Refresh(num,values);  %更新模型
end

%计算目标值
function criterion = OPCriterion(obj,num,ch,x0)
    obj = SetPIDValue(obj,num,ch,x0);
    if num == 1
        criterion = EvalModel2(obj,obj.pid1,ch,0);    
    else
        criterion = EvalModel2(obj,obj.pid2,ch,0);
    end 
    criterion = criterion{1,ch}([1 2],2);
end

%目标函数
function result = Target(criterion,st)    
%w1:直接比例法
%     result = criterion./st;
%     result = sum(result);
%     result = criterion./st;
    result = (criterion(1)-st(1))+ 100*(criterion(2)-st(2));
    if criterion(1) < st(1) | criterion(2) < st(2)
        result = -1;
    end    
end




