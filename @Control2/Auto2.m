%�����������ܣ��Զ�������Ʋ���������pid1Ϊ��ʼ��������������Ų������洢��pid2��;
%�����Ŀ��Ʋ�����Χ kp,kd,fd,ki,fi;
%20190909

function obj = Auto2(obj,chns)
    %Step0����������
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
          
    values2 = values;  %��pid1�Ĳ�������pid1
    ctr = obj;
    
    %Stpe1�����Ĵ���
    for iC = 1:length(chns)
        chn = chns(iC);
        %���������Ϣ��mat�ļ���  

        save('controller.mat','ctr','chn');
        %��ȡ��ֵ
        tempOrder = orders(chn,:);
        x0 = values(find(ismember(types,tempOrder) == 1));
    
        %Step3:�����Ż�����
        VUB = x0*2
        VLB = x0*0.5;
        A = [];
        b = [];
        Aeq = [];
        beq = [];
        [x, fval] = fmincon(@LossFun2, x0, A, b, Aeq, beq, VLB, VUB);

        %���²������赽pid2��
        values2(tempOrder) = x;
    end
    
    obj.paras2 = obj.paras1;
    obj.paras2.values = values2;
    obj = GetModel(obj,'pid',2);
end

function score = LossFun2(x)
    %������Ϣ
    data = load('controller.mat');
    chn = data.chn;
    ctr = data.ctr;
%   kp,capital_kd,frequency_D,capital_ki,frequency_I
    %��������
    values = ctr.paras1.values;
    types = ctr.paras1.types(:,1);
    orders = [40031 40036 40041 40151 40156
              40032 40037 40042 40152 40157
              40034 40039 40044 40154 40159
              40035 40040 40045 40155 40160
              40033 40038 40043 40153 40158];
    tempOrder = orders(chn,:);
    values(find(ismember(types,tempOrder) == 1)) = x;  %������ֵ�����values
%     x
    ctr.paras1.values = values;   
    
    %���������б�ֵ
    ctr = ctr.GetModel('pid',1,chn)
    ctr = ctr.GetModel('open',1,chn);
    p = ctr.Margin2(ctr.openlp{1,chn});

%     values = ctr.paras1.values;    
%     x0 = values(find(ismember(types,tempOrder) == 1));
    %����Ϊ��ʧ����
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
