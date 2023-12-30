%»­³öFFT
%20200521

function [fMax,f,As] = FFTPlot(obj,fileNum,chns,DrawFlag)
    if nargin < 4
        DrawFlag = 1;
    end
    
    cN = length(chns);
    WindowWidth = obj.sampling;
    
    [data channelNames] = GetData(obj,fileNum,chns);
    
    for iC = 1:cN
        FigTitle = channelNames{1,iC};
      
        [fMax f A] = Signal2Speed2(data(iC,:),WindowWidth);
        if DrawFlag == 1
            figure;
            plot(f,A);
            title(['FFT-' channelNames{1,iC}]);
            grid on
            xlabel('ÆµÂÊ£¨Hz£©');ylabel('·ùÖµ');
        end
        
        As(iC,:) = A;
        fMaxs(iC,1) = fMax;
    end
    
    fMax = median(fMaxs);
end