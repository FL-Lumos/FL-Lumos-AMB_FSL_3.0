function matpy2()
    % 加载模型
    
    mymod = py.importlib.import_module('draw_auto_result');  % 不要带py后缀,不然报错
    py.importlib.reload(mymod); % 重新加载模块，实时更新

    mymod.plt_auto_result();

     
end



