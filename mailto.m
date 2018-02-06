%% �������������г�����������ʼ���ʾ������MATLAB����figure����Ϊ.pngͼƬ����һ��������ָ�����䣡
%                 Author: 840529151@qq.com   https://www.noahbear.top
%     _______________________________________________________________
%    ʹ�÷������������´�����������Ľű����
%     emailto = 'xxxx@xxx.xx'; %��������
%     mailto;
%     _______________________________________________________________
%    ��ϣ��ͳ�Ƴ�������ʱ�䣬�������ĳ�����ǰ��Ӵ��룺
%     profile on;
%     _______________________________________________________________
%    ����ѡ����ϣ�����湤���ռ䣬������.mat��ʽ�ʼ���������mailto;ǰ��Ӽӣ�
%           mailto_saveVar = {'workspace'};  %�������������ռ�
%           mailto_saveVar = {'a','b','c'};  %������� a, b, c
%    ����ѡ��������ѡ������
%           mailto_subject = '�������MATLAB'; %�趨�ʼ�����
%           mailto_delTempFiles = 'Y';            %�Ƿ�ɾ����ʱ�ļ�����pngͼ��mat�ļ�����Y/N��
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
if(~exist('emailto','var'))
    emailto = '840529151@qq.com';           %Ĭ����ϵ������
    fprintf(strcat('\n�ʼ���������:',emailto,'\n��ϣ���޸����䣬�������ĳ����м�����룺\n emailto = ''��������''; \n'));
end
if(~exist('mailto_subject','var'))
    mailto_subject = '�������MATLAB';      %Ĭ���ʼ�����
end
if(~exist('mailto_saveVar','var'))
    mailto_saveVar = {};                    %Ĭ�ϲ����湤���ռ�
end
if(~exist('mailto_saveVar','var'))
    mailto_delTempFiles ='Y';               %ɾ����ʱ�ļ�
end
%% ----------------------------------------------%
mailto_content = {};
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
Sendmail( emailto , mailto_subject , mailto_content , mailto_attachment );

fprintf('\n---------------------------------\n�ѳɹ������ʼ���\n');
clear emailto_content emailto_subject mailto_timestamp mailto_i mailto_attachment mailto_attachmentdir mailto_content
clear mailto_cur_mfile mailto_cur_mfile_path_index mailto_h_fig_len mailto_saveVarStr mailto_saveVar mailto_subject mailto_h_fig_save_name
clear mailto_h_fig mailto_host mailto_mail mailto_port mailto_props mailto_psswd mailto_s_msg mailto_profStatus ans
if(~exist('mailto_delTempFiles','var'))
    mailto_delTempFiles ='Y';
end
if sum(mailto_delTempFiles == 'Y'| mailto_delTempFiles == 'y')
    rmdir(strcat(mailto_cur_mfile_path,mailto_demoTimestamp),'s');
end
clear mailto_cur_mfile_path mailto_demoTimestamp mailto_delTempFiles

