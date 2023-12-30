%{
错误代码说明：
parameter_status = 1; % 1：参数输入正确
parameter_status = 2; % 2：输入参数格式错误
parameter_status = 3; % 3：“参考最值”个数与“待检测通道数”不符合
parameter_status = 4; % 4：“疑似阈值”个数与“待检测通道数”不符合
parameter_status = 5; % 5：“严重阈值”个数与“待检测通道数”不符合
parameter_status = 6; % 6：“扫描灵敏度”个数只能为2个
parameter_status = 7; % 7：“扫描灵敏度”个数只能为1个
%}

% 状态代码
parameter_status = '1'; % 1：参数输入正确

% 代码说明(带上分行符)
parameter_status_Interpretation = ['1：参数输入正确',newline,...
                                   '2：输入参数格式错误',newline,...
                                   '3：“参考最值”个数与“待检测通道数”不符合',newline,...
                                   '4：“疑似阈值”个数与“待检测通道数”不符合',newline,...
                                   '5：“严重阈值”个数与“待检测通道数”不符合',newline,...
                                   '6：“扫描灵敏度”个数只能为2个',newline,...
                                   '7：“扫描灵敏度”个数只能为1个',newline];



scn_channel = strsplit(app.scn_channel.Value,',');
scn_channel = str2double(scn_channel) % 如果原始字符串包含非数字字符或空格，str2double 会在那些位置生成 NaN（Not a Number）
scn_channel_max = strsplit(app.scn_channel_max.Value,',');
scn_channel_max = str2double(scn_channel_max)
scn_suspected_threshold = strsplit(app.scn_suspected_threshold.Value,',');
scn_suspected_threshold = str2double(scn_suspected_threshold)
scn_serious_threshold = strsplit(app.scn_serious_threshold.Value,',');
scn_serious_threshold = str2double(scn_serious_threshold)
set_scanning_sensitivity = strsplit(app.set_scanning_sensitivity.Value,',');
set_scanning_sensitivity = str2double(set_scanning_sensitivity)
set_scanning_density = str2double(app.set_scanning_density.Value)
set_scanning_time = str2double(app.set_scanning_time.Value)

% 检测是否有非数字字符
if any(isnan(scn_channel)) || any(isnan(scn_channel_max)) || any(isnan(scn_suspected_threshold)) || any(isnan(scn_serious_threshold)) || any(isnan(set_scanning_sensitivity))
    parameter_status = [parameter_status,'/2'];
else
    if length(scn_channel) ~= length(scn_channel_max)
        parameter_status = [parameter_status,'/3'];
    end
    if length(scn_channel) ~= length(scn_suspected_threshold)
        parameter_status = [parameter_status,'/4'];
    end
    if length(scn_channel) ~= length(scn_serious_threshold)
        parameter_status = [parameter_status,'/5'];
    end
    if length(set_scanning_sensitivity) == 2
        parameter_status = [parameter_status,'/6'];
    end
    if length(set_scanning_sensitivity) == 1
        parameter_status = [parameter_status,'/7'];
    end      

end

if length(parameter_status) > 1
    % 在msgbox弹窗中显示错误信息以及错误代码和错误代码说明
    msgbox(['参数输入错误，错误代码：',parameter_status_Interpretation,newline,'错误代码：',parameter_status],'错误','error');   
else
    parameter_status = str2double(parameter_status)
end


