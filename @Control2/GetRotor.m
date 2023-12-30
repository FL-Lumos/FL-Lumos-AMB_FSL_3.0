%生成转子模型（去除控制器）
%20190508

function obj = GetRotor(obj,num,chnType)
    if num == 1
        pid = obj.pid1;
    else
        pid = obj.pid2;
    end
    freqs = obj.freqs;
%     rotor = cell{1,5};
    
    Gain = GetParaValue2(obj,num,'exc_gain');  %激励放大倍数
    %X
    % if isempty(find(Channels == 'X')) == 0
    if isempty(findstr('X',chnType)) == 0   
        %Step1：构造该方向上的控制器函数
    %     sys_C(2,2) = tf(1,1);
        sys_C(1,1) = pid{1,1};   %X1方向的控制器模型
        sys_C(2,2) = pid{1,3};   %X2方向的控制器模型
        sys_C(1,2) = 0;
        sys_C(2,1) = 0;
    
        %Step2: 构造闭环传递函数
        sys_CL_frd = freqs{1,1};   %等价于freqs{1,3}，X方向的频率模型
        sys_CL_frd{1,1} = Gain*sys_CL_frd{1,1};
        sys_CL_frd{1,2} = Gain*sys_CL_frd{1,2};
        sys_CL_frd{2,1} = Gain*sys_CL_frd{2,1};
        sys_CL_frd{2,2} = Gain*sys_CL_frd{2,2};
        sys_CL = ConvertFRDCell2MIMO20120927(sys_CL_frd,0);
    
        %Step3: 计算开环不带控制器的参数
        I = eye(2);
        [tmpR, Fs] = frdata(sys_CL);
        clear tmpR
        NFs = length(Fs);
        sys = sys_CL/(I - sys_C*sys_CL);  
        
        obj.rotor{1,1} = sys(1,1);
        obj.rotor{1,3} = sys(2,2);
        
        %20200506 加入交叉项
        obj.rotorX{1} = sys;
    end

    %Y
    if isempty(findstr('Y',chnType)) == 0
        %Step1：构造该方向上的控制器函数
%         sys_C(2,2) = tf(1,1);
        sys_C(1,1) = pid{1,2};   %Y1方向的控制器模型
        sys_C(2,2) = pid{1,4};   %Y2方向的控制器模型
        sys_C(1,2) = 0;
        sys_C(2,1) = 0;

        %Step2: 构造闭环传递函数
        sys_CL_frd = freqs{1,2};  %等价于freqs{1,4}，Y方向的频率模型
        sys_CL_frd{1,1} = Gain*sys_CL_frd{1,1};
        sys_CL_frd{1,2} = Gain*sys_CL_frd{1,2};
        sys_CL_frd{2,1} = Gain*sys_CL_frd{2,1};
        sys_CL_frd{2,2} = Gain*sys_CL_frd{2,2};
        sys_CL = ConvertFRDCell2MIMO20120927(sys_CL_frd,0);

        %Step3: 计算开环不带控制器的参数
        I = eye(2);
        [tmpR, Fs] = frdata(sys_CL);
        clear tmpR
        NFs = length(Fs);
        sys = sys_CL/(I - sys_C*sys_CL);   

        obj.rotor{1,2} = sys(1,1);
        obj.rotor{1,4} = sys(2,2);
        
        %20200506 加入交叉项
        obj.rotorX{2} = sys;  
    end

    %Z
    if isempty(findstr('Z',chnType)) == 0
        sys_CL = freqs{1,5};
        sys_C = pid{1,5};

        %step4: 计算开环不带控制器的参数  
        I = eye(1);
        [tmpR,Fs] = frdata(sys_CL);
        clear tmpR
        NFs = length(Fs);

        sys = sys_CL/(I-sys_C*sys_CL);
        
        obj.rotor{1,5} = sys;
        %20200506 加入交叉项
        obj.rotorX{3} = sys;
    end

function sys = ConvertFRDCell2MIMO20120927(FRDcell,extrap)

[N1,N2]=size(FRDcell);  %系统维数

if nargin<2
    extrap=0;
end

minFs=zeros(N1,N2);   %每个系统的最小频率点数组
maxFs=zeros(N1,N2);
Fs=[];

for k1=1:N1
    for k2=1:N2
        if ~isa(FRDcell{k1,k2},'numeric')
            [tmpR,tmpFs]=frdata(FRDcell{k1,k2});
            minFs(k1,k2)=min(tmpFs);
            maxFs(k1,k2)=max(tmpFs);
            Fs=union(Fs,tmpFs);
        end
    end
end

maxminFs=max(minFs(:));
minmaxFs=min(maxFs(:));

if extrap==0
    Fs(Fs<maxminFs)=[];
    Fs(Fs>minmaxFs)=[];
end

% sys(N1,N2)=frd;

for k1=1:N1
    for k2=1:N2
        if ~isa(FRDcell{k1,k2},'numeric')
            sys(k1,k2)=interp(FRDcell{k1,k2},Fs);
        end
    end
end

