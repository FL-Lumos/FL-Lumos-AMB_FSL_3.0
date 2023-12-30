% 从每个64字符的AD_RAW中的每个通道recordData~startIdx提取对应的数据

function channel_data_single_channle = TXT_extractChannelData(record_point_channel_data, channel_data_single_channle_points)
    
    % 重新排列通道数据以匹配数据点结构(前半部分为字符为16进制低位，后半部分为16进制低位高位,说以要前后字符部分对调)
    channelData = [record_point_channel_data(channel_data_single_channle_points/2+1:channel_data_single_channle_points), record_point_channel_data(1:channel_data_single_channle_points/2)];

    % 将每个数据点的十六进制(带+/-符号)数据转换为十进制
        
    decimalValue = hex2dec(channelData);

        % 使用typecast将无符号整数转换为带符号整数（假设是int16类型）
    channel_data_single_channle  = typecast(uint16(decimalValue), 'int16');
    
end