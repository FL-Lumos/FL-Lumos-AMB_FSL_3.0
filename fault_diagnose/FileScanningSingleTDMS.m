classdef FileScanningSingleTDMS
    % 用于扫描单个 TXT 文件
    
    %{
    参数说明：
    1.输入
        
        scn_mode：用于读取设 扫描模式 % 2023.12.30：3.0版本中，不再使用通道数模式切换，这个变量暂时保留，但是不再使用

        scn_channel：用于读取 待检测的通道（通道时默认顺序：x1, y1, x2, y2, z，...）
        scn_channel_max：用于读取 待检测的通道的设计最大值
        scn_serious_threshold：用于读取 严重阈值设
        scn_suspected_threshold：用于读取 疑似阈值设
        set_scanning_sensitivity：用于读取设置的参数(敏感度阈值设置)
        filename：所有要读取的文件名
        filepath：当前要读取的这批文件所在的文件夹的绝对路径
    
    2.返回
        file_total_points：文件的总的数据点的个数
        file__scanning_serious_fault_points：严重故障点的个数
        file__scanning_suspected_fault_points：疑似故障点的个数
        status_label：扫描状态(1：正常，2：严重故障，3：疑似故障)
    
    %}
    properties
        file_total_points % 文件的总的数据点的个数
        file__scanning_serious_fault_points % 严重故障点的个数
        file__scanning_suspected_fault_points % 疑似故障点的个数
        status_label % 扫描状态(1：正常，2：严重故障，3：疑似故障)
        filename_sus_ser_display % 字符串 用于显示的文件名 “文件名_疑似故障点数百分比_严重故障点数百分比”                    
    end

    methods
        function obj = FileScanningSingleTDMS(scn_mode,scn_channel,scn_channel_max,scn_serious_threshold,scn_suspected_threshold,set_scanning_sensitivity,filename,filepath) % 类的构造函数，用于初始化类的属性
            % 读入单个txt文件的数据
            if filepath(end) ~='\'
                filepath = [filepath '\'];
            end
            fileName = [filepath filename];

            [a,b] = TDMS_readTDMSFile(fileName);
            [channelData channelNames] = TDMS_readChannelOrGroup(fileName,a.groupNames); 

            % 读取文件的总的数据点的个数
            obj.file_total_points = length(channelData{1});

            % 参数格式转换：参数都是字符串数组，数字字符之间用逗号隔离，所以要先分离出单个数字字符
            scn_channel = strsplit(scn_channel,',');
            scn_channel_max = strsplit(scn_channel_max,',');
            scn_serious_threshold = strsplit(scn_serious_threshold,',');
            scn_suspected_threshold = strsplit(scn_suspected_threshold,',');
            set_scanning_sensitivity = strsplit(set_scanning_sensitivity,',');

            % 读取待检测的通道（通道时默认顺序：x1, y1, x2, y2, z，...）
                % scn_channe

            j = 1;
            channelData_scn = zeros(length(scn_channel),obj.file_total_points);
%             channelData_scn(:) = {0};
            channelData_scn_serious = zeros(length(scn_channel),obj.file_total_points);
%             channelData_scn_serious(:) = {0};
            channelData_scn_suspected = zeros(length(scn_channel),obj.file_total_points);
%             channelData_scn_suspected(:) = {0};

            for i = scn_channel
                channelData_scn(j,:) = channelData{1,str2num(i{1})};

                %严重
                % channelData_scn这一行的数据统一除（str2num(scn_channel_max(j))*str2num(scn_serious_threshold(j))）取余
                channelData_scn_serious(j,:) = floor(abs(channelData_scn(j,:))/(str2num(scn_channel_max{j})*str2num(scn_serious_threshold{j})));
                % channelData_scn是数组，将这一行的元素非零的位置的元素置为1
                channelData_scn_serious(j,find(channelData_scn_serious(j,:) ~= 0)) = 1;

                %疑似
                channelData_scn_suspected(j,:) = floor(abs(channelData_scn(j,:))/(str2num(scn_channel_max{j})*str2num(scn_suspected_threshold{j})));
                channelData_scn_suspected(j,find(channelData_scn_suspected(j,:) ~= 0)) = 1;
                
                j = j + 1;
            end

            % 将channelData_scn_serious和channelData_scn_suspected的每一行的数据相加，得到每一行的数据的和
            channelData_scn_serious_result = zeros(1,obj.file_total_points);
            channelData_scn_suspected_result = zeros(1,obj.file_total_points);
            channelData_scn_serious_result = sum(channelData_scn_serious);
            channelData_scn_suspected_result = sum(channelData_scn_suspected);

            % 严重故障点的个数
            obj.file__scanning_serious_fault_points = length(find(channelData_scn_serious_result >= 1));
            % 疑似故障点的个数
            obj.file__scanning_suspected_fault_points = length(find(channelData_scn_suspected_result >= 1));
            obj.file__scanning_suspected_fault_points = obj.file__scanning_suspected_fault_points - obj.file__scanning_serious_fault_points;


            % 扫描状态(1：正常，2：疑似故障，3：严重故障)
            if obj.file__scanning_serious_fault_points/obj.file_total_points > str2num(set_scanning_sensitivity{2}) % 根据敏感度的第一位先判断 是否存在严重故障
                obj.status_label = 3;
            elseif (obj.file__scanning_suspected_fault_points+obj.file__scanning_serious_fault_points)/obj.file_total_points > str2num(set_scanning_sensitivity{1}) % 根据敏感度的第二位再判断 是否存在疑似故障
                obj.status_label = 2;
            else
                obj.status_label = 1;
            end          

            % 字符串 用于显示的文件名 “文件名_疑似故障点数百分比_严重故障点数百分比”（其中百分比到小数点后3为，没有的也用空格将字符位补全）
            obj.filename_sus_ser_display = [filename '_' num2str(obj.file__scanning_suspected_fault_points/obj.file_total_points*100,'%0.3f') '%_' num2str(obj.file__scanning_serious_fault_points/obj.file_total_points*100,'%0.3f') '%'];
            
        
        end

    end
    

    
end
    
    
    
    