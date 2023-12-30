%20210325
%函数功能：TDMS3类成员，用于画各种基于TDMS数据的曲线
%输入变量：
%figType——图类型，1为振动-时间曲线；2为转速-时间曲线；3为振动-转速曲线
%fileNum——TDMS号，例如[1:3]；
%chn——通道号，例如[2 5]；
%flag——1为单图显示，2为多图显示；

function PlotX(obj,figType,fileNum,chn,flag)
    data = obj.GetData(fileNum,chn);
    chnNames = obj.channelNames(chn);
    
    %类型1：画振幅-时间曲线
    if figType == 1
        figure
        dataX = [1:length(data)]/obj.sampling;  %获取X通道的时间信息
        
        for iC = 1:size(data,1)
            plot(dataX,data(iC,:));
            xlabel('Time/s')
            ylabel('Vibration Amplitude/V')
            
            if flag == 1
                if iC < size(data,1)
                    hold on
                else
                    legend(chnNames)
                    title('振动幅值-时间曲线')
                end
            else
                title('振动幅值-时间曲线')
                legend(chnNames{iC})
                if iC < size(data,1)
                    figure
                end
            end
        end
    end
    
    %类型2：转速-时间曲线，转速采用的是fft的结果，默认选择五个振动方向通道作为计算
    if figType == 2
        figure
        dataX = [1:length(data)]/obj.sampling;  %获取X通道的时间信息
        
        segLen = floor(obj.sampling*0.1);   %计算片段的长度，默认为0.1s
        num = floor((length(data)-segLen+1)/(segLen/2)) + 1;
        
        fSpeed = zeros(1,num);
        ASpeed = zeros(size(data,1),num);
        TimeSpeed = zeros(1,num);
        flag = 0;
        for iP = 1:segLen/2:length(data)-segLen+1
            flag = flag + 1;
            tempData = data(:,iP:iP+segLen-1);
            [fMax AMax] = Signal2Speed3(tempData,obj.sampling);
            fSpeed(flag) = fMax;
            ASpeed(:,flag) = AMax; 
            TimeSpeed(flag) = dataX(iP);
        end
        
        plot(TimeSpeed,fSpeed)
        title('转速-时间曲线')
        xlabel('Time/s')
        ylabel('Vibration Amplitude/mm')
    end
    
    %类型3：同频振幅-转速
    if figType == 3
        figure
        %每隔1秒取一个点，数据之间有50%的重叠，最高转速不超过500Hz
        xLocation = [1:obj.sampling/2:length(data)];
        xLocation = xLocation(1:end-2);
        
        num = length(xLocation);
        speeds = zeros(1,num);
        vibs = zeros(length(chn),num);
        
        %计算转速、对应的振动
        for iL = 1:num
            dataX = data(:,xLocation(iL):xLocation(iL)+obj.sampling-1);
            [speed,vib] = CalSpeedX(dataX,obj.sampling,1);
            speeds(1,xLocation(iL)) = speed;
            vibs(:,xLocation(iL)) = vib;
        end

        %画图：高于500Hz的都去掉,选择最高点
        Th = 500;
        
        xl = find(speeds <= Th*1.1);  %过滤掉异常的高频
        speeds = speeds(1,xl);
        vibs = vibs(:,xl);
        
        for iC = 1:size(data,1)
            scatter(speeds,vibs(iC,:));
            xlabel('Speed/Hz')
            ylabel('Vibration Amplitude/V')
            
            if flag == 1
                if iC < size(data,1)
                    hold on
                else
                    legend(chnNames)
                    title('振动幅值-转速曲线')
                end
            else
                title('振动幅值-转速曲线')
                legend(chnNames{iC})
                if iC < size(data,1)
                    figure
                end
            end
        end        
    end
end