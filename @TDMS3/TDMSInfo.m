%2023.12.26
%增加对于txt文件的支持
%20200815
%增加filePoints和totalTime在本函数中幅值
%20200520
%基于TDMS2中的TDMSInfo进行改造，只关注第1个文件的信息
%20190702
%函数功能:TDMS的类函数，用于读取tdms文件数据的基本信息

function obj = TDMSInfo(obj)
    fileNames = obj.fileNames;
    filePath = obj.filePath;
            
    fileNum = length(fileNames); % 一共需要读取多少的文件个数

%------------1.读入这一批文件的信息（基于第一个TDMS、txt文件提取相关信息）--------------------%
    sampling = 0;
    fileName = fileNames{1,1};
    fileName = [filePath fileName];

    if isequal(fileName(end-2:end),'dms') % 如果是读入的tdms文件，就调用之前的方法

% 1.1获取：channeNames%各通道名称，包括空数据通道；channelData：各通道的具体数据
   
        [a,b] = TDMS_readTDMSFile(fileName); %a,b中存有tdms数据的信息
        %channelData channeNames都是cell格式
        [channelData channelNames2] = TDMS_readChannelOrGroup(fileName,a.groupNames); %读取tdms文件的数据，channelData=1*n的cell n为通道数，其中每行的元素都包含了对应通道的所有数据，channelNames2是n个通道的名字
        num = length(channelData); %通道个数
        channels = [];
        
        channels = zeros(1,num);
        channelNames = cell(1,num);

        % 依次把channelData这个cell中各通道数据装入channels这个数组中
        for iC = 1:num
            tempData = channelData{1,iC};
            if isempty(tempData) ~= 1 % 该通道是否有数据
                channels(1,iC) = 1;
                channelNames{1,iC} = channelNames2{1,iC};
            end
        end

        obj.channelFlag = channels; % 这是个数组，包含对应位置的这个通道是否是有数据的
        obj.channelNames = channelNames; % 这是个包含通道名称的cell

% 1.2获取：sampling：采样率（通过文件的总时间数据点数（一个时间点就对应了一个数据点）/文件的总时间秒数）；date：数据采集时间（该文件中，第一个数据点的采集时间）
        %找到时间列的位置
        [tx,ty] = find(strcmp(channelNames2, 'Time')); % find找到为1的元素的位置（行tx，列ty）
        if isempty(tx) ~= 1  %如果tx不为空，则存在时间列
            timeData = channelData{tx,ty}; % 内部存储的时间是序列化格式（代表自 0000 年 01 月 01 日00:00以来的天数）
            %采样率：每秒钟的采样点数
            sampling = round((length(timeData)-1)/((timeData(end)-timeData(1))*24*60*60));  %2022.2.28 从公元0年开始（length(timeData)-1，减1是求时间间隔数）
            date = datestr(timeData(1),'yyyy-mm-dd hh:MM:ss');
        end
        obj.sampling = sampling;
        obj.date = date;
%--------------------------------------------------------------------------------------------%

%-----------------------------------2.读入所有文件-------------------------------------------%
        
        %20200815修改,统计每个tdms文件的filePoint，并计算总时间
        %2021.4.20 加入进度条
        h = waitbar(0,'正在读取文件，请稍候!');
        
        filePoints = zeros(1,fileNum);
        for iF = 1:fileNum % 开始依次循环读入这一批次的所有的文件
            tic  % 开始计时

            tempName = fileNames{1,iF};
            tempFullName = [filePath tempName];

            [a,b] = TDMS_readTDMSFile(tempFullName); %a,b中存有tdms数据的信息
            [channelData,channelNames2] = TDMS_readChannelOrGroup(tempFullName,a.groupNames);
            tempID = 1;

            while isempty(channelData{1,tempID}) & tempID < length(channelNames2) % 通过while循环，找到第一个非空的通道数据，确保 tempID 变量指向的通道在后续的处理中包含有效的数据。
                tempID = tempID + 1; 
            end
    %             tempID
            filePoints(1,iF) = length(channelData{1,tempID}); % 单个数据通道中，包含的点的个数（在处理 cell 数组时，使用 {} 通常用于获取 cell 元素的内容，而使用 () 用于获取整个 cell 元素。）
            t = toc;
            [iF t]; % 用于调试的时候观察单个读取的耗时
            
            waitbar(iF/fileNum,h,['已经读取' num2str(iF) '/' num2str(fileNum) '个文件！']);
        end
        
        close(h) % 关闭进度条
        obj.fileNum = fileNum; % 同一批次中，每个文件对应的文件名为一个元素
        obj.filePoints = filePoints; % 同一批次中，每个文件对应的当个数据通道中的数据点数为一个元素
        
        %计算同一批次文件的总时间=求和（单个文件的数据点数）/同一批的采样率
        if obj.sampling > 0
            obj.totalTime =  sum(obj.filePoints)/obj.sampling;  
        else
            obj.totalTime = 0;
        end

%-----------------------------------------------------------------------------------------------------%  
%--------------------2023.12.26 如果读入的是txt文件，就调用新的函数进行信息读取------------------------% 
%-----------------------------------------------------------------------------------------------------% 
    elseif isequal(fileName(end-2:end),'txt') 
       
        % tdms文件输出的关键信息(在txt文件中也要实现）：
        %{
            obj.channelFlag = channels; %各通道标志，1为有数据通道，0为无数据通道
            obj.channelNames = channelNames; %各通道名称，包括空数据通道
            obj.sampling = sampling; %采样率
            obj.date = date; %文件日期
            obj.fileNum = fileNum; %文件数目
            obj.filePoints = filePoints;  %1*fileNum，每个元素为文件点数

        %}
       
% 1.1获取：channeNames：各通道名称，包括空数据通道；channelFlag：各通道的数据有无情况（有：1；无：0）
   
        [channelData, channelNames2] = TXT_readChannelOrGroup(fileName); %a,b中存有tdms数据的信息

        % 依次判断各通道是否存在数据（TXT不存在这个问题，所以按照app_TXT_channelName_Value的长度，全赋1）
        num = length(channelNames2); %通道个数   
        channels = [];        
        channels = ones(1,num);

        obj.channelFlag = channels; % 这是个数组，包含对应位置的这个通道是否是有数据的
        obj.channelNames = channelNames2; % 这是个包含通道名称的cell

% 1.2获取：sampling：采样率（通过文件的总时间数据点数（一个时间点就对应了一个数据点）/文件的总时间秒数）；date：数据采集时间（该文件中，第一个数据点的采集时间）
        %找到时间列的位置
        [tx,ty] = find(strcmp(channelNames2, 'time')); % find找到为1的元素的位置（行tx，列ty）
        if isempty(tx) ~= 1  %如果tx不为空，则存在时间列
            timeData = channelData{tx,ty}; % 内部存储的时间是序列化格式（代表自 0000 年 01 月 01 日00:00以来的天数）
            %采样率：每秒钟的采样点数
            sampling = round((length(timeData)-1)/((timeData(end)-timeData(1))));  %2022.2.28 从公元0年开始（length(timeData)-1，减1是求时间间隔数）

            startTime = datetime(1970,1,1,0,0,0);
                % 将timeData(1)转换为天数
            day_temp = timeData(1)/(24*60*60);
            % 在startTime的基础上加上秒数，得到当前的datetime对象
            currentTime = startTime + day_temp;
            % 将currentTime格式化为yyyy-mm-dd hh:MM:ss的字符串
            date = datestr(currentTime,'yyyy-mm-dd HH:MM:SS')

            % 将经过时间转换为datetime对象

        end
        obj.sampling = sampling;
        obj.date = date;
%--------------------------------------------------------------------------------------------%

%-----------------------------------2.读入所有文件-------------------------------------------%
        
        %20200815修改,统计每个tdms文件的filePoint，并计算总时间
        %2021.4.20 加入进度条
        h = waitbar(0,'正在读取文件，请稍候!');
        
        filePoints = zeros(1,fileNum);
        for iF = 1:fileNum % 开始依次循环读入这一批次的所有的文件
            tic  % 开始计时

            tempName = fileNames{1,iF};
            tempFullName = [filePath tempName];

            [channelData,channelNames2] = TXT_readChannelOrGroup(fileName);
            tempID = 1;

            while isempty(channelData{1,tempID}) & tempID < length(channelNames2) % 通过while循环，找到第一个非空的通道数据，确保 tempID 变量指向的通道在后续的处理中包含有效的数据。
                tempID = tempID + 1; 
            end
    %             tempID
            filePoints(1,iF) = length(channelData{1,tempID}); % 单个数据通道中，包含的点的个数（在处理 cell 数组时，使用 {} 通常用于获取 cell 元素的内容，而使用 () 用于获取整个 cell 元素。）
            t = toc;
            [iF t]; % 用于调试的时候观察单个读取的耗时
            
            waitbar(iF/fileNum,h,['已经读取' num2str(iF) '/' num2str(fileNum) '个文件！']);
        end
        
        close(h) % 关闭进度条
        obj.fileNum = fileNum; % 同一批次中，每个文件对应的文件名为一个元素
        obj.filePoints = filePoints; % 同一批次中，每个文件对应的当个数据通道中的数据点数为一个元素
        
        %计算同一批次文件的总时间=求和（单个文件的数据点数）/同一批的采样率
        if obj.sampling > 0
            obj.totalTime =  sum(obj.filePoints)/obj.sampling;  
        else
            obj.totalTime = 0;
        end


end
    



