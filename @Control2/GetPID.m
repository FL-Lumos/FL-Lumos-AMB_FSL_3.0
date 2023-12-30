%Control2���ڷ���
%������ControlParas���г�Ա����PIDModel
%20190606
%��ĳ��ͨ���Ŀ��Ʋ�������ΪPID����ģ��
%channel��'X1','Y1','X2','Y2','Z1'

function obj = GetPID(obj,num,channel)
    %20180813 ���Ӵ���������
%     Sr = abs(GetParaValue2(obj,num,'sensor_gain',channel));
    %20191028,��abs����Ϊ-
    Sr = -(GetParaValue2(obj,num,'sensor_gain',channel));

    %�����������ڴ��ݺ���
    GP = GetParaValue2(obj,num,'kp',channel);
    
    %�������ֻ��ڴ��ݺ���
    GI = GetComponentModel(obj,num,'integral',channel);
    
    %����΢�ֻ��ڴ��ݺ���
    GD = GetComponentModel(obj,num,'shape',channel);
    
    %�˲����������ݺ���
    GF = GetComponentModel(obj,num,'filter',channel);

    %PIDģ�ͺϳ�
    pid = Sr*(GP + GI + GD) * GF;   %�������������ݺ���
    
    if num == 1
        obj.pid1{1,channel} = pid;
    else
        obj.pid2{1,channel} = pid;
    end   
end