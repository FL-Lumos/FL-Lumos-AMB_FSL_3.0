%画瀑布图
%20200521
%20200810 增加FigTitle的选项，修改了后三个输入的顺序
%输入变量
%fileNum：TDMS3类中数据文件序号，可以为多个文件的数组
%chns：通道号，可以为单个或者多个的数组
%DrawFlag：画图标志，默认为1，画图，0为不画图
%figureTitle：瀑布图的名称前缀，最终图的标题为前缀+通道名，默认为空
%Fs：瀑布图频率间隔与范围，默认为[1:1:1000]
%输出变量
%T

function [T,Fs,SPs,channelNames] = WaterFallPlot(obj,fileNum,chns,DrawFlag,figureTitle,Fs)
    if nargin < 4
        DrawFlag = 1;
    end
%     if nargin < 5
%         saveFigure = 0;  %默认不保存
%     end
    if nargin < 5
        figureTitle = [];
    end
    if nargin < 6
        Fs = [1:1:2000];
    end
  
    cN = length(chns);
    WindowWidth = obj.sampling;
    
    [data channelNames] = GetData(obj,fileNum,chns);
    
    for iC = 1:cN
        FigTitle = [figureTitle channelNames{1,iC}];
        if DrawFlag == 1
            fg = figure;
        end
        
        [T,Fs,SP] = WaterFall(data(iC,:),WindowWidth,Fs,DrawFlag,FigTitle);
        SPs{1,iC} = SP;
        
%         if saveFigure == 1
%             saveas(fg,[obj.filePath FigTitle], 'fig');
%         end
    end
end