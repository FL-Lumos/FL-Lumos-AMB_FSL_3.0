%通过弹出GUI，显示轴心轨迹，可以拖动进度条，显示不同时间点的轨迹
%20200524
%输入:
%chnOrder——通道顺序,要显示为X1,Y1,X2,Y2,Z，默认是[4 5 2 3 6]
%numPt——每个轴心轨迹点数，默认是8000
%maxLimit——坐标系的最大范围，默认是5

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
    
%     %计算总时间
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