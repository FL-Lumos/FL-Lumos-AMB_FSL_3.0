%���ٲ�ͼ
%20200521
%20200810 ����FigTitle��ѡ��޸��˺����������˳��
%�������
%fileNum��TDMS3���������ļ���ţ�����Ϊ����ļ�������
%chns��ͨ���ţ�����Ϊ�������߶��������
%DrawFlag����ͼ��־��Ĭ��Ϊ1����ͼ��0Ϊ����ͼ
%figureTitle���ٲ�ͼ������ǰ׺������ͼ�ı���Ϊǰ׺+ͨ������Ĭ��Ϊ��
%Fs���ٲ�ͼƵ�ʼ���뷶Χ��Ĭ��Ϊ[1:1:1000]
%�������
%T

function [T,Fs,SPs,channelNames] = WaterFallPlot(obj,fileNum,chns,DrawFlag,figureTitle,Fs)
    if nargin < 4
        DrawFlag = 1;
    end
%     if nargin < 5
%         saveFigure = 0;  %Ĭ�ϲ�����
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