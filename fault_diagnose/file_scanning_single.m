classdef FileScanning
% 用于扫描这一批文件

%{
参数说明：
1.输入
    set_vibration_threshold：用于读取设置的参数(振动阈值设置)
    set_scanning_sensitivity：用于读取设置的参数(敏感度阈值设置)
    filename：所有要读取的文件名
    filepath：当前要读取的这批文件所在的文件夹的绝对路径

2.返回
    file_scanning_total_points：整体扫描结果
    filen__scanning_serious_fault_points：严重故障点的个数
    filen__scanning_suspected_fault_points：疑似故障点的个数

%}
    properties
        filename_serious_suspected; % 用于整体扫描结果显示框：'文件名_严重故障点百分比_疑似故障点百分比'
        filename_serious_suspected_fault_points; % 用于严重故障-数据文件显示框：'文件名_严重故障点个数_疑似故障点个数'
        filen__scanning_suspected_fault_points; % 用于疑似故障-数据文件显示框：'文件名_严重故障点个数_疑似故障点个数'
        num_normal_files; % 正常文件的个数
        num_serious_files; % 严重故障文件的个数
        num_suspected_files; % 疑似故障文件的个数
    end

    methods
        function obj = FileScanning(set_vibration_threshold,set_scanning_sensitivity,filename,filepath)

            % 显示扫描
            h = waitbar(1/length(filename),'正在全域扫描诊断','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            setappdata(h,'canceling',0);

            for i = 1:length(filename)
                          
                %进度条 添加 2023.11.30
                str = ['扫描中...',num2str(i/length(filename)*100),'%'];
                waitbar(i/length(filename),h,str);

                if getappdata(h,'canceling') % 如果在中途取消了扫描                         
                    delete(h);                    
                    msgbox('全域扫描已取消！','注意：','warn');                    
                    return
                end
               

            
                if i == length(filename) % 扫描完成

                end


            end

            delete(h);
            msgbox('全域扫描诊断完成');
 







            %{
            参数说明：
            1.输入
                app：用于读取设置的参数
                filename：单个文件的文件名
                filepath：当前要读取的单个文件所在文件夹的绝对路径

            2.返回
                file_scanning_total_points：当前读取的单个文件所包含的总的数据点的个数
                filen__scanning_serious_fault_points：严重故障点的个数
                filen__scanning_suspected_fault_points：疑似故障点的个数

            %}
            %{
            1.读取设置的参数
            %}
            %{
            2.读取单个文件
            %}
            %{
            3.计算总的数据点的个数
            %}
            %{
            4.计算严重故障点的个数
            %}
            %{
            5.计算疑似故障点的个数
            %}
            %{
            6.返回
            %}
        end

    
    end















end



