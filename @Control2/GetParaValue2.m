%Control2���ڷ���
%���ܣ�
%1. ��ȡָ�����ƵĿ��Ʋ���ֵ��
%2. ָ����������ͨ��������ȡ��Ӧ�Ĳ���ֵ;
%20190606
%�������
%num����1��ʾparas1,2��ʾpara2
%paraName����������/ȥ��ͨ��������
%channel������ֵ/ͨ��
%value������ֵ
function value = GetParaValue2(obj,num,paraName,channel)
    if num == 1     
        paraNames = obj.paras1.names;
        values = obj.paras1.values;
        channels = obj.paras1.channels;
    else
        paraNames = obj.paras2.names;
        values = obj.paras2.values;
        channels = obj.paras2.channels;
    end
    
    %��֪��������ͨ������e.g. 'channel_on',channel = 1,���ȡ'channel_on_x1'����ֵ
    if nargin == 4
        if isstr(channel) == 0
            channel = channels{channel};
        end
        paraName = [paraName '_' channel];
    end
        
    %��֪������'channel_on_x1'��ȡ����ֵ
    location = strcmp(paraName,paraNames);
    value = values(location);
end