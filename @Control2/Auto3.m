%�����������ܣ��Զ�������Ʋ���������pid1Ϊ��ʼ��������������Ų������洢��pid2��;
%�����Ŀ��Ʋ�����Χ kp,kd,fd,ki,fi;
%20190909

function obj = Auto3(obj,chns)
    %Step0����������
    if nargin < 2
        chns = [1,2,3,4,5];
    end  
    
    %Step1������pid2�����Ż�
    obj.pid2 = obj.pid1;
    obj.paras2 = obj.paras1;
    
    deta = 0.3;
    N = 100;
    %Stpe2��ѭ������
    for iC = 1:length(chns)
        ch = chns(iC);        
        
        x0 = GetPIDValue(obj,2,ch);   %��ȡ����
        st = OPCriterion(obj,2,ch,x0); %�жϱ�׼
        stV = 1;
        
        flag = 1;
        while flag > 0
            flag = flag + 1
            neig = CalcNN(x0,deta,N);      %��ȡ�ھ�

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
    
    %�������
    Save2CSV(obj,'best.csv',2)
end

%��������
%x0Ϊԭʼ����ֵ
%detaΪ��������뾶
%NΪ��������
function neig = CalcNN(x0,deta,N)
    %ÿһ�д���һ����������
    temp = 1 + deta*(2*rand(N,length(x0))-1);  %������������
    neig = ones(N,1)*x0.*temp;
end

%��ȡָ��ͨ�����������ֵ
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

%����ָ��ͨ�����������ֵ
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
    obj = obj.Refresh(num,values);  %����ģ��
end

%����Ŀ��ֵ
function criterion = OPCriterion(obj,num,ch,x0)
    obj = SetPIDValue(obj,num,ch,x0);
    if num == 1
        criterion = EvalModel2(obj,obj.pid1,ch,0);    
    else
        criterion = EvalModel2(obj,obj.pid2,ch,0);
    end 
    criterion = criterion{1,ch}([1 2],2);
end

%Ŀ�꺯��
function result = Target(criterion,st)    
%w1:ֱ�ӱ�����
%     result = criterion./st;
%     result = sum(result);
%     result = criterion./st;
    result = (criterion(1)-st(1))+ 100*(criterion(2)-st(2));
    if criterion(1) < st(1) | criterion(2) < st(2)
        result = -1;
    end    
end




