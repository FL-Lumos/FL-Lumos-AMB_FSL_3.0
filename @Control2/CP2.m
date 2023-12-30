%函数功能：关闭参数中所有的滤波器，微分整形；
%与CP不同的是，
%20190903
%输入参数1：num——控制器pid1和pid2，1为默认参数，可以为1或2；
%输入参数2：pr——是否烧写到控制参数csv文件中，默认为0，0为不烧写，1为烧写
%输出参数：result: flag——1为可用，0为不可用,str——具体内容

function [obj,result] = CP2(obj,num,pr)
    %Step0: 参数预备，只保存到参数，不写入到csv中
    %默认是pid1
    if nargin < 2
        num = 1;
    end
    if num == 1
        paras = obj.paras1;
    else
        paras = obj.paras2;
    end
    %默认不写到csv中，只保存到paras中
    if nargin < 3
        pr = 0;
    else
        pr = 1;
    end
    
    %Step1: 找到滤波器，微分整形开关的位置
    values = paras.values; %参数值
    names = paras.names;   %参数名
    n1 = strmatch('active_f',names);   %滤波器位置
    n2 = strmatch('active_shape_D',names);  %微分整形位置
    n = [n1;n2];   
    
    %Step2：将相应位置的数值设为0
    if isempty(find(values(n) == 1)) == 1
        result = 0;
    else
        result = 1;
        values(n) = 0;
        paras.values = values;
    end

    if num == 1
        obj.paras1 = paras;
    else
        obj.paras2 = paras;
    end
    
    if pr == 1
        if num == 1
            obj.paras1.values = values;
            fileName = obj.paras1.file;
        else
            obj.paras2.values = values;
            fileName = obj.paras2.file;
        end
        fileName = [fileName(1:end-4) '_Modified.csv'];
        Save2CSV(obj,fileName,num)    
    end
end
    