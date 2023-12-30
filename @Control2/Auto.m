%自动计算控制参数
%基于pid1为初始参数，计算出最优参数，存储到pid2中
%20190828开始

function obj = Auto(obj,chn)
    %Step1:保存相关信息到mat文件中  
    %Step2:获取初值
    values = obj.paras1.values;
    types = obj.paras1.types(:,1);
    orders = [40031 40036 40041 40151 40156
              40032 40037 40042 40152 40157
              40034 40039 40044 40154 40159
              40035 40040 40045 40155 40160
              40033 40038 40043 40153 40158];
    tempOrder = orders(chn,:);
    x0 = values(find(ismember(types,tempOrder) == 1));
    
    %Step3:构造优化参数
    VUB = x0*2
    VLB = x0*0.5;
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    [x, fval] = fmincon(@LossFun2, x0, A, b, Aeq, beq, VLB, VUB)
%     [x,b,c,d] = fminsearch(@LossFun2,x0)

%     [x,fval] = ga(@LossFun2,x0,[],[],[],[],[],[])

    %将新参数写入到控制器中


%      if nargin < 2
%          chn = 1;
%      end
%      obj.paras2 = obj.paras1;
%      obj = GetModel(obj,'pid',2);
%      
%      types = obj.paras1.types(:,1);
%      values = obj.paras1.values;
%      
%      %设置
%      thA = 8;    %幅值裕度阈值
%      thP = 35;   %相角裕度阈值
%      
%      orders = [40031 40036 40041 40151 40156];
%      c = ismember(types,orders);
%      para = values(c);   %初始参数
%      
%      %确定参数搜索的上下界限
%      maxP = para*1.5;
%      minP = para*0.5;
%      
%      storeMat = zeros(4,100000);
%      
%      L = 0;
%      
%      for iP = 1:100000
% %          iP
%          %临时参数
%          tempValue = zeros(5,1);         
%          tempValue = minP + (maxP - minP).*rand(5,1);
%          
%          %临时pid2
%          values(c) = tempValue;
%          obj.paras2.values = values;
%          obj = obj.GetModel('pid',2);
%          obj = obj.GetModel('open',2,1);               
%          obj = obj.EvalModel(1,0);
%          
%          stab = obj.stab{1,1};
%          storeMat(:,iP) = stab(:);
%          
%          s1 = stab(1,2);
%          s2 = stab(2,2);
% %          tempL = sign(ReLu(s1 - thA)*ReLu(s2-thP))*(ReLu(s1 - thA)/thA + ReLu(s2 - thP)/thP);
%          tempL = lossf(s1,s2);
%          
%         iP
%         [s1,s2,tempL]
%          
%         if tempL > L
%        newPara = tempValue;
%              L = tempL;
%          end
%          
%          if L > 0
%              break;
%          end
%          
%          if iP == 100000
%             values(c) = newPara;
%             obj.paras2.values = values;
%          end
%          
% %          if stab(1,2) > thA & stab(2,2) > thP
% %              break
% %          end
%      end
%      obj.Save2CSV('newParas.csv',2)
end

function score = lossf(a,b)
    if a < 8
        A = a - 8;
    else
        A = 0.1*(a - 8);
    end
    if b < 35
        B = b - 35;
    else
        B = 0.1*(b-35);
    end
    
    score = A + B;
    
end

function s = ReLu(x)
    if x > 0
        s = x;
    else
        s = 0;
    end
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
    
%     score = -((a/ThA)^2 + (b/ThP)^2 + 0.1*(a - ThA) + 0.9*(b - ThP));
%     score = -((a - ThA) + 2.5*(b - ThP))
    score = -(fA(a) + fP(b));

%     score = -(sign(a - ThA)*(a - ThA) + sign(b-ThP)*(b-ThP));
%     score = -sum(x)
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