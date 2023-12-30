%画出不同组件的波特图，将所有模型画在一个图上
%20200508
%输入：mds——cell格式，每个cell中为1个模型
%      names——cell格式，每个模型的名称
%      titleName——figure的名称
function BDPlot2(obj,mds,names,titleName)
    if nargin < 4
        titleName = '系统模型比较';
    end
    if nargin < 3
        for iN = 1:length(mds)
            names{1,iN} = num2str(iN);
        end
    end


    %波特图设置
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