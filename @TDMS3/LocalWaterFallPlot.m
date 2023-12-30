%根据局部数据，画瀑布图
%2022.7.11
%20200810 增加FigTitle的选项，修改了后三个输入的顺序
%输入变量
%data：为任意普通的数据块chn*N
%DrawFlag：画图标志，默认为1，画图，0为不画图
%figureTitle：瀑布图的名称前缀，最终图的标题为前缀+通道名，默认为空
%Fs：瀑布图频率间隔与范围，默认为[1:1:1000]
%输出变量
%T

function LocalWaterFallPlot(obj,data,DrawFlag,figureTitle,Fs)
    if nargin < 3
        DrawFlag = 1;
    end
    if nargin < 4
        figureTitle = [];
    end
    if nargin < 5
        Fs = [1:1:2000];
    end
  
    cN = size(data,1);  %数据通道数目
    WindowWidth = obj.sampling;
   
    for iC = 1:cN
        FigTitle = figureTitle{iC};
        if DrawFlag == 1
            fg = figure;
        end
        
        [T,Fs,SP] = WaterFall(data(iC,:),WindowWidth,Fs,DrawFlag,FigTitle);        
    end
end