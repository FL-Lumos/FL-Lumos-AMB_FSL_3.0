% 读出当前filename单个txt文件的channeNames：各通道名称，包括空数据通道；channelData：各通道的数据

function  cal_result = TXT_Calculator(txt_data)
%-----------------------获取数据----------------------------------------------%
txt_data = txt_data{:}; % 将cell数组转换为字符串


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
    txt_data_char_array = txt_data;

    % 把每条数据中的各部分提取出来
    %16个通道的各数据通道的缩放系数：
    channel_scale_fa = [1/2048, 1/32, 1/32, 1/32, 1/32, 1/32, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256, 1/256];    

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
            % 将tt_sec_array由 秒 转换为 08-Nov-2023 10:36:26 格式
    seconds_since_epoch = tt_sec_dec_array;    
            % 计算起始时间（1970年1月1日）
    start_time = datetime(1970, 1, 1, 0, 0, 0);    
            % 将秒数加到起始时间，得到指定时间点
    specified_time = start_time + seconds(seconds_since_epoch);
            % 由'datetime'类型变为str类型数据
    tt_sec_dec_array = datestr(specified_time);
    


        % tt_100u_sec_array
    tt_100u_sec_array = [tt_100u_sec_array(:,3:4), tt_100u_sec_array(:,1:2)];
    tt_100u_sec_array = strcat('0x', tt_100u_sec_array, 'u16');
    tt_100u_sec_dec_array = hex2dec(tt_100u_sec_array)/10000;

        % AD_RAW_array
    AD_RAW_array = [AD_RAW_array(:,3:4), AD_RAW_array(:,1:2)];
    %AD_RAW_array = strcat('0x', AD_RAW_array, 's16');
    AD_RAW_dec_array = hex2dec(AD_RAW_array);
    AD_RAW_dec_array = typecast(uint16(AD_RAW_dec_array), 'int16');
    % 再把AD_RAW_dec_array变为double类型
    AD_RAW_dec_array = double(AD_RAW_dec_array);

        %重构，变为每一列对应一个通道在该txt文件中的所有数据点数
    AD_RAW_dec_array = reshape(AD_RAW_dec_array, channelNum, total_record*channel_points_per_record)'; 

        %按物理意义，对各通道（各列）的数据进行缩放
    for i = 1:channelNum
        AD_RAW_dec_array(:,i) = AD_RAW_dec_array(:,i)*channel_scale_fa(i);
    end
    % 将AD_RAW_dec_array的每一列都单独按列展开为一维数组
    AD_RAW_dec = zeros(channelNum, total_record*channel_points_per_record);
    for i = 1:channelNum
        AD_RAW_dec(i,:) = reshape(AD_RAW_dec_array(:,i), 1, total_record*channel_points_per_record);
    end



    % speed_hz_array
    speed_hz_array = [speed_hz_array(:,7:8), speed_hz_array(:,5:6), speed_hz_array(:,3:4), speed_hz_array(:,1:2)];
    % speed_hz_dec_array = hex2num(speed_hz_array)/1;% 示例代码这里给错了，因为这里是个单精度数，而hex2num直接转是要输入双进度的，说以这里不能直接转换。
    speed_hz_dec_array = typecast(uint32(hex2dec(speed_hz_array)),'single')/1;

    % rotor_angle_rad_array
    rotor_angle_rad_array = [rotor_angle_rad_array(:,7:8), rotor_angle_rad_array(:,5:6), rotor_angle_rad_array(:,3:4), rotor_angle_rad_array(:,1:2)];
    % rotor_angle_rad_dec_array = hex2num(rotor_angle_rad_array)/1; % 示例代码这里给错了，因为这里是个单精度数，而hex2num直接转是要输入双进度的，说以这里不能直接转换。
    rotor_angle_rad_dec_array = typecast(uint32(hex2dec(rotor_angle_rad_array)),'single')/1;

    %------------到此，已读取所有数据，并且已为对应的物理量-----------------%
    %---------------------------------------------------------------------%



%--------------------------将所有数据输出：channelData-------------------------%



    cell_result = cell(1, 5);

    cal_result = struct('tt_sec', tt_sec_dec_array, 'tt_100u_sec', tt_100u_sec_dec_array, 'AD_RAW', AD_RAW_dec, 'speed_hz', speed_hz_dec_array, 'rotor_angle_rad', rotor_angle_rad_dec_array);


%--------------------------将所有数据输出：channelData-------------------------%
%---------------------------------------------------------------------%


    
    
end
