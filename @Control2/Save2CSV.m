%20190806
%将参数保存到csv文件中去
%fileName——自定义参数名称，缺省时，即为日期，譬如20190806140511，精确到秒
%num/paras——缺省时为1，否则为2，即只能应用paras1,paras2,或者为结构体paras

function Save2CSV(obj,fileName,num)
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
    
    %在原路径下，复制paras1所属的csv，并命名为fileName
    %判断fileName是否已经包括了路径
    if isempty(find(fileName == ':'))
        fullName = [obj.paras1.path fileName];
    else
        fullName = fileName;
    end
    copyfile(obj.paras1.file,fullName);
    [values names]= xlsread(fullName);
    
    newNames = paras.names;
    newValues = paras.values;
    
    tempValue = zeros(size(values));
    for iN = 1:length(names)
        tempName = names{iN};
        temp = strcmp(tempName,newNames);
        tempLocation = find(temp == 1);
        tempValue(iN,1) = newValues(tempLocation);
    end
    
    xlswrite(fullName,tempValue,1,'B1')
end