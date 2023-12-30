%ControlParas类的成员方法
%20190426
%功能：打印所有属性、方法的功能

function Help(obj)
    %基本模型
    disp('GetParaValue——获取指定名称的控制参数值');
    disp('PIDModel——构建指定通道的PID模型');
    disp('FrequencyModel——从扫频数据中获取闭环传递函数');
    disp('RotorModel——解算开环转子模型（不包括控制器）');
    
    %计算操作
    disp('BDPlot——画出不同组件的波特图')
    disp('CP2——关闭控制参数中的滤波器通道，微分整形通道')
    disp('ReadParas——读入控制参数，可以初始化paras1或者paras2')
    disp('ReadFreqs——读入扫频文件，可以初始化freqs')
    
    %调试操作
    disp('SP——生成用于扫频的五组参数');
    disp('Sensor——将传感器标定的数值直接写入到控制参数中，务必将数值页放到Excel表格中的第1页');
    disp('VF——用于验证控制参数是否可烧写到DSP中')
    disp('CP——清理控制参数中的调试项，用于烧写！')
    disp('Save2CSV——将参数保存CSV文件中')
    
    
%     from keras.utils import np_utils
%     from keras.models import Sequential
%     from keras.layers import Dense, Activation, Convolution2D, MaxPooling2D, Flatten
%     from keras.optimizers import Adam

end