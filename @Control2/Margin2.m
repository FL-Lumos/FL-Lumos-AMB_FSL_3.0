%基于margin函数进行改造，得到幅值裕度和相角裕度，以及对应的以Hz为单位的频率值
%输入：GH为开环函数
%输出：p为结构体，包括Am为幅值裕度,单位是dB，Af为幅值裕度对应的频率值(Hz)，Pm为相角裕度，Pf为相角裕度对应的频率值(Hz)
%20190516
%20190614修改，用allmargins代替margin
%20190903修改，增加了灵敏度函数最大值

function p = Margin2(obj,g)
%     [Am Pm Aw Pw] = margin(g);
%     Am = 20*log10(Am);
%     Af = Aw/(2*pi);
%     Pf = Pw/(2*pi);
%     p = struct('Am',Am,'Af',Af,'Pm',Pm,'Pf',Pf);

     %求出所有的相位、幅值裕度，取第一个，并将弧度转化为Hz
     S = allmargin(g);
     Am = abs(20*log10(S.GainMargin(1)));
     Af = S.GMFrequency(1)/(2*pi);
%      Pm = 20*log10(S.PhaseMargin(1));
     %20210325 修改为正确
     Pm = S.PhaseMargin(1);         %单位是角度
     Pf = S.PMFrequency(1)/(2*pi);  %单位是频率Hz
   
     %20190903 灵敏度判断
     st = 1/(1 + g);    %灵敏度函数
     f1 = st.Frequency/(2*pi);   %频率值
     s1 = 20*log10(abs(st.ResponseData));  %幅值
     
     [Sm f2] = max(s1);          %灵敏度函数最大值
     Sf = f1(f2);                %灵敏度函数最大值对应的频率   
     
     p = struct('Am',Am,'Af',Af,'Pm',Pm,'Pf',Pf,'Sm',Sm,'Sf',Sf);
end