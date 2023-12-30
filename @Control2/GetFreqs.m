%Control2从扫频数据中提取模型,为构造闭环模型准备
%20190606,来源于FrequencyModel
%输入参数
%filePath——数据文件所在路径，需要将文件命名为X1\Y1\X2\Y2\Z.txt
%chn——为'X','Y','Z'
%输出：sys——基于数据的模型，若是X、Y通道，则返回是2*2的cell,纵坐标为激励方向，横坐标为响应方向；若是Z通道，则是1*1cell

function obj = GetFreqs(obj,filePath,chnType)
    if nargin < 2 
        filePath = [];
    end
    
    %20200503
    if nargin < 3
        chnType = 'XYZ';
    end
    
    if isempty(filePath) == 1
        filePath = uigetdir(pwd,'扫频文件路径');
%         parasFile = [pathName fileName];   
    end
    
    
    
%     %载入文件
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
        
        obj.freqs{1,1} = sys;
        obj.freqs{1,3} = sys;
    end

    if  isempty(findstr('Y',chnType)) == 0
        temp3 = load([filePath 'Y1.txt']);
        temp4 = load([filePath 'Y2.txt']);
        Fs = temp3(:,1);
        M = temp3(:,8);  %Y1激励，Y1响应
        A = temp3(:,9);
        sys{1,1} = MADataToFrd20170508(M,A,Fs);

        M = temp3(:,4);  %Y1激励，Y2响应
        A = temp3(:,5);
        sys{2,1} = MADataToFrd20170508(M,A,Fs);

        M = temp4(:,8);  %Y2激励，Y1响应
        A = temp4(:,9); 
        sys{1,2} = MADataToFrd20170508(M,A,Fs);     

        M = temp4(:,4); %Y2激励，Y2响应
        A = temp4(:,5); 
        sys{2,2} = MADataToFrd20170508(M,A,Fs);           
        
        obj.freqs{1,2} = sys;
        obj.freqs{1,4} = sys;
    end

    if isempty(findstr('Z',chnType)) == 0
        temp5 = load([filePath 'Z.txt']);
        Fs = temp5(:,1);
        M = temp5(:,10);  %Z激励，Z响应
        A = temp5(:,11);
        sys = MADataToFrd20170508(M,A,Fs);  
        obj.freqs{1,5} = sys;
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
