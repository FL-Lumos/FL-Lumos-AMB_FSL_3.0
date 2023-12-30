%定义控制系统的评价/损失函数

function scores = LossFun(obj,num,chn)
    %默认是五个通道 
    if nargin < 3
         chn = [1 2 3 4 5];
    end
    %默认是第1组参数 
    if nargin < 2
        num = 1;
    end
    
    %构造pid模型和开环函数
    obj = obj.GetModel('pid',num,chn);
    obj = obj.GetModel('open',num,chn);      
    obj = GetModel(obj,'S',num,chn);
    
    scores = [];
    for iC = 1:length(chn)
        ch = chn(iC);
        
        %幅值裕度，相位裕度
        mg = obj.Margin2(op);  
        %评估灵敏度函数
        st = obj.st{1,ch};    

        f = st.f/(2*pi);                    %横坐标频率值
        r = st.ResponseData;
        r = reshape(r,size(f));
        m = 20*log10(abs(r));      %响应幅值
        p = angle(r)*180/pi;  %响应相位
        [maxSt l] = max(m);
        fSt = f(l);        
        
        th = [mg(1,2) mg(2,3) maxSt];        %依次为幅值裕度，相角裕度，灵敏度最大值
        
    end
end

function score = Loss(th)
    a = th(1);
    p = th(2);
    s = th(3);
    
    tha = 8;
    thp = 35;
    ths = 6;
    
    ra = ReLu(a - tha);
    rp = ReLu(p - thp);
    rs = ReLu(s - ths);

end

function obj = Auto(obj,chn)
     if nargin < 2
         chn = 1;
     end
     obj.paras2 = obj.paras1;
     obj = GetModel(obj,'pid',2);
     
     types = obj.paras1.types(:,1);
     values = obj.paras1.values;
     
     %设置
     thA = 8;    %幅值裕度阈值
     thP = 35;   %相角裕度阈值
     
     orders = [40031 40036 40041 40151 40156];
     c = ismember(types,orders);
     para = values(c);   %初始参数
     
     %确定参数搜索的上下界限
     maxP = para*1.5;
     minP = para*0.5;
     
     storeMat = zeros(4,100000);
     
     L = 0;
     
     for iP = 1:100000
%          iP
         %临时参数
         tempValue = zeros(5,1);         
         tempValue = minP + (maxP - minP).*rand(5,1);
         
         %临时pid2
         values(c) = tempValue;
         obj.paras2.values = values;
         obj = obj.GetModel('pid',2);
         obj = obj.GetModel('open',2,1);               
         obj = obj.EvalModel(1,0);
         
         stab = obj.stab{1,1};
         storeMat(:,iP) = stab(:);
         
         s1 = stab(1,2);
         s2 = stab(2,2);
%          tempL = sign(ReLu(s1 - thA)*ReLu(s2-thP))*(ReLu(s1 - thA)/thA + ReLu(s2 - thP)/thP);
         tempL = lossf(s1,s2);
         
        iP
        [s1,s2,tempL]
         
        if tempL > L
       newPara = tempValue;
             L = tempL;
         end
         
         if L > 0
             break;
         end
         
         if iP == 100000
            values(c) = newPara;
            obj.paras2.values = values;
         end
         
%          if stab(1,2) > thA & stab(2,2) > thP
%              break
%          end
     end
     obj.Save2CSV('newParas.csv',2)
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