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

mailto_profStatus = profile('status');
if strcmp(mailto_profStatus.ProfilerStatus,'off')
    fprintf('��ϣ��ͳ�Ƴ����������ܣ��������ĳ�����ǰ��Ӵ��룺\n profile on;')
    mailto_profStatus = 0;
else
    profile off;
    mailto_profStatus = 1;
end
%% Ĭ������
[emailto,mailto_subject,mailto_content,mailto_saveVar,mailto_delTempFiles] = sortInputs(varargin{:});
%% ----------------------------------------------%
mailto_timestamp = datetime;
mailto_timestamp.Format = 'uuuuMMddHHmmss';
mailto_demoTimestamp = char(mailto_timestamp);
mailto_cur_mfile = mfilename('fullpath');
mailto_cur_mfile_path_index = strfind(mailto_cur_mfile,'\');
mailto_cur_mfile_path = mailto_cur_mfile(1:mailto_cur_mfile_path_index(end));
mkdir(mailto_cur_mfile_path,mailto_demoTimestamp);
if strcmp(mailto_saveVar,'workspace')
    save(strcat(mailto_cur_mfile_path,mailto_demoTimestamp,'\BasicWorkspace.mat')); %���湤���ռ�
    mailto_content{end+1} = '�ѱ������������ռ������';
elseif ~isempty(mailto_saveVar)
    try
        save(strcat(mailto_cur_mfile_path,mailto_demoTimestamp,'\Var.mat'),mailto_saveVar{:});
        mailto_saveVarStr = strcat(mailto_saveVar,'��  ');
        mailto_content{end+1} = strcat('�ѱ��������',mailto_saveVarStr{:});
    catch Ecept_error
        mailto_content{end+1} = strcat('�����ռ䱣�淢���쳣:\n identifier��',Ecept_error.identifier,'\n message��',Ecept_error.message);
        fprintf('\n\n');
        fprintf(strcat('�����ռ䱣�淢���쳣:\n identifier��',Ecept_error.identifier,'\n message��',Ecept_error.message));
        fprintf('����������ı������Ƿ���ȷ����ʹ����ȷ�����');
        help mailto;
        mailto_delTempFiles = 'n';%��ɾ����ʱ�ļ�
    end
end
try
    mailto_h_fig = findall(0,'type','figure');
    mailto_h_fig_len = length(mailto_h_fig);
    mailto_content{end+1} = strcat('����⵽',num2str(mailto_h_fig_len),'��figureͼ��');
    for mailto_i = 1:mailto_h_fig_len
        if isempty(mailto_h_fig(mailto_i).Number)
            mailto_h_fig_save_name = mailto_h_fig(mailto_i).Name;
        else
            mailto_h_fig_save_name = num2str(mailto_h_fig(mailto_i).Number);
        end
        saveas(mailto_h_fig(mailto_i),strcat(mailto_cur_mfile_path,mailto_demoTimestamp,'/',mailto_h_fig_save_name,'.png'));
    end
    mailto_attachmentdir = dir(fullfile(mailto_cur_mfile_path,mailto_demoTimestamp));
    mailto_attachmentdir = mailto_attachmentdir(3:end); %ȥ��.��..Ŀ¼
    mailto_attachment = strcat({mailto_attachmentdir.folder},'\',{mailto_attachmentdir.name});
catch Ecept_error
    mailto_content{end+1} = strcat('ͼƬ���淢���쳣��  identifier��',Ecept_error.identifier,'   message��',Ecept_error.message);
    mailto_attachment = {};
    mailto_delTempFiles = 'n';
end
mailto_content = HtmlMailMsg(mailto_profStatus,mailto_content);
%SendToServer(mailto_demoTimestamp,mailto_content,mailto_attachment)
fprintf(['\n�ʼ���������:',emailto,'\n']);
Sendmail( emailto , mailto_subject , mailto_content , mailto_attachment );

fprintf('\n---------------------------------\n�ѳɹ������ʼ���\n');
if(~exist('mailto_delTempFiles','var'))
    mailto_delTempFiles ='Y';
end
if sum(mailto_delTempFiles == 'Y'| mailto_delTempFiles == 'y')
    rmdir(strcat(mailto_cur_mfile_path,mailto_demoTimestamp),'s');
end

function [emailto,mailto_subject,mailto_content,mailto_saveVar,mailto_delTempFiles] = sortInputs(varargin)
emailto = '840529151@qq.com';           %Ĭ����ϵ������
mailto_subject = '�������MATLAB';      %Ĭ���ʼ�����
mailto_content = {};
mailto_saveVar = {};                    %Ĭ�ϲ����湤���ռ�
mailto_delTempFiles ='Y';               %ɾ����ʱ�ļ�
if nargin == 0
    % ʹ��Ĭ������
else
    pat = '([A-Za-z0-9\u4e00-\u9fa5]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+)?';
    r = regexp(varargin{1},pat,'match');
    if ~isempty(r)
        emailto = r;
    end
    if nargin > 1
       subject = labelVaule('subject',varargin{:});
       if ~isempty(subject)
           mailto_subject = subject;
       end
       content = labelVaule('content',varargin{:});
       if ~isempty(content)
           mailto_content = {content};
       end
       saveVar = labelVaule('saveVar',varargin{:});
       if ~isempty(saveVar)
           mailto_saveVar = strsplit(saveVar,',');
       end
       delTempFiles = labelVaule('delTempFiles',varargin{:});
       if ~isempty(delTempFiles)
           mailto_delTempFiles = delTempFiles;
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




