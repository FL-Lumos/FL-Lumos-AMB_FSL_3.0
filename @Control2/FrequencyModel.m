%��ɨƵ��������ȡģ��,Ϊ����ջ�ģ��׼��
%20190508
%���룺filePath���������ļ�����·������Ҫ���ļ�����ΪX1\Y1\X2\Y2\Z.txt
%chnType����Ϊ'X','Y','Z'
%�����sys�����������ݵ�ģ�ͣ�����X��Yͨ�����򷵻���2*2��cell,������Ϊ�������򣬺�����Ϊ��Ӧ��������Zͨ��������1*1cell

function sys = FrequencyModel(obj,filePath,chnType)
    fileNamesProcess(filePath);  %���ļ����ƽ���Ԥ����,20200622
    
    if strcmp(chnType,'X') == 1
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
    end

    if strcmp(chnType,'Y') == 1
        temp1 = load([filePath 'Y1.txt']);
        temp2 = load([filePath 'Y2.txt']);
        Fs = temp1(:,1);
        M = temp1(:,8);  %Y1������Y1��Ӧ
        A = temp1(:,9);
        sys{1,1} = MADataToFrd20170508(M,A,Fs);

        M = temp1(:,4);  %Y1������Y2��Ӧ
        A = temp1(:,5);
        sys{2,1} = MADataToFrd20170508(M,A,Fs);

        M = temp2(:,8);  %Y2������Y1��Ӧ
        A = temp2(:,9); 
        sys{1,2} = MADataToFrd20170508(M,A,Fs);     

        M = temp2(:,4); %Y2������Y2��Ӧ
        A = temp2(:,5); 
        sys{2,2} = MADataToFrd20170508(M,A,Fs);           
    end

    if strcmp(chnType,'Z') == 1
        temp2 = load([filePath 'Z.txt']);
        Fs = temp2(:,1);
        M = temp2(:,10);  %Z������Z��Ӧ
        A = temp2(:,11);
        sys = MADataToFrd20170508(M,A,Fs);  
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

%��filePath·��֮�µ�ɨƵ�ļ����д���,��FSResult�ļ�����Ϊ��Ӧ��ͨ������
%Ʃ��"FSResult�������X1201803211430.txt"����Ϊ'X1.txt'��
%Ҫע�����ͨ�����ƿ�����Сд����x1��Ҫ����Ϊ��д��
%20200622
function fileNamesProcess(filePath)
    files = dir([filePath '*.txt']);
    fileNames = cell(1,length(files));
    for iF = 1:length(files)
        fileNames{1,iF} = files(iF).name;
    end
    p1 = strmatch('FSResult',fileNames);
    p2 = strmatch('FSResultInfo',fileNames);
    p3 = setdiff(p1,p2);  %FSResult�����ļ����

    tempNames = fileNames(p3);
    
    z1 = {'X1','Y1','X2','Y2','Z'};
    z2 = {'x1','y1','x2','y2','z'};
    for iF = 1:length(p3)
        tempName = tempNames{iF};    
        for iC = 1:5
            if (isempty(findstr(z1{iC},tempName)) & isempty(findstr(z2{iC},tempName))) == 0
                newName = [z1{iC} '.txt'];
                if isempty(strmatch(newName,fileNames)) 
                    copyfile([filePath tempName],[filePath newName]);
                    break;
                end
            end           
        end
    end
end
