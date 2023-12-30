%Control2类内方法
%更新于ControlParas类中成员方法PIDModel
%20190606
%将某个通道的控制参数构造为PID连续模型
%channel：'X1','Y1','X2','Y2','Z1'

function obj = GetPID(obj,num,channel)
    %20180813 增加传感器环节
%     Sr = abs(GetParaValue2(obj,num,'sensor_gain',channel));
    %20191028,将abs更改为-
    Sr = -(GetParaValue2(obj,num,'sensor_gain',channel));

    %连续比例环节传递函数
    GP = GetParaValue2(obj,num,'kp',channel);
    
    %连续积分环节传递函数
    GI = GetComponentModel(obj,num,'integral',channel);
    
    %连续微分环节传递函数
    GD = GetComponentModel(obj,num,'shape',channel);
    
    %滤波器连续传递函数
    GF = GetComponentModel(obj,num,'filter',channel);

    %PID模型合成
    pid = Sr*(GP + GI + GD) * GF;   %连续控制器传递函数
    
    if num == 1
        obj.pid1{1,channel} = pid;
    else
        obj.pid2{1,channel} = pid;
    end   
end