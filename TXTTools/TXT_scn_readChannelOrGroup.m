% 读出当前filename单个txt文件的channeNames：各通道名称，包括空数据通道；channelData：各通道的数据

function [channelData channelNames] = TDMS_scn_readChannelOrGroup(filepath,fileName)

    TXT_channeNames = 'EXC,X1,Y1,Z1,X2,Y2,PX1,NX1,PY1,NY1,PZ,NZ,PX2,NX2,PY2,NY2,time,speed,rotor_angle';

    channelNames = strsplit(TXT_channeNames, ',');
    

%---------------读取对应文件的原始数据-----------------%
        % 读入txt数据文件
    filePathName = strcat(filepath,fileName);

    fid = fopen(filePathName, 'r');
    txt_data = fread(fid, '*char');
    fclose(fid);    
%---------------读取对应文件的原始数据-----------------%
    
%---------------- 定义参数----------------------------%

%----------1. 定义参数--txt文件中每条数据各部分的定义和起始位置~结束位置-----%
    chars_per_record = 2944; % 每条数据包含的字符数

    tt_sec = 8; % 每条数据中-时间戳-的字符数

    tt_100u_sec = 4; % 每条数据中-100微妙时间戳-的字符数

    Unused_characters_1 = 16; % 每条数据中-保留-的字符数

    AD_RAW = 2880; % 每条数据中-通道数据段-的字符数
    channel_data_all_channle_points = 64; % 每个通道数据段中-单个数据点-的字符数
    channel_data_single_channle_points = 4; % 每个数据点上-单个通道对应-的字符数
    channelNum = channel_data_all_channle_points/channel_data_single_channle_points; % 每个数据点上包含的通道个数 = 16
    channel_points_per_record = AD_RAW/channel_data_all_channle_points ; % 每个通道数据段中-包含的数据点-的个数 = 45

    speed_hz = 8; % 每条数据中-速度数据-的字符数

    rotor_angle_rad = 8; % 每条数据中-转子角度-的字符数

    Unused_characters_2 = 20; % 每条数据中-保留-的字符数

%----------2. 定义参数--txt文件定义-----%   
        % 计算
    toal_characters = length(txt_data); % 总的字符数
    total_record = toal_characters / chars_per_record; % 总的数据 条 数
    TXT_channel_total_points = total_record*channel_points_per_record;% 总的单通道数据 点 数


%---------------- 定义参数----------------------------%
%---------------------------------------------------------------------%

% txt_data是一个toal_characters长度的字符串，需要将txt_data变为toal_character行[tt_sec（8个字符）,tt_100u（4个字符）,保留（16个字符）,AD_RAW(45个数据点（64个字符）),speed_hz（8个字符）,rotor_angle_rad（8个字符）,保留（20个字符）]51列的矩阵

    %把字符串变为1*n的矩阵
    txt_data_char_array = char(txt_data)';
    txt_data_char_array = reshape(txt_data_char_array, chars_per_record, toal_characters/chars_per_record)'; % 每一行是一条数据

    % 把每条数据中的各部分提取出来
    %16个通道的各数据通道的缩放系数：
    channel_scale_fa = [1/2048, 1/(32*1000), 1/(32*1000), 1/(32*1000), 1/(32*1000), 1/(32*1000), 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256];    
% %       用除法，避免浮点数问题
%     channel_scale_fa = [2048, (32*1000), (32*1000), (32*1000), (32*1000), (32*1000), 256, 256, 256, 256, 256, 256, 256, 256, 256, 256];        

    tt_sec_array = txt_data_char_array(:,1:tt_sec); % 从txt_data中提取出所有的时间戳数据
    tt_100u_sec_array = txt_data_char_array(:,tt_sec+1:tt_sec+tt_100u_sec); % 从txt_data中提取出所有的100微妙时间戳数据
    Unused_characters_1_array = txt_data_char_array(:,tt_sec+tt_100u_sec+1:tt_sec+tt_100u_sec+Unused_characters_1); % 从txt_data中提取出所有的保留数据
    AD_RAW_array = txt_data_char_array(:,tt_sec+tt_100u_sec+Unused_characters_1+1:tt_sec+tt_100u_sec+Unused_characters_1+AD_RAW); % 从txt_data中提取出所有的通道数据段数据
    
    % 需要把数据依次放入AD_RAW_array_cell的每一行中   
        % 将条数（13275）*字符数（2880）的矩阵AD_RAW_array 重塑为行数（9558000）*字符数（4）的矩阵（使得每一行都是一个数据点，便于后续进行高低位调整和进制转换）
    AD_RAW_array = reshape(AD_RAW_array', 4, total_record*channelNum*channel_points_per_record)'; % 每一行是一个数据点(4字符)    

    speed_hz_array = txt_data_char_array(:,tt_sec+tt_100u_sec+Unused_characters_1+AD_RAW+1:tt_sec+tt_100u_sec+Unused_characters_1+AD_RAW+speed_hz); % 从txt_data中提取出所有的速度数据
    rotor_angle_rad_array = txt_data_char_array(:,tt_sec+tt_100u_sec+Unused_characters_1+AD_RAW+speed_hz+1:tt_sec+tt_100u_sec+Unused_characters_1+AD_RAW+speed_hz+rotor_angle_rad); % 从txt_data中提取出所有的转子角度数据
    Unused_characters_2_array = txt_data_char_array(:,tt_sec+tt_100u_sec+Unused_characters_1+AD_RAW+speed_hz+rotor_angle_rad+1:tt_sec+tt_100u_sec+Unused_characters_1+AD_RAW+speed_hz+rotor_angle_rad+Unused_characters_2); % 从txt_data中提取出所有的保留数据

    % 调整各部分的顺序（每列的每相邻两个字符为一位，地位在前，高位在后，现在需要变成高位在前，低位在后），让后每列前后加上'0x'，'u32'，然后再转换为10进制数，存入*_dec_array中
        % tt_sec_array
    tt_sec_array = [tt_sec_array(:,7:8), tt_sec_array(:,5:6), tt_sec_array(:,3:4), tt_sec_array(:,1:2)];
    tt_sec_array = strcat('0x', tt_sec_array, 'u32');
    tt_sec_dec_array = hex2dec(tt_sec_array)/1; % 除以1是缩放系数

        % tt_100u_sec_array
    tt_100u_sec_array = [tt_100u_sec_array(:,3:4), tt_100u_sec_array(:,1:2)];
    tt_100u_sec_array = strcat('0x', tt_100u_sec_array, 'u16');
    tt_100u_sec_dec_array = hex2dec(tt_100u_sec_array)/1;

        % AD_RAW_array
    AD_RAW_array = [AD_RAW_array(:,3:4), AD_RAW_array(:,1:2)];
    %AD_RAW_array = strcat('0x', AD_RAW_array, 's16');
    AD_RAW_dec_array = hex2dec(AD_RAW_array);
    AD_RAW_dec_array = typecast(uint16(AD_RAW_dec_array), 'int16');
    AD_RAW_dec_array = double(AD_RAW_dec_array);

        %重构，变为每一列对应一个通道在该txt文件中的所有数据点数
    AD_RAW_dec_array = reshape(AD_RAW_dec_array, channelNum, total_record*channel_points_per_record)'; 

        %按物理意义，对各通道（各列）的数据进行缩放
    for i = 1:channelNum
        AD_RAW_dec_array(:,i) = AD_RAW_dec_array(:,i)*channel_scale_fa(i);
%         AD_RAW_dec_array(:,i) = AD_RAW_dec_array(:,i)/channel_scale_fa(i);
    end
    % 将AD_RAW_dec_array的每一列都单独按列展开为一维数组
    AD_RAW_dec = zeros(channelNum, total_record*channel_points_per_record);
    for i = 1:channelNum
        AD_RAW_dec(i,:) = reshape(AD_RAW_dec_array(:,i), 1, total_record*channel_points_per_record);
    end



    % speed_hz_array
    speed_hz_array = [speed_hz_array(:,7:8), speed_hz_array(:,5:6), speed_hz_array(:,3:4), speed_hz_array(:,1:2)];
    speed_hz_dec_array = hex2num(speed_hz_array)/1;

    % rotor_angle_rad_array
    rotor_angle_rad_array = [rotor_angle_rad_array(:,7:8), rotor_angle_rad_array(:,5:6), rotor_angle_rad_array(:,3:4), rotor_angle_rad_array(:,1:2)];
    rotor_angle_rad_dec_array = hex2num(rotor_angle_rad_array)/1;
    
    %------------到此，已读取所有数据，并且已为对应的物理量-----------------%
    %---------------------------------------------------------------------%



%------------人为计算量：time、speed、rotor_angle-----------------%
    % time
    time_temp = tt_sec_dec_array + tt_100u_sec_dec_array/1000000*100; % 每个数据点的采集时间（人为平均计算）;/1000000*100用于 100微秒 单位转换为 秒
    time = zeros(length(time_temp), channel_points_per_record); % 每个数据点的采集时间（人为平均计算）
    average_time_per_point = zeros(length(time_temp),1); % 每个数据点的平均采集时间（人为平均计算）
    
    time(:,1) = time_temp; % 第1个数据点的采集时间（人为平均计算）
    time(1:end-1,end) = time(2:end,1); % 第2个数据点的采集时间（人为平均计算） = 第2个数据点的采集时间（人为平均计算） - 第1个数据点的采集时间（人为平均计算）

    if total_record < 2
        msgbox('文件内仅有一条数据，无法计算采集时间点！')        
    end
    average_time_per_point(1:end-1, 1) = (time(1:end-1,end) - time(1:end-1,1))/(channel_points_per_record); % 每个数据点的平均采集时间（人为平均计算） = （该段的采集时间/该段的数据点数）
    average_time_per_point(end, 1) = average_time_per_point(end-1, 1);
    
    for i = 2:channel_points_per_record
        time(:,i) = time(:,i-1) + average_time_per_point(:,1); % 第i个数据点的采集时间（人为平均计算） = 第i-1个数据点的采集时间（人为平均计算） + 每个数据点的平均采集时间（人为平均计算）
    end 
    

    % 将time按行展开为一维数组
    time = reshape(time', 1, TXT_channel_total_points);

    % speed
    speed_temp = speed_hz_dec_array; % 转换为转/分
    speed = zeros(length(speed_temp), channel_points_per_record); % 每个数据点的转速
    average_speed_per_point = zeros(length(speed_temp),1); % 每个数据点的平均转速

    speed(:,1) = speed_temp; % 第1个数据点的转速
    speed(1:end-1,end) = speed(2:end,1); % 第2个数据点的转速 = 第2个数据点的转速 - 第1个数据点的转速

    average_speed_per_point(1:end-1, 1) = (speed(1:end-1,end) - speed(1:end-1,1))/(channel_points_per_record); % 每个数据点的平均转速 = （该段的转速/该段的数据点数）
    average_speed_per_point(end, 1) = average_speed_per_point(end-1, 1);

    for i = 2:channel_points_per_record
        speed(:,i) = speed(:,i-1) + average_speed_per_point(:,1); % 第i个数据点的转速 = 第i-1个数据点的转速 + 每个数据点的平均转速
    end
    % 将speed按行展开为一维数组
    speed = reshape(speed', 1, TXT_channel_total_points);    

    % rotor_angle
    rotor_angle_temp = rotor_angle_rad_dec_array; % 转换为弧度
    rotor_angle = zeros(length(rotor_angle_temp), channel_points_per_record); % 每个数据点的转子角度
    average_rotor_angle_per_point = zeros(length(rotor_angle_temp),1); % 每个数据点的平均转子角度

    rotor_angle(:,1) = rotor_angle_temp; % 第1个数据点的转子角度
    rotor_angle(1:end-1,end) = rotor_angle(2:end,1); % 第2个数据点的转子角度 = 第2个数据点的转子角度 - 第1个数据点的转子角度

    average_rotor_angle_per_point(1:end-1, 1) = (rotor_angle(1:end-1,end) - rotor_angle(1:end-1,1))/(channel_points_per_record); % 每个数据点的平均转子角度 = （该段的转子角度/该段的数据点数）
    average_rotor_angle_per_point(end, 1) = average_rotor_angle_per_point(end-1, 1);

    for i = 2:channel_points_per_record
        rotor_angle(:,i) = rotor_angle(:,i-1) + average_rotor_angle_per_point(:,1); % 第i个数据点的转子角度 = 第i-1个数据点的转子角度 + 每个数据点的平均转子角度
    end
    % 将rotor_angle按行展开为一维数组
    rotor_angle = reshape(rotor_angle', 1, TXT_channel_total_points);

%------------人为计算量：time、speed、rotor_angle-----------------%
%---------------------------------------------------------------------%


%-----------将数据通道的值都归一化到-5~5V之间（为了与tdms的显示一致）-------------------------%
%     % 将AD_RAW_dec的每一行的元素都单独归一化到-5~5V之间
%     for i = 1:channelNum
%         AD_RAW_dec(i,:) = AD_RAW_dec(i,:)/max(abs(AD_RAW_dec(i,:)))*5;
%     end


%--------------------------将所有数据输出：channelData-------------------------%
    channelData_temp = zeros(length(channelNames), TXT_channel_total_points);

    for i = 1:channelNum
        channelData_temp(i,:) = AD_RAW_dec(i,:); % 将AD_RAW_dec_array的每一列都单独按列展开为一维数组
    end

    channelData_temp(end-2,:) = time; % 将time按行展开为一维数组
    channelData_temp(end-1,:) = speed; % 将speed按行展开为一维数组
    channelData_temp(end,:) = rotor_angle; % 将rotor_angle按行展开为一维数组

    % 将channelData的每一行都合并为一个元素，存入channelData_cell中
    channelData_cell = cell(1, length(channelNames));

    for i = 1:length(channelNames)
        channelData_cell{1,i} = channelData_temp(i,:);
    end

    channelData = channelData_cell;

%--------------------------将所有数据输出：channelData-------------------------%
%---------------------------------------------------------------------%


    
    
end
