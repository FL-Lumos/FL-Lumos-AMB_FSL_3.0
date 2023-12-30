%����ת��ģ�ͣ�ȥ����������
%20190508

function sys = RotorModel(obj,filePath,chnTypes)

Gain = GetParaValue(obj,'exc_gain');  %�����Ŵ���
%X
% if isempty(find(Channels == 'X')) == 0
if strcmp(chnTypes,'X')    
    %Step1������÷����ϵĿ���������
%     sys_C(2,2) = tf(1,1);
    sys_C(1,1) = PIDModel(obj,1);   %X1����Ŀ�����ģ��
    sys_C(2,2) = PIDModel(obj,3);   %X2����Ŀ�����ģ��
    sys_C(1,2) = 0;
    sys_C(2,1) = 0;
    
    %Step2: ����ջ����ݺ���
    sys_CL_frd = FrequencyModel(obj,filePath,chnTypes);
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
end

%Y
if strcmp(chnTypes,'Y') == 1
    %Step1������÷����ϵĿ���������
    sys_C(2,2) = tf(1,1);
    sys_C(1,1) = PIDModel(obj,2);   %X1����Ŀ�����ģ��
    sys_C(2,2) = PIDModel(obj,4);   %X2����Ŀ�����ģ��
    sys_C(1,2) = 0;
    sys_C(2,1) = 0;
    
    %Step2: ����ջ����ݺ���
    sys_CL_frd = FrequencyModel(obj,filePath,chnTypes);
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
end

%Z
if strcmp(chnTypes,'Z') == 1
    sys_CL = FrequencyModel(obj,filePath,chnTypes);
    sys_C = PIDModel(obj,5);
    
    %step4: ���㿪�������������Ĳ���  
    I = eye(1);
    [tmpR,Fs] = frdata(sys_CL);
    clear tmpR
    NFs = length(Fs);
    
    sys = sys_CL/(I-sys_C*sys_CL);
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

