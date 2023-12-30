function speed = Trans2Speed(obj,fileNum,chn,plusLength)
    if nargin < 4
        plusLength = 1000;
    end
    
    data = obj.GetData(fileNum,chn);
    speed = zeros(size(data));
    
    for iS = 1:length(data) - plusLength
        [S IP] = Pulse2Speed(data(iS:iS+plusLength-1),obj.sampling);
        speed(1,iS) = S;
    end
    
    speed(1,iS+1:length(data)) = speed(1,iS);
end