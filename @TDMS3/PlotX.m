%20210325
%�������ܣ�TDMS3���Ա�����ڻ����ֻ���TDMS���ݵ�����
%���������
%figType����ͼ���ͣ�1Ϊ��-ʱ�����ߣ�2Ϊת��-ʱ�����ߣ�3Ϊ��-ת������
%fileNum����TDMS�ţ�����[1:3]��
%chn����ͨ���ţ�����[2 5]��
%flag����1Ϊ��ͼ��ʾ��2Ϊ��ͼ��ʾ��

function PlotX(obj,figType,fileNum,chn,flag)
    data = obj.GetData(fileNum,chn);
    chnNames = obj.channelNames(chn);
    
    %����1�������-ʱ������
    if figType == 1
        figure
        dataX = [1:length(data)]/obj.sampling;  %��ȡXͨ����ʱ����Ϣ
        
        for iC = 1:size(data,1)
            plot(dataX,data(iC,:));
            xlabel('Time/s')
            ylabel('Vibration Amplitude/V')
            
            if flag == 1
                if iC < size(data,1)
                    hold on
                else
                    legend(chnNames)
                    title('�񶯷�ֵ-ʱ������')
                end
            else
                title('�񶯷�ֵ-ʱ������')
                legend(chnNames{iC})
                if iC < size(data,1)
                    figure
                end
            end
        end
    end
    
    %����2��ת��-ʱ�����ߣ�ת�ٲ��õ���fft�Ľ����Ĭ��ѡ������񶯷���ͨ����Ϊ����
    if figType == 2
        figure
        dataX = [1:length(data)]/obj.sampling;  %��ȡXͨ����ʱ����Ϣ
        
        segLen = floor(obj.sampling*0.1);   %����Ƭ�εĳ��ȣ�Ĭ��Ϊ0.1s
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
        title('ת��-ʱ������')
        xlabel('Time/s')
        ylabel('Vibration Amplitude/mm')
    end
    
    %����3��ͬƵ���-ת��
    if figType == 3
        figure
        %ÿ��1��ȡһ���㣬����֮����50%���ص������ת�ٲ�����500Hz
        xLocation = [1:obj.sampling/2:length(data)];
        xLocation = xLocation(1:end-2);
        
        num = length(xLocation);
        speeds = zeros(1,num);
        vibs = zeros(length(chn),num);
        
        %����ת�١���Ӧ����
        for iL = 1:num
            dataX = data(:,xLocation(iL):xLocation(iL)+obj.sampling-1);
            [speed,vib] = CalSpeedX(dataX,obj.sampling,1);
            speeds(1,xLocation(iL)) = speed;
            vibs(:,xLocation(iL)) = vib;
        end

        %��ͼ������500Hz�Ķ�ȥ��,ѡ����ߵ�
        Th = 500;
        
        xl = find(speeds <= Th*1.1);  %���˵��쳣�ĸ�Ƶ
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
                    title('�񶯷�ֵ-ת������')
                end
            else
                title('�񶯷�ֵ-ת������')
                legend(chnNames{iC})
                if iC < size(data,1)
                    figure
                end
            end
        end        
    end
end