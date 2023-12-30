%20210315
%将参数保存到csv文件中去，逐行将参数写到csv文件中，允许不存在模板；不同于Save2CSV，Save2CSV是拷贝现有参数，将新参数写到其中。
%fileName——自定义参数名称，缺省时，即为日期，譬如20190806140511，精确到秒
%num/paras——缺省时为1，否则为2，即只能应用paras1,paras2,或者为结构体paras

function Save2CSV2(obj,fileName,num)
    if nargin < 2
        fileName = [datestr(now,'yyyymmddhhMMSS') '.csv'];
    end
    if nargin < 3
        num = 1;
    end
    
    %第3个参数为paras时，为具体输入内容
    if isstruct(num) == 1
        paras = num;
    else 
        if num == 1
            paras = obj.paras1;
        else
            paras = obj.paras2;
        end
    end
    
    pT = table(paras.names,paras.values);
    writetable(pT,fileName,'WriteVariableNames',false);
end