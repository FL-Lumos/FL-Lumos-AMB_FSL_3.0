%从扫频数据中提取模型,为构造闭环模型准备
%20190508
%输入：filePath——数据文件所在路径，需要将文件命名为X1\Y1\X2\Y2\Z.txt
%chnType——为'X','Y','Z'
%输出：sys——基于数据的模型，若是X、Y通道，则返回是2*2的cell,纵坐标为激励方向，横坐标为响应方向；若是Z通道，则是1*1cell

function sys = FrequencyModel(obj,filePath,chnType)
    fileNamesProcess(filePath);  %对文件名称进行预处理,20200622
    
    if strcmp(chnType,'X') == 1
        temp1 = load([filePath 'X1.txt']);
        temp2 = load([filePath 'X2.txt']);
        Fs = temp1(:,1); %频率值
        M = temp1(:,6);  %X1激励，X1响应
        A = temp1(:,7);
        sys{1,1} = MADataToFrd20170508(M,A,Fs);

        M = temp1(:,2);  %X1激励，X2响应
        A = temp1(:,3);
        sys{2,1} = MADataToFrd20170508(M,A,Fs);

        M = temp2(:,6);  %X2激励，X1响应
        A = temp2(:,7); 
        sys{1,2} = MADataToFrd20170508(M,A,Fs);     

        M = temp2(:,2); %X2激励，X2响应
        A = temp2(:,3);
        sys{2,2} = MADataToFrd20170508(M,A,Fs);       
    end

    if strcmp(chnType,'Y') == 1
        temp1 = load([filePath 'Y1.txt']);
        temp2 = load([filePath 'Y2.txt']);
        Fs = temp1(:,1);
        M = temp1(:,8);  %Y1激励，Y1响应
        A = temp1(:,9);
        sys{1,1} = MADataToFrd20170508(M,A,Fs);

        M = temp1(:,4);  %Y1激励，Y2响应
        A = temp1(:,5);
        sys{2,1} = MADataToFrd20170508(M,A,Fs);

        M = temp2(:,8);  %Y2激励，Y1响应
        A = temp2(:,9); 
        sys{1,2} = MADataToFrd20170508(M,A,Fs);     

        M = temp2(:,4); %Y2激励，Y2响应
        A = temp2(:,5); 
        sys{2,2} = MADataToFrd20170508(M,A,Fs);           
    end

    if strcmp(chnType,'Z') == 1
        temp2 = load([filePath 'Z.txt']);
        Fs = temp2(:,1);
        M = temp2(:,10);  %Z激励，Z响应
        A = temp2(:,11);
        sys = MADataToFrd20170508(M,A,Fs);  
    end
end

%幅值、角度转化为Frd模型
function sys = MADataToFrd20170508(M,A,Fs)
    M = 10.^(M/20);   %dB化为幅值
    A = A / 180*pi;    %角度转化为弧度
    FRdata=M.*exp(1j*A); %欧拉公式构造复数形式的频响
    
    I=find(all(FRdata==1,2));
    Fs(I)=[];
    FRdata(I,:)=[];
    
    %去掉相同的元素
    [Fs,ia,ic] = unique(Fs);
    FRdata = FRdata(ia);
    
    %构造Hrd模型
    H=idfrd(FRdata,Fs*2*pi,0);
    sys=frd(H);   
end

%对filePath路径之下的扫频文件进行处理,将FSResult文件更名为相应的通道名称
%譬如"FSResult曝气风机X1201803211430.txt"更名为'X1.txt'；
%要注意的是通道名称可能是小写，如x1，要更名为大写；
%20200622
function fileNamesProcess(filePath)
    files = dir([filePath '*.txt']);
    fileNames = cell(1,length(files));
    for iF = 1:length(files)
        fileNames{1,iF} = files(iF).name;
    end
    p1 = strmatch('FSResult',fileNames);
    p2 = strmatch('FSResultInfo',fileNames);
    p3 = setdiff(p1,p2);  %FSResult所在文件序号

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
