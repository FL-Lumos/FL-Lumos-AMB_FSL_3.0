%2023.12.26
%���Ӷ���txt�ļ���֧��
%20200815
%����filePoints��totalTime�ڱ������з�ֵ
%20200520
%����TDMS2�е�TDMSInfo���и��죬ֻ��ע��1���ļ�����Ϣ
%20190702
%��������:TDMS���ຯ�������ڶ�ȡtdms�ļ����ݵĻ�����Ϣ

function obj = TDMSInfo(obj)
    fileNames = obj.fileNames;
    filePath = obj.filePath;
            
    fileNum = length(fileNames); % һ����Ҫ��ȡ���ٵ��ļ�����

%------------1.������һ���ļ�����Ϣ�����ڵ�һ��TDMS��txt�ļ���ȡ�����Ϣ��--------------------%
    sampling = 0;
    fileName = fileNames{1,1};
    fileName = [filePath fileName];

    if isequal(fileName(end-2:end),'dms') % ����Ƕ����tdms�ļ����͵���֮ǰ�ķ���

% 1.1��ȡ��channeNames%��ͨ�����ƣ�����������ͨ����channelData����ͨ���ľ�������
   
        [a,b] = TDMS_readTDMSFile(fileName); %a,b�д���tdms���ݵ���Ϣ
        %channelData channeNames����cell��ʽ
        [channelData channelNames2] = TDMS_readChannelOrGroup(fileName,a.groupNames); %��ȡtdms�ļ������ݣ�channelData=1*n��cell nΪͨ����������ÿ�е�Ԫ�ض������˶�Ӧͨ�����������ݣ�channelNames2��n��ͨ��������
        num = length(channelData); %ͨ������
        channels = [];
        
        channels = zeros(1,num);
        channelNames = cell(1,num);

        % ���ΰ�channelData���cell�и�ͨ������װ��channels���������
        for iC = 1:num
            tempData = channelData{1,iC};
            if isempty(tempData) ~= 1 % ��ͨ���Ƿ�������
                channels(1,iC) = 1;
                channelNames{1,iC} = channelNames2{1,iC};
            end
        end

        obj.channelFlag = channels; % ���Ǹ����飬������Ӧλ�õ����ͨ���Ƿ��������ݵ�
        obj.channelNames = channelNames; % ���Ǹ�����ͨ�����Ƶ�cell

% 1.2��ȡ��sampling�������ʣ�ͨ���ļ�����ʱ�����ݵ�����һ��ʱ���Ͷ�Ӧ��һ�����ݵ㣩/�ļ�����ʱ����������date�����ݲɼ�ʱ�䣨���ļ��У���һ�����ݵ�Ĳɼ�ʱ�䣩
        %�ҵ�ʱ���е�λ��
        [tx,ty] = find(strcmp(channelNames2, 'Time')); % find�ҵ�Ϊ1��Ԫ�ص�λ�ã���tx����ty��
        if isempty(tx) ~= 1  %���tx��Ϊ�գ������ʱ����
            timeData = channelData{tx,ty}; % �ڲ��洢��ʱ�������л���ʽ�������� 0000 �� 01 �� 01 ��00:00������������
            %�����ʣ�ÿ���ӵĲ�������
            sampling = round((length(timeData)-1)/((timeData(end)-timeData(1))*24*60*60));  %2022.2.28 �ӹ�Ԫ0�꿪ʼ��length(timeData)-1����1����ʱ��������
            date = datestr(timeData(1),'yyyy-mm-dd hh:MM:ss');
        end
        obj.sampling = sampling;
        obj.date = date;
%--------------------------------------------------------------------------------------------%

%-----------------------------------2.���������ļ�-------------------------------------------%
        
        %20200815�޸�,ͳ��ÿ��tdms�ļ���filePoint����������ʱ��
        %2021.4.20 ���������
        h = waitbar(0,'���ڶ�ȡ�ļ������Ժ�!');
        
        filePoints = zeros(1,fileNum);
        for iF = 1:fileNum % ��ʼ����ѭ��������һ���ε����е��ļ�
            tic  % ��ʼ��ʱ

            tempName = fileNames{1,iF};
            tempFullName = [filePath tempName];

            [a,b] = TDMS_readTDMSFile(tempFullName); %a,b�д���tdms���ݵ���Ϣ
            [channelData,channelNames2] = TDMS_readChannelOrGroup(tempFullName,a.groupNames);
            tempID = 1;

            while isempty(channelData{1,tempID}) & tempID < length(channelNames2) % ͨ��whileѭ�����ҵ���һ���ǿյ�ͨ�����ݣ�ȷ�� tempID ����ָ���ͨ���ں����Ĵ����а�����Ч�����ݡ�
                tempID = tempID + 1; 
            end
    %             tempID
            filePoints(1,iF) = length(channelData{1,tempID}); % ��������ͨ���У������ĵ�ĸ������ڴ��� cell ����ʱ��ʹ�� {} ͨ�����ڻ�ȡ cell Ԫ�ص����ݣ���ʹ�� () ���ڻ�ȡ���� cell Ԫ�ء���
            t = toc;
            [iF t]; % ���ڵ��Ե�ʱ��۲쵥����ȡ�ĺ�ʱ
            
            waitbar(iF/fileNum,h,['�Ѿ���ȡ' num2str(iF) '/' num2str(fileNum) '���ļ���']);
        end
        
        close(h) % �رս�����
        obj.fileNum = fileNum; % ͬһ�����У�ÿ���ļ���Ӧ���ļ���Ϊһ��Ԫ��
        obj.filePoints = filePoints; % ͬһ�����У�ÿ���ļ���Ӧ�ĵ�������ͨ���е����ݵ���Ϊһ��Ԫ��
        
        %����ͬһ�����ļ�����ʱ��=��ͣ������ļ������ݵ�����/ͬһ���Ĳ�����
        if obj.sampling > 0
            obj.totalTime =  sum(obj.filePoints)/obj.sampling;  
        else
            obj.totalTime = 0;
        end

%-----------------------------------------------------------------------------------------------------%  
%--------------------2023.12.26 ����������txt�ļ����͵����µĺ���������Ϣ��ȡ------------------------% 
%-----------------------------------------------------------------------------------------------------% 
    elseif isequal(fileName(end-2:end),'txt') 
       
        % tdms�ļ�����Ĺؼ���Ϣ(��txt�ļ���ҲҪʵ�֣���
        %{
            obj.channelFlag = channels; %��ͨ����־��1Ϊ������ͨ����0Ϊ������ͨ��
            obj.channelNames = channelNames; %��ͨ�����ƣ�����������ͨ��
            obj.sampling = sampling; %������
            obj.date = date; %�ļ�����
            obj.fileNum = fileNum; %�ļ���Ŀ
            obj.filePoints = filePoints;  %1*fileNum��ÿ��Ԫ��Ϊ�ļ�����

        %}
       
% 1.1��ȡ��channeNames����ͨ�����ƣ�����������ͨ����channelFlag����ͨ������������������У�1���ޣ�0��
   
        [channelData, channelNames2] = TXT_readChannelOrGroup(fileName); %a,b�д���tdms���ݵ���Ϣ

        % �����жϸ�ͨ���Ƿ�������ݣ�TXT������������⣬���԰���app_TXT_channelName_Value�ĳ��ȣ�ȫ��1��
        num = length(channelNames2); %ͨ������   
        channels = [];        
        channels = ones(1,num);

        obj.channelFlag = channels; % ���Ǹ����飬������Ӧλ�õ����ͨ���Ƿ��������ݵ�
        obj.channelNames = channelNames2; % ���Ǹ�����ͨ�����Ƶ�cell

% 1.2��ȡ��sampling�������ʣ�ͨ���ļ�����ʱ�����ݵ�����һ��ʱ���Ͷ�Ӧ��һ�����ݵ㣩/�ļ�����ʱ����������date�����ݲɼ�ʱ�䣨���ļ��У���һ�����ݵ�Ĳɼ�ʱ�䣩
        %�ҵ�ʱ���е�λ��
        [tx,ty] = find(strcmp(channelNames2, 'time')); % find�ҵ�Ϊ1��Ԫ�ص�λ�ã���tx����ty��
        if isempty(tx) ~= 1  %���tx��Ϊ�գ������ʱ����
            timeData = channelData{tx,ty}; % �ڲ��洢��ʱ�������л���ʽ�������� 0000 �� 01 �� 01 ��00:00������������
            %�����ʣ�ÿ���ӵĲ�������
            sampling = round((length(timeData)-1)/((timeData(end)-timeData(1))));  %2022.2.28 �ӹ�Ԫ0�꿪ʼ��length(timeData)-1����1����ʱ��������

            startTime = datetime(1970,1,1,0,0,0);
                % ��timeData(1)ת��Ϊ����
            day_temp = timeData(1)/(24*60*60);
            % ��startTime�Ļ����ϼ����������õ���ǰ��datetime����
            currentTime = startTime + day_temp;
            % ��currentTime��ʽ��Ϊyyyy-mm-dd hh:MM:ss���ַ���
            date = datestr(currentTime,'yyyy-mm-dd HH:MM:SS')

            % ������ʱ��ת��Ϊdatetime����

        end
        obj.sampling = sampling;
        obj.date = date;
%--------------------------------------------------------------------------------------------%

%-----------------------------------2.���������ļ�-------------------------------------------%
        
        %20200815�޸�,ͳ��ÿ��tdms�ļ���filePoint����������ʱ��
        %2021.4.20 ���������
        h = waitbar(0,'���ڶ�ȡ�ļ������Ժ�!');
        
        filePoints = zeros(1,fileNum);
        for iF = 1:fileNum % ��ʼ����ѭ��������һ���ε����е��ļ�
            tic  % ��ʼ��ʱ

            tempName = fileNames{1,iF};
            tempFullName = [filePath tempName];

            [channelData,channelNames2] = TXT_readChannelOrGroup(fileName);
            tempID = 1;

            while isempty(channelData{1,tempID}) & tempID < length(channelNames2) % ͨ��whileѭ�����ҵ���һ���ǿյ�ͨ�����ݣ�ȷ�� tempID ����ָ���ͨ���ں����Ĵ����а�����Ч�����ݡ�
                tempID = tempID + 1; 
            end
    %             tempID
            filePoints(1,iF) = length(channelData{1,tempID}); % ��������ͨ���У������ĵ�ĸ������ڴ��� cell ����ʱ��ʹ�� {} ͨ�����ڻ�ȡ cell Ԫ�ص����ݣ���ʹ�� () ���ڻ�ȡ���� cell Ԫ�ء���
            t = toc;
            [iF t]; % ���ڵ��Ե�ʱ��۲쵥����ȡ�ĺ�ʱ
            
            waitbar(iF/fileNum,h,['�Ѿ���ȡ' num2str(iF) '/' num2str(fileNum) '���ļ���']);
        end
        
        close(h) % �رս�����
        obj.fileNum = fileNum; % ͬһ�����У�ÿ���ļ���Ӧ���ļ���Ϊһ��Ԫ��
        obj.filePoints = filePoints; % ͬһ�����У�ÿ���ļ���Ӧ�ĵ�������ͨ���е����ݵ���Ϊһ��Ԫ��
        
        %����ͬһ�����ļ�����ʱ��=��ͣ������ļ������ݵ�����/ͬһ���Ĳ�����
        if obj.sampling > 0
            obj.totalTime =  sum(obj.filePoints)/obj.sampling;  
        else
            obj.totalTime = 0;
        end


end
    



