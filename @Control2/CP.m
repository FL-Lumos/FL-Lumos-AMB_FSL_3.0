%函数功能：清理控制参数中的调试项，为打开悬浮通道，关闭扫频通道，关闭电压通道,用于烧写，取Clean Parameters的缩写含义
%20190823，20190903改造
%输入参数：num——控制器pid1和pid2，1为默认参数，可以为1或2；
%输出参数：result: flag——1为可用，0为不可用,str——具体内容

function result = CP(obj,num)
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
        values(d) = 1;
    end
    %S2: 扫频通道是否全部关闭
    target = [40796:40805];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  '扫频通道未全部置零！'];
        flag = 0;
        values(d) = 0;
    end
    
    %S3: 电压通道是否都置零
    target = [40751:40760];
    [c d] = ismember(target,types);
    tempValues = values(d);
    
    if isempty(find(tempValues ~= 0)) == 0
        str = [str  '电压输出通道未全部置零！'];
        flag = 0;
        values(d) = 0;
    end
    
    if flag == 1
        str = ['参数设置正确，未修改，可以烧写到DSP中！'];
    else
        str = ['参数设置错误！'  str '已更正！']; 
        if num == 1
            obj.paras1.values = values;
            fileName = obj.paras1.file;
        else
            obj.paras2.values = values;
            fileName = obj.paras2.file;
        end
        fileName = [fileName(1:end-4) '_Modified.csv'];
        Save2CSV(obj,fileName,num)
        msgbox(str)
    end
    
    result.flag = flag;
    result.str = str;
end
    