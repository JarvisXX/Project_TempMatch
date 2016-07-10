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
	if strcmp(temp,'路径')  FilePath = i; end
	if strcmp(temp,'公司名称')     CompanyName = i; end
	if strcmp(temp,'单证类型')     DocumentType = i; end
	if strcmp(temp,'模板类型')  TemplateType = i; end
	if strcmp(temp,'多页标记')  PageFlag = i; end
	if strcmp(temp,'纯表格')  TableFlag = i; end
	if strcmp(temp,'坐标序号')  SeriesNum = i; end
	if strcmp(temp,'X坐标')         Xorder = i;end
	if strcmp(temp,'Y坐标')         Yorder = i;end
	if strcmp(temp,'宽度')    Worder = i;end
	if strcmp(temp,'高度')    Horder = i;end
	if strcmp(temp,'坐标特征')    FeatureFlag = i;end
	if strcmp(temp,'数据属性.表名')    DatabaseTablename = i;end
    if strcmp(temp,'数据属性.列名')    DatabaseColname = i;end
end
    
for i = 1:size(numberInfo,1)
    a = numberInfo(i,PageFlag);
    TextInfo{i+1,PageFlag} = num2str(a);%将多页标记存入TextInfo中

    b = numberInfo(i,TableFlag);
    TextInfo{i+1,TableFlag} = num2str(b);%将纯表格存入TextInfo中

    c = numberInfo(i,IDName);
    TextInfo{i+1,IDName} = num2str(c);%将纯表格存入ID中

    if SeriesNum <= size(numberInfo,2)
        d =numberInfo(i,SeriesNum);
        if ~isnan(d)
            TextInfo{i+1,SeriesNum} = num2str(d);%将坐标序号存入ID中
        end
    end
end
%-------------将数字内容中的字符类型转换为double型-----------------
SeriesNumStr = TextInfo(1:end,SeriesNum);%取出模板内容的列标记（字符串类型）
SeriesNumDouble = zeros(1,TextRow);%转换为double型

XStr = TextInfo(1:end,Xorder);%取出模板内容的X方向坐标（字符串类型）
XDouble = zeros(1,TextRow);%转换为double型
YStr = TextInfo(1:end,Yorder);%取出模板内容的Y方向坐标（字符串类型）
YDouble = zeros(1,TextRow);%转换为double型
WStr = TextInfo(1:end,Worder);%取出模板内容的Weight坐标（字符串类型）
WDouble = zeros(1,TextRow);%转换为double型
HStr = TextInfo(1:end,Horder);%取出模板内容的Height坐标（字符串类型）
HDouble = zeros(1,TextRow);%转换为double型
for i = 1:TextRow
    SeriesNumDouble(i) = str2double(SeriesNumStr{i});%若为字符型，则会转换为NaN
    XDouble(i) = str2double(XStr{i});
    YDouble(i) = str2double(YStr{i});
    WDouble(i) = str2double(WStr{i});
    HDouble(i) = str2double(HStr{i});
end

[~,InitalNum] = find(SeriesNumDouble==1);%寻找每张图片的起始位置
RectNum = SeriesNumDouble(end);%计算有多少个矩形框
template = [];%记录模板信息
template.CompanyName = TextInfo{InitalNum,CompanyName};%从text_info表格中取出对应公司名称
template.DocumentType =  TextInfo{InitalNum,DocumentType};%从text_info表格中取出对应单证类型
template.FilePath =  TextInfo{InitalNum,FilePath};%从text_info表格中取出对应路径
template.TemplateType =  TextInfo{InitalNum,TemplateType};%从text_info表格中取出对应模板类型
template.PageFlag =  TextInfo{InitalNum,PageFlag};%从text_info表格中取出对应多页标记
template.TableFlag =  TextInfo{InitalNum,TableFlag};%从text_info表格中取出对应 表体 是否为纯表格标记
for j = 1:RectNum
    TempOrder = InitalNum + j - 1;
    x = XDouble(TempOrder);
    y = YDouble(TempOrder);
    w = WDouble(TempOrder);
    h = HDouble(TempOrder);
    template.rect{j}.pos = [x,y,w,h];%从表格中取出对应矩形框
    
    template.rect{j}.FeatureFlag = TextInfo(TempOrder,FeatureFlag);%取出特征标记
    template.rect{j}.DatabaseTablename =  TextInfo{InitalNum,DatabaseTablename};%从text_info表格中取出对应 数据属性.表名
    template.rect{j}.DatabaseColname =  TextInfo{InitalNum,DatabaseColname};%从text_info表格中取出对应 数据属性.列名
end

