function template = xlsProcess(filename)
[~, computer] = system('hostname');
[~, user] = system('whoami');
[~, alltask] = system(['tasklist /S ', computer, ' /U ', user]);
excelPID = regexp(alltask, 'EXCEL.EXE\s*(\d+)\s', 'tokens');
for i = 1 : length(excelPID)
      killPID = cell2mat(excelPID{i});
      system(['taskkill /f /pid ', killPID]);
end
[numberInfo,TextInfo,raw] = xlsread(filename);
[TextRow, TextColumn] = size(TextInfo);
for i = 1:TextColumn
	temp = TextInfo{1,i};
	if strcmp(temp,'ID')     IDName = i; end
	if strcmp(temp,'·��')  FilePath = i; end
	if strcmp(temp,'��˾����')     CompanyName = i; end
	if strcmp(temp,'��֤����')     DocumentType = i; end
	if strcmp(temp,'ģ������')  TemplateType = i; end
	if strcmp(temp,'��ҳ���')  PageFlag = i; end
	if strcmp(temp,'�����')  TableFlag = i; end
	if strcmp(temp,'�������')  SeriesNum = i; end
	if strcmp(temp,'X����')         Xorder = i;end
	if strcmp(temp,'Y����')         Yorder = i;end
	if strcmp(temp,'���')    Worder = i;end
	if strcmp(temp,'�߶�')    Horder = i;end
	if strcmp(temp,'��������')    FeatureFlag = i;end
	if strcmp(temp,'��������.����')    DatabaseTablename = i;end
    if strcmp(temp,'��������.����')    DatabaseColname = i;end
end
    
for i = 1:size(numberInfo,1)
    a = numberInfo(i,PageFlag);
    TextInfo{i+1,PageFlag} = num2str(a);%����ҳ��Ǵ���TextInfo��

    b = numberInfo(i,TableFlag);
    TextInfo{i+1,TableFlag} = num2str(b);%����������TextInfo��

    c = numberInfo(i,IDName);
    TextInfo{i+1,IDName} = num2str(c);%����������ID��

    if SeriesNum <= size(numberInfo,2)
        d =numberInfo(i,SeriesNum);
        if ~isnan(d)
            TextInfo{i+1,SeriesNum} = num2str(d);%��������Ŵ���ID��
        end
    end
end
%-------------�����������е��ַ�����ת��Ϊdouble��-----------------
SeriesNumStr = TextInfo(1:end,SeriesNum);%ȡ��ģ�����ݵ��б�ǣ��ַ������ͣ�
SeriesNumDouble = zeros(1,TextRow);%ת��Ϊdouble��

XStr = TextInfo(1:end,Xorder);%ȡ��ģ�����ݵ�X�������꣨�ַ������ͣ�
XDouble = zeros(1,TextRow);%ת��Ϊdouble��
YStr = TextInfo(1:end,Yorder);%ȡ��ģ�����ݵ�Y�������꣨�ַ������ͣ�
YDouble = zeros(1,TextRow);%ת��Ϊdouble��
WStr = TextInfo(1:end,Worder);%ȡ��ģ�����ݵ�Weight���꣨�ַ������ͣ�
WDouble = zeros(1,TextRow);%ת��Ϊdouble��
HStr = TextInfo(1:end,Horder);%ȡ��ģ�����ݵ�Height���꣨�ַ������ͣ�
HDouble = zeros(1,TextRow);%ת��Ϊdouble��
for i = 1:TextRow
    SeriesNumDouble(i) = str2double(SeriesNumStr{i});%��Ϊ�ַ��ͣ����ת��ΪNaN
    XDouble(i) = str2double(XStr{i});
    YDouble(i) = str2double(YStr{i});
    WDouble(i) = str2double(WStr{i});
    HDouble(i) = str2double(HStr{i});
end

[~,InitalNum] = find(SeriesNumDouble==1);%Ѱ��ÿ��ͼƬ����ʼλ��
RectNum = SeriesNumDouble(end);%�����ж��ٸ����ο�
template = [];%��¼ģ����Ϣ
template.CompanyName = TextInfo{InitalNum,CompanyName};%��text_info�����ȡ����Ӧ��˾����
template.DocumentType =  TextInfo{InitalNum,DocumentType};%��text_info�����ȡ����Ӧ��֤����
template.FilePath =  TextInfo{InitalNum,FilePath};%��text_info�����ȡ����Ӧ·��
template.TemplateType =  TextInfo{InitalNum,TemplateType};%��text_info�����ȡ����Ӧģ������
template.PageFlag =  TextInfo{InitalNum,PageFlag};%��text_info�����ȡ����Ӧ��ҳ���
template.TableFlag =  TextInfo{InitalNum,TableFlag};%��text_info�����ȡ����Ӧ ���� �Ƿ�Ϊ�������
for j = 1:RectNum
    TempOrder = InitalNum + j - 1;
    x = XDouble(TempOrder);
    y = YDouble(TempOrder);
    w = WDouble(TempOrder);
    h = HDouble(TempOrder);
    template.rect{j}.pos = [x,y,w,h];%�ӱ����ȡ����Ӧ���ο�
    
    template.rect{j}.FeatureFlag = TextInfo(TempOrder,FeatureFlag);%ȡ���������
    template.rect{j}.DatabaseTablename =  TextInfo{InitalNum,DatabaseTablename};%��text_info�����ȡ����Ӧ ��������.����
    template.rect{j}.DatabaseColname =  TextInfo{InitalNum,DatabaseColname};%��text_info�����ȡ����Ӧ ��������.����
end

