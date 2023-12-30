function status_damage_value_temp = matpy1()
    % 加载模型
    %amb_autoencoder = py.importlib.import_module('amb_autoencoder');
    %py.importlib.reload(amb_autoencoder);
    
    mymod = py.importlib.import_module('anomaly_detection_auto_mat');  % 不要带py后缀,不然报错
    py.importlib.reload(mymod); % 重新加载模块，实时更新

    status_damage_value_temp = mymod.mat_anomaly_detection();

    %status_value_temp = py.anomaly_detection_auto_mat.mat_anomaly_detection();
     
end



