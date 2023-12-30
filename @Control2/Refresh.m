%将pid的参数更新到pid模型中
%20200528

function obj = Refresh(obj,num,values)          
    if num == 1
        obj.paras1.values = values;
        obj = GetModel(obj,'pid');
    else
        obj.paras2.values = values;
        obj = GetModel(obj,'pid',2);
    end
end