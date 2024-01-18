
% 设置原始 CSV 文件路径和新文件名
originalCsvFilePath = fullfile('D:\DTOOL\科研\课题-升降速异常检测\智能故障检测_离线扫描定位软件\AMB_FSL_3.0\SetData.csv');
newCsvFileName = 'SetData_temp.csv';

tempCsvFilePath = 'temp_SetData_temp.csv';

% 复制原始 CSV 文件并改名
copyfile(originalCsvFilePath, tempCsvFilePath, 'f');

% 移动新 CSV 文件到 .\config 文件夹
movefile(tempCsvFilePath, fullfile('D:\DTOOL\科研\课题-升降速异常检测\智能故障检测_离线扫描定位软件\AMB_FSL_3.0\config\', newCsvFileName), 'f');