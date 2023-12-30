%Control2中的初始化读入参数文件
%2019-04-25
%更新时间为20190606
%20210415 增加对新版参数（无模板）的支持

function obj = ReadParas(obj,num,parasFile)
%     parasFile = obj.parasFile;
    paraTemplate = obj.paraTemplate;
    if nargin < 3
        parasFile = [];
        if nargin == 1
            num = 1;
        end
    end
    
    %如果输入参数parasFile是[]，则弹出对话框读入参数
    if isempty(parasFile) == 1
        [fileName,pathName] = uigetfile({'*.csv'},'选择控制参数文件');
        parasFile = [pathName fileName];  
    end
    
    %从新控制参数文件中读入
    try 
        tempData = importdata(parasFile);
    catch
        return
    end
    
    paraNames = tempData.textdata;
    paraValues = tempData.data;
    
    paraTypes = zeros(length(paraValues),5);
    
    %为paraTypes赋值
    templateNames = paraTemplate.str(:,1);
    templateTypes = paraTemplate.type;
    paraOrder = zeros(size(paraValues));
    
    
    %20210415 增加对新版参数的支持，首先判断是否是旧版参数
    num1 = length(paraValues);    %读入的参数个数
    num2 = length(templateTypes); %旧版模板的参数个数
    
    if num1 == num2    
        for iT = 1:length(templateNames)
            tempName = paraNames(iT,1);  %选取新文件中的一个参数
            paraOrder(iT,1) = strmatch(tempName,templateNames,'exact'); %在模板中匹配
        end

        paraTypes = templateTypes(paraOrder,:); 

        paras.names = paraNames;
        paras.types = paraTypes;
        paras.values = paraValues;
        paras.channels = paraTemplate.channels;
        paras.dataTypes = paraTemplate.dataTypes;
        paras.paraTypes = paraTemplate.paraTypes;
        paras.info = ['names为参数名称；' 10 'type中分别是参数序号、参数类型、通道类型、数据类型、组内序号；' 10 'channels为type中数字对应的通道名称；' 10 'paraTypes为type中数字对应的参数类型；' 10 'dataTypes为type中数字对应的数据类型；' 10 'file为参数文件的路径与文件名'];
    else
        paras.names = paraNames;
        paras.values = paraValues;
        paras.channels = paraTemplate.channels;
    end
      
    %20190606
    paras.file = parasFile;
    %20190807 增加路径识别
    p1 = find(parasFile == '\');
    if isempty(p1) == 1
        paras.path = [cd '\'];
    else
        p2 = p1(end);
        paras.path = parasFile(1:p2);
    end
    

    %20190606更新
    if num == 1
        obj.paras1 = paras;
        obj = GetModel(obj,'pid');
    else
        obj.paras2 = paras;
        obj = GetModel(obj,'pid',2);
    end
%     obj.paras = paras;
end