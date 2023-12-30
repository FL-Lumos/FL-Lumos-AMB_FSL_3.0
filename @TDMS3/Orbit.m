%ͨ������GUI����ʾ���Ĺ켣�������϶�����������ʾ��ͬʱ���Ĺ켣
%20200524
%����:
%chnOrder����ͨ��˳��,Ҫ��ʾΪX1,Y1,X2,Y2,Z��Ĭ����[4 5 2 3 6]
%numPt����ÿ�����Ĺ켣������Ĭ����8000
%maxLimit��������ϵ�����Χ��Ĭ����5

function Orbit(obj,chnOrder,numPt,maxLimit)
    if nargin < 4
        maxLimit = 5;
    end
    if nargin < 3
        numPt = 8000;
    end
    if nargin < 2
        chnOrder = [4 5 2 3 6];
    end
    
%     %������ʱ��
%     totalTime = 0;
%     for iT = 1:obj.fileNum
%         p = load([obj.filePath obj.matNames{1,iT}]);
%         t = length(p.data);
%         totalTime = totalTime + t;
%     end
    
    totalTime = obj.totalTime;
    zRange = numPt / obj.sampling;
    
    tdmsInfo = struct('Tdms3',obj,'chnOrder',chnOrder,'numPt',numPt,'maxLimit',maxLimit,'zRange',zRange);
    
    amb = TDMSBrowser(tdmsInfo);    
end