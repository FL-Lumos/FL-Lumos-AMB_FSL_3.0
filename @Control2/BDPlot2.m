%������ͬ����Ĳ���ͼ��������ģ�ͻ���һ��ͼ��
%20200508
%���룺mds����cell��ʽ��ÿ��cell��Ϊ1��ģ��
%      names����cell��ʽ��ÿ��ģ�͵�����
%      titleName����figure������
function BDPlot2(obj,mds,names,titleName)
    if nargin < 4
        titleName = 'ϵͳģ�ͱȽ�';
    end
    if nargin < 3
        for iN = 1:length(mds)
            names{1,iN} = num2str(iN);
        end
    end


    %����ͼ����
    bp=bodeoptions;
    bp.FreqUnits='Hz';
    bp.IOGrouping='outputs';
    bp.Grid='on';
    bp.PhaseWrapping ='on'; 
    bp.MagUnits = 'dB';
    bp.Xlim = [0.1 2000];
    
    mInput = [];
    name = [];
    for iM = 1:length(mds)
        mInput = [mInput 'mds{' num2str(iM) '},'];
        name = [name 'names{' num2str(iM) '},'];
    end
    mInput = ['bodeplot('  mInput  'bp)'];
    name = ['legend(' name(1:end-1) ')'];
    
    figure('name',titleName);
    bp.Title.String = titleName;
    
    eval(mInput) 
    eval(name)
end