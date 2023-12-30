%Control2��ɨƵ��������ȡģ��,Ϊ����ջ�ģ��׼��
%20190606,��Դ��FrequencyModel
%�������
%filePath���������ļ�����·������Ҫ���ļ�����ΪX1\Y1\X2\Y2\Z.txt
%chn����Ϊ'X','Y','Z'
%�����sys�����������ݵ�ģ�ͣ�����X��Yͨ�����򷵻���2*2��cell,������Ϊ�������򣬺�����Ϊ��Ӧ��������Zͨ��������1*1cell

function obj = GetFreqs(obj,filePath,chnType)
    if nargin < 2 
        filePath = [];
    end
    
    %20200503
    if nargin < 3
        chnType = 'XYZ';
    end
    
    if isempty(filePath) == 1
        filePath = uigetdir(pwd,'ɨƵ�ļ�·��');
%         parasFile = [pathName fileName];   
    end
    
    
    
%     %�����ļ�
%     try        
%         temp1 = load([filePath '\' 'X1.txt']);
%         temp2 = load([filePath '\' 'X2.txt']);
%         temp3 = load([filePath '\' 'Y1.txt']);
%         temp4 = load([filePath '\' 'Y2.txt']);  
%         temp5 = load([filePath '\' 'Z.txt']); 
%         chnType = ['XYZ'];
%     catch
%         return;
%     end
                
    if isempty(findstr('X',chnType)) == 0
        temp1 = load([filePath 'X1.txt']);
        temp2 = load([filePath 'X2.txt']);
        Fs = temp1(:,1); %Ƶ��ֵ
        M = temp1(:,6);  %X1������X1��Ӧ
        A = temp1(:,7);
        sys{1,1} = MADataToFrd20170508(M,A,Fs);

        M = temp1(:,2);  %X1������X2��Ӧ
        A = temp1(:,3);
        sys{2,1} = MADataToFrd20170508(M,A,Fs);

        M = temp2(:,6);  %X2������X1��Ӧ
        A = temp2(:,7); 
        sys{1,2} = MADataToFrd20170508(M,A,Fs);     

        M = temp2(:,2); %X2������X2��Ӧ
        A = temp2(:,3);
        sys{2,2} = MADataToFrd20170508(M,A,Fs);   
        
        obj.freqs{1,1} = sys;
        obj.freqs{1,3} = sys;
    end

    if  isempty(findstr('Y',chnType)) == 0
        temp3 = load([filePath 'Y1.txt']);
        temp4 = load([filePath 'Y2.txt']);
        Fs = temp3(:,1);
        M = temp3(:,8);  %Y1������Y1��Ӧ
        A = temp3(:,9);
        sys{1,1} = MADataToFrd20170508(M,A,Fs);

        M = temp3(:,4);  %Y1������Y2��Ӧ
        A = temp3(:,5);
        sys{2,1} = MADataToFrd20170508(M,A,Fs);

        M = temp4(:,8);  %Y2������Y1��Ӧ
        A = temp4(:,9); 
        sys{1,2} = MADataToFrd20170508(M,A,Fs);     

        M = temp4(:,4); %Y2������Y2��Ӧ
        A = temp4(:,5); 
        sys{2,2} = MADataToFrd20170508(M,A,Fs);           
        
        obj.freqs{1,2} = sys;
        obj.freqs{1,4} = sys;
    end

    if isempty(findstr('Z',chnType)) == 0
        temp5 = load([filePath 'Z.txt']);
        Fs = temp5(:,1);
        M = temp5(:,10);  %Z������Z��Ӧ
        A = temp5(:,11);
        sys = MADataToFrd20170508(M,A,Fs);  
        obj.freqs{1,5} = sys;
    end
end

%��ֵ���Ƕ�ת��ΪFrdģ��
function sys = MADataToFrd20170508(M,A,Fs)
    M = 10.^(M/20);   %dB��Ϊ��ֵ
    A = A / 180*pi;    %�Ƕ�ת��Ϊ����
    FRdata=M.*exp(1j*A); %ŷ����ʽ���츴����ʽ��Ƶ��
    
    I=find(all(FRdata==1,2));
    Fs(I)=[];
    FRdata(I,:)=[];
    
    %ȥ����ͬ��Ԫ��
    [Fs,ia,ic] = unique(Fs);
    FRdata = FRdata(ia);
    
    %����Hrdģ��
    H=idfrd(FRdata,Fs*2*pi,0);
    sys=frd(H);   
end
