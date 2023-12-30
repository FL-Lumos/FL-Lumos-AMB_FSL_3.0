%函数基本功能：自动计算控制参数，基于pid1为初始参数，计算出最优参数，存储到pid2中;
%调整的控制参数范围 kp,kd,fd,ki,fi;
%20190909

function obj = Auto2(obj,chns)
    %Step0：参数设置
    if nargin < 2
        chns = [1,2,3,4,5];
    end  
    values = obj.paras1.values;
    types = obj.paras1.types(:,1);
    orders = [40031 40036 40041 40151 40156
              40032 40037 40042 40152 40157
              40034 40039 40044 40154 40159
              40035 40040 40045 40155 40160
              40033 40038 40043 40153 40158];
          
    values2 = values;  %将pid1的参数赋给pid1
    ctr = obj;
    
    %Stpe1：核心代码
    for iC = 1:length(chns)
        chn = chns(iC);
        %保存相关信息到mat文件中  

        save('controller.mat','ctr','chn');
        %获取初值
        tempOrder = orders(chn,:);
        x0 = values(find(ismember(types,tempOrder) == 1));
    
        %Step3:构造优化参数
        VUB = x0*2
        VLB = x0*0.5;
        A = [];
        b = [];
        Aeq = [];
        beq = [];
        [x, fval] = fmincon(@LossFun2, x0, A, b, Aeq, beq, VLB, VUB);

        %将新参数赋予到pid2中
        values2(tempOrder) = x;
    end
    
    obj.paras2 = obj.paras1;
    obj.paras2.values = values2;
    obj = GetModel(obj,'pid',2);
end

function score = LossFun2(x)
    %载入信息
    data = load('controller.mat');
    chn = data.chn;
    ctr = data.ctr;
%   kp,capital_kd,frequency_D,capital_ki,frequency_I
    %参数更新
    values = ctr.paras1.values;
    types = ctr.paras1.types(:,1);
    orders = [40031 40036 40041 40151 40156
              40032 40037 40042 40152 40157
              40034 40039 40044 40154 40159
              40035 40040 40045 40155 40160
              40033 40038 40043 40153 40158];
    tempOrder = orders(chn,:);
    values(find(ismember(types,tempOrder) == 1)) = x;  %将参数值赋予给values
%     x
    ctr.paras1.values = values;   
    
    %计算三个判别值
    ctr = ctr.GetModel('pid',1,chn)
    ctr = ctr.GetModel('open',1,chn);
    p = ctr.Margin2(ctr.openlp{1,chn});

%     values = ctr.paras1.values;    
%     x0 = values(find(ismember(types,tempOrder) == 1));
    %整合为损失函数
    a = p.Am;
    b = p.Pm;
    c = p.Sm;
   
    ThA = 8;
    ThP = 35;
    ThS = 6;
    
%     score = -(fA(a) + fP(b));
    score = -(fA(a) + fP(b) + fS(c));

    [a b c score]
end

function score = fP(x)
    if x < 25
        score = 0;
    elseif x < 35
        score = x - 25;
    elseif x < 40
        score = 10 + (x-35)*0.4;
    elseif x < 45
        score = 12 - 2.4*(x-40);
    else 
        score = 0;
    end
end

function score = fA(x)
    if x < 6
        score = 0;
    elseif x < 8
        score = (x-6)*5;
    elseif x < 10
        score = 10 + (x - 8)*1;
    elseif x < 12
        score = 12 - 6*(x-10);
    else 
        score = 0;
    end
end

function score = fS(x)
    score = 6 - x;
end
