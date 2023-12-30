%����margin�������и��죬�õ���ֵԣ�Ⱥ����ԣ�ȣ��Լ���Ӧ����HzΪ��λ��Ƶ��ֵ
%���룺GHΪ��������
%�����pΪ�ṹ�壬����AmΪ��ֵԣ��,��λ��dB��AfΪ��ֵԣ�ȶ�Ӧ��Ƶ��ֵ(Hz)��PmΪ���ԣ�ȣ�PfΪ���ԣ�ȶ�Ӧ��Ƶ��ֵ(Hz)
%20190516
%20190614�޸ģ���allmargins����margin
%20190903�޸ģ������������Ⱥ������ֵ

function p = Margin2(obj,g)
%     [Am Pm Aw Pw] = margin(g);
%     Am = 20*log10(Am);
%     Af = Aw/(2*pi);
%     Pf = Pw/(2*pi);
%     p = struct('Am',Am,'Af',Af,'Pm',Pm,'Pf',Pf);

     %������е���λ����ֵԣ�ȣ�ȡ��һ������������ת��ΪHz
     S = allmargin(g);
     Am = abs(20*log10(S.GainMargin(1)));
     Af = S.GMFrequency(1)/(2*pi);
%      Pm = 20*log10(S.PhaseMargin(1));
     %20210325 �޸�Ϊ��ȷ
     Pm = S.PhaseMargin(1);         %��λ�ǽǶ�
     Pf = S.PMFrequency(1)/(2*pi);  %��λ��Ƶ��Hz
   
     %20190903 �������ж�
     st = 1/(1 + g);    %�����Ⱥ���
     f1 = st.Frequency/(2*pi);   %Ƶ��ֵ
     s1 = 20*log10(abs(st.ResponseData));  %��ֵ
     
     [Sm f2] = max(s1);          %�����Ⱥ������ֵ
     Sf = f1(f2);                %�����Ⱥ������ֵ��Ӧ��Ƶ��   
     
     p = struct('Am',Am,'Af',Af,'Pm',Pm,'Pf',Pf,'Sm',Sm,'Sf',Sf);
end