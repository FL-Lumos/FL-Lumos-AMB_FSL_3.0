%����ת��ģ�ͣ�ȥ����������
%20190508

function obj = GetRotor(obj,num,chnType)
    if num == 1
        pid = obj.pid1;
    else
        pid = obj.pid2;
    end
    freqs = obj.freqs;
%     rotor = cell{1,5};
    
    Gain = GetParaValue2(obj,num,'exc_gain');  %�����Ŵ���
    %X
    % if isempty(find(Channels == 'X')) == 0
    if isempty(findstr('X',chnType)) == 0   
        %Step1������÷����ϵĿ���������
    %     sys_C(2,2) = tf(1,1);
        sys_C(1,1) = pid{1,1};   %X1����Ŀ�����ģ��
        sys_C(2,2) = pid{1,3};   %X2����Ŀ�����ģ��
        sys_C(1,2) = 0;
        sys_C(2,1) = 0;
    
        %Step2: ����ջ����ݺ���
        sys_CL_frd = freqs{1,1};   %�ȼ���freqs{1,3}��X�����Ƶ��ģ��
        sys_CL_frd{1,1} = Gain*sys_CL_frd{1,1};
        sys_CL_frd{1,2} = Gain*sys_CL_frd{1,2};
        sys_CL_frd{2,1} = Gain*sys_CL_frd{2,1};
        sys_CL_frd{2,2} = Gain*sys_CL_frd{2,2};
        sys_CL = ConvertFRDCell2MIMO20120927(sys_CL_frd,0);
    
        %Step3: ���㿪�������������Ĳ���
        I = eye(2);
        [tmpR, Fs] = frdata(sys_CL);
        clear tmpR
        NFs = length(Fs);
        sys = sys_CL/(I - sys_C*sys_CL);  
        
        obj.rotor{1,1} = sys(1,1);
        obj.rotor{1,3} = sys(2,2);
        
        %20200506 ���뽻����
        obj.rotorX{1} = sys;
    end

    %Y
    if isempty(findstr('Y',chnType)) == 0
        %Step1������÷����ϵĿ���������
%         sys_C(2,2) = tf(1,1);
        sys_C(1,1) = pid{1,2};   %Y1����Ŀ�����ģ��
        sys_C(2,2) = pid{1,4};   %Y2����Ŀ�����ģ��
        sys_C(1,2) = 0;
        sys_C(2,1) = 0;

        %Step2: ����ջ����ݺ���
        sys_CL_frd = freqs{1,2};  %�ȼ���freqs{1,4}��Y�����Ƶ��ģ��
        sys_CL_frd{1,1} = Gain*sys_CL_frd{1,1};
        sys_CL_frd{1,2} = Gain*sys_CL_frd{1,2};
        sys_CL_frd{2,1} = Gain*sys_CL_frd{2,1};
        sys_CL_frd{2,2} = Gain*sys_CL_frd{2,2};
        sys_CL = ConvertFRDCell2MIMO20120927(sys_CL_frd,0);

        %Step3: ���㿪�������������Ĳ���
        I = eye(2);
        [tmpR, Fs] = frdata(sys_CL);
        clear tmpR
        NFs = length(Fs);
        sys = sys_CL/(I - sys_C*sys_CL);   

        obj.rotor{1,2} = sys(1,1);
        obj.rotor{1,4} = sys(2,2);
        
        %20200506 ���뽻����
        obj.rotorX{2} = sys;  
    end

    %Z
    if isempty(findstr('Z',chnType)) == 0
        sys_CL = freqs{1,5};
        sys_C = pid{1,5};

        %step4: ���㿪�������������Ĳ���  
        I = eye(1);
        [tmpR,Fs] = frdata(sys_CL);
        clear tmpR
        NFs = length(Fs);

        sys = sys_CL/(I-sys_C*sys_CL);
        
        obj.rotor{1,5} = sys;
        %20200506 ���뽻����
        obj.rotorX{3} = sys;
    end

function sys = ConvertFRDCell2MIMO20120927(FRDcell,extrap)

[N1,N2]=size(FRDcell);  %ϵͳά��

if nargin<2
    extrap=0;
end

minFs=zeros(N1,N2);   %ÿ��ϵͳ����СƵ�ʵ�����
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

