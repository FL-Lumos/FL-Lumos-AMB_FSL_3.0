function save_file_scan_result(app, save_file_name, File_scan_results)
    try
        % 先检测要保存的内容是否为空
        if isempty(File_scan_results)
            return
        end
        % 获取当前时间戳
        time_stamp = datestr(now, 'yyyymmddHHMMSS');
        % 生成文件名
        file_name = [save_file_name, time_stamp, '.txt'];
        % 生成文件路径
        if app.save_resul_path.Value(end) == '\'
            file_path = fullfile(app.save_resul_path.Value, file_name);
        else
            file_path = fullfile(app.save_resul_path.Value, '\', file_name);
        end

        % 保存文件内容
        fid = fopen(file_path, 'w');
        for i = 1:length(File_scan_results)
            fprintf(fid, '%s\n', File_scan_results{i});
        end
        fclose(fid);

        msgbox('扫描结果保存成功');
    catch
        msgbox('扫描结果保存失败');
    end
    
end