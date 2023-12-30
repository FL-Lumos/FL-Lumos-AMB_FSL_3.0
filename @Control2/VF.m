%验证控制参数是否具备烧写到DSP的功能，取verfication的缩写含义
%20190822
%输入参数：num——1为默认参数，可以为1、2
%输出参数：result: flag——1为可用，0为不可用,str——具体内容

function result = VF(obj,num)
    %Step0: 参数预备
    if nargin < 2
        num = 1;
    end
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    
    values = paras.values; %参数值
    types = paras.types(:,1);   %参数值对应的参数类型的第1列，参数序号，本函数主要基于此进行判断
    str = [];
    flag = 1;
    %Step1: 提取主要信息进行判断
    %S1: 悬浮通道是否全部打开 40001-40005
    target = [40001:40005];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if sum(tempValues) ~= 5
        str = [str  '悬浮通道未全部打开！'];
        flag = 0;
    end
    %S2: 扫频通道是否全部关闭
    target = [40796:40805];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  '扫频通道未全部置零！'];
        flag = 0;
    end
    
    %S3: 电压通道是否都置零
    target = [40751:40760];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  '电压输出通道未全部置零！'];
        flag = 0;
    end
    
    if isempty(str) == 1
        str = ['参数设置正确，可以烧写到DSP中！'];
    else
        str = ['参数设置错误！'  str];
    end
    
    result = struct('flag',flag,'str',str);
    msgbox(str)
end