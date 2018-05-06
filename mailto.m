function mailto(varargin)
%% �������������г�����������ʼ���ʾ
% �������������г�����������ʼ���ʾ
% ����MATLAB����figure����Ϊ.pngͼƬ����һ��������ָ�����䣡
%                 Author: noahbear@sina.com   https://www.noahbear.top
%     _______________________________________________________________
%    ʹ�÷������������´�����������Ľű����
%     mailto('xxxx@xxx.xx');
%     _______________________________________________________________
%    ��ϣ��ͳ�Ƴ����������ܣ��������ĳ�����ǰ��Ӵ��룺
%     profile on;
%     _______________________________________________________________
%    ����ѡ����ϣ�����湤���ռ䣬������.mat��ʽ�ʼ�������ʹ�ò�����
%           mailto('saveVar', 'workspace');     %�������������ռ�
%           mailto('saveVar', 'a,b,c');         %������� a, b, c
%    ����ѡ��������ѡ������
%           mailto('subject', '�������MATLAB'); %�趨�ʼ�����
%           mailto('delTempFiles', 'N');        %�Ƿ�ɾ����ʱ�ļ�����pngͼ��mat�ļ�����Y/N��
%     ------------------------------ʹ�÷���-------------------------
%     mailto('noahbear@sina.com','subject','���Գ���','saveVar','workspace');
%

profStatus = profile('status');
if strcmp(profStatus.ProfilerStatus,'off')
    fprintf('��ϣ��ͳ�Ƴ����������ܣ��������ĳ�����ǰ��Ӵ��룺\n profile on;')
    profStatus = 0;
else
    profile off;
    profStatus = 1;
end
%% Ĭ������
[emailto,subject,content,saveVar,delTempFiles] = sortInputs(varargin{:});
%% ----------------------------------------------%
timestamp = datetime;
timestamp.Format = 'uuuuMMddHHmmss';
demoTimestamp = char(timestamp);
curMfile = mfilename('fullpath');
curMfilePath_index = strfind(curMfile,'\');
curMfilePath = curMfile(1:curMfilePath_index(end));
mkdir(curMfilePath,demoTimestamp);
if strcmp(saveVar,'workspace')
    evalin('base',['save(strcat(''' , curMfilePath , ''',''' , demoTimestamp, ''',''\BasicWorkspace.mat''))']); %���湤���ռ�
    content{end+1} = '�ѱ������������ռ������';
elseif ~isempty(saveVar)
    try
        saveVarStr = strcat('''',saveVar,''',');
        saveVarStr{end} = saveVarStr{end}(1:end-1);
        %saveVarStr = strcat(saveVar,'��  ');
        evalin('base',['save(strcat(''' , curMfilePath , ''',''' , demoTimestamp, ''',''\Var.mat''),',saveVarStr{:} ,')']);
        %save(strcat(curMfilePath,demoTimestamp,'\Var.mat'),saveVar{:});
        
        content{end+1} = strcat('�ѱ��������',saveVarStr{:});
    catch Ecept_error
        content{end+1} = strcat('�����ռ䱣�淢���쳣:\n identifier��',Ecept_error.identifier,'\n message��',Ecept_error.message);
        fprintf('\n\n');
        fprintf(strcat('�����ռ䱣�淢���쳣:\n identifier��',Ecept_error.identifier,'\n message��',Ecept_error.message));
        fprintf('����������ı������Ƿ���ȷ����ʹ����ȷ�����');
        help mailto;
        delTempFiles = 'n';%��ɾ����ʱ�ļ�
    end
end
try
    Hfig = findall(0,'type','figure');
    HfigLen = length(Hfig);
    content{end+1} = strcat('����⵽',num2str(HfigLen),'��figureͼ��');
    for i = 1:HfigLen
        if isempty(Hfig(i).Number)
            h_fig_save_name = Hfig(i).Name;
        else
            h_fig_save_name = num2str(Hfig(i).Number);
        end
        saveas(Hfig(i),strcat(curMfilePath,demoTimestamp,'/',h_fig_save_name,'.png'));
    end
    attachmentdir = dir(fullfile(curMfilePath,demoTimestamp));
    attachmentdir = attachmentdir(3:end); %ȥ��.��..Ŀ¼
    attachment = strcat({attachmentdir.folder},'\',{attachmentdir.name});
catch Ecept_error
    content{end+1} = strcat('ͼƬ���淢���쳣��  identifier��',Ecept_error.identifier,'   message��',Ecept_error.message);
    attachment = {};
    delTempFiles = 'n';
end
content = HtmlMailMsg(profStatus,content);
%SendToServer(demoTimestamp,content,attachment)
fprintf(['\n�ʼ���������:',emailto,'\n']);
Sendmail( emailto , subject , content , attachment );

fprintf('\n---------------------------------\n�ѳɹ������ʼ���\n');
if(~exist('delTempFiles','var'))
    delTempFiles ='Y';
end
if sum(delTempFiles == 'Y'| delTempFiles == 'y')
    rmdir(strcat(curMfilePath,demoTimestamp),'s');
end

function [emailto,subject,content,saveVar,delTempFiles] = sortInputs(varargin)
emailto = 'noahbear@sina.com';           %Ĭ����ϵ������
subject = '�������MATLAB';      %Ĭ���ʼ�����
content = {};
saveVar = {};                    %Ĭ�ϲ����湤���ռ�
delTempFiles ='Y';               %ɾ����ʱ�ļ�
if nargin == 0
    % ʹ��Ĭ������
else
    pat = '([A-Za-z0-9\u4e00-\u9fa5]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+)?';
    r = regexp(varargin{1},pat,'match');
    if ~isempty(r)
        emailto = r;
    end
    if nargin > 1
       subj = labelVaule('subject',varargin{:});
       if ~isempty(subj)
           subject = subj;
       end
       content = labelVaule('content',varargin{:});
       if ~isempty(content)
           content = {content};
       end
       saveVar = labelVaule('saveVar',varargin{:});
       if ~isempty(saveVar)
           saveVar = strsplit(saveVar,',');
       end
       delTempFile = labelVaule('delTempFiles',varargin{:});
       if ~isempty(delTempFile)
           delTempFiles = delTempFile;
       end
    end
end

function value = labelVaule(labelname,varargin)
value = [];
a = strcmpi(varargin,labelname);
idx = find(a == 1);
if ~isempty(idx) && idx<nargin
    value = varargin{idx+1};
end




