%获取PID模型中的部件传递函数模型：包括滤波器、微分整形等
%20190606,更新与ControlParas中的GetModel

function md = GetComponentModel(obj,num,groupName,channel)
    Fs = 10000;
    
    %构造积分部分的传递函数
    if strcmp(groupName,'integral') == 1
        active_I = GetParaValue2(obj,num,'active_I',channel);
        if active_I == 1
            capital_ki = GetParaValue2(obj,num,'capital_ki',channel);
            frequency_I = GetParaValue2(obj,num,'frequency_I',channel);
            omega_i = frequency_I * 2 * pi;   %积分环节截止角频率
        
            md=tf(capital_ki * omega_i,[1,omega_i]);  %连续积分环节传递函数
        else
            md = 0;
        end
    end
    
    %构造滤波器传递函数
    if strcmp(groupName,'filter') == 1
        groupValues = GetGroupParaValues2(obj,num,groupName,channel);
        md = ss(1,0,0,1,1/Fs);   %初始化滤波器
        for iG = 1:length(groupValues)
            tempValue = groupValues{1,iG};
            active_f = tempValue.active_f;
            if active_f == 0
                gd = 1; %当滤波器关闭时，滤波器传递函数为1；
            else
                FC = tempValue.frequency_f;
                FW = tempValue.bandwidth_f;
                FR = tempValue.Rs_f;
                [b,a] = cheby2(2,FR,[FC-FW,FC+FW]/(Fs/2),'stop');
                coef = [b,-a(2:end)];
                gd = ss(tf(coef(1:5),[1,-coef(6:9)],1/Fs));

%                 %20190813
%                 [A,B,C,D] = cheby2(2,FR,[FC-FW,FC+FW]/(Fs/2),'stop');
%                 gd = ss(A,B,C,D,1/Fs);
            end
            md = md * gd;
        end
        md = d2c(md,'matched');
    end   
    
    %微分整形/相位补偿
    if strcmp(groupName,'shape') == 1
        groupValues = GetGroupParaValues2(obj,num,groupName,channel);
        tempMd = cell(1,2);
        weights = zeros(1,2);
        active_D = zeros(1,2);
        %分别整合两个微分整形模型
        for iG = 1:2
            tempValue = groupValues{1,iG};
            fp = tempValue.frequency_peak;
            fb = tempValue.frequency_bw;
            weights(1,iG) = tempValue.weight;
            active_D(1,iG) = tempValue.active_shape_D;

            a1_2 = 4 * fp * Fs;
            a2_2 = fp^2 + 4 * pi^2 * (fp - fb)^2;
            a3_2 = 4 * fp * Fs;
            a4_2 = fp^2 + 4 * pi^2 * (fp + fb)^2;
            
            tempMd{1,iG} = tf([1,a1_2/2/Fs,a2_2],[1,a3_2/2/Fs,a4_2]);  %相位补偿环节连续传递函数        
        end
        %综合两个模型
        w0 = weights(1);    
        w2 = weights(2);
        
        frequency_D = GetParaValue2(obj,num,'frequency_D',channel);
        capital_kd = GetParaValue2(obj,num,'capital_kd',channel); 
        omega_d=frequency_D*2*pi;   %微分环节截止角频率        
    
%         kd = 2 * capital_kd * Fs/(1 + 2*Fs/omega_d);   %DSP程序中的变量kd
%         kdo = (2 * Fs/omega_d - 1)/(2*Fs/omega_d + 1); %DSP程序中的变量kdo
        
        %暂时只考虑整形全开的情况
        if active_D(1) == 1 && active_D(2) == 1
            md = tf([capital_kd * omega_d,0],[1,omega_d]) * (w2 * tempMd{1,2} * tempMd{1,1} + (1 - w0));    %连续微分环节传递函数
        elseif active_D(1) == 1 && active_D(2) == 0
            md = tf([capital_kd * omega_d,0],[1,omega_d])*(w2 * tempMd{1,1} + (1 - w0));    %连续微分环节传递函数    
        elseif active_D(1) == 0 && active_D(2) == 1
            md = tf([capital_kd * omega_d,0],[1,omega_d])*(w2 * tempMd{1,2} + (1 - w0));    %连续微分环节传递函数
        else
            md = tf([capital_kd * omega_d,0],[1,omega_d]);    %连续微分环节传递函数
        end 
    end
end