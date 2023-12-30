%Control2类内方法
%功能：
%1. 获取指定名称的控制参数值；
%2. 指定参数名和通道数，获取相应的参数值;
%20190606
%输入参数
%num——1表示paras1,2表示para2
%paraName——参数名/去掉通道的名称
%channel——数值/通道
%value——数值
function value = GetParaValue2(obj,num,paraName,channel)
    if num == 1     
        paraNames = obj.paras1.names;
        values = obj.paras1.values;
        channels = obj.paras1.channels;
    else
        paraNames = obj.paras2.names;
        values = obj.paras2.values;
        channels = obj.paras2.channels;
    end
    
    %已知参数名和通道名，e.g. 'channel_on',channel = 1,则获取'channel_on_x1'的数值
    if nargin == 4
        if isstr(channel) == 0
            channel = channels{channel};
        end
        paraName = [paraName '_' channel];
    end
        
    %已知参数名'channel_on_x1'，取其数值
    location = strcmp(paraName,paraNames);
    value = values(location);
end