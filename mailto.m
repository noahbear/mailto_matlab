%% 本程序用于运行程序结束后发送邮件提示，并将MATLAB所有figure保存为.png图片附件一并发送至指定邮箱！
%                 Author: 840529151@qq.com   https://www.noahbear.top
%     _______________________________________________________________
%    使用方法：（将以下代码添加至您的脚本最后）
%     emailto = 'xxxx@xxx.xx'; %您的邮箱
%     mailto;
%     _______________________________________________________________
%    若希望统计程序运行时间，请在您的程序最前添加代码：
%     profile on;
%     _______________________________________________________________
%    【可选】若希望保存工作空间，并发送.mat格式邮件附件请在mailto;前添加加：
%           mailto_saveVar = {'workspace'};  %保存整个工作空间
%           mailto_saveVar = {'a','b','c'};  %保存变量 a, b, c
%    【可选】其他可选参数：
%           mailto_subject = '发自你的MATLAB'; %设定邮件主题
%           mailto_delTempFiles = 'Y';            %是否删除临时文件（如png图、mat文件）【Y/N】
%

mailto_profStatus = profile('status');
if strcmp(mailto_profStatus.ProfilerStatus,'off')
    fprintf('若希望统计程序运行性能，请在您的程序最前添加代码：\n profile on;')
    mailto_profStatus = 0;
else
    profile off;
    mailto_profStatus = 1;
end
%% 默认设置
if(~exist('emailto','var'))
    emailto = '840529151@qq.com';           %默认联系人邮箱
    fprintf(strcat('\n邮件将发送至:',emailto,'\n若希望修改邮箱，请在您的程序中加入代码：\n emailto = ''您的邮箱''; \n'));
end
if(~exist('mailto_subject','var'))
    mailto_subject = '发自你的MATLAB';      %默认邮件主题
end
if(~exist('mailto_saveVar','var'))
    mailto_saveVar = {};                    %默认不保存工作空间
end
if(~exist('mailto_saveVar','var'))
    mailto_delTempFiles ='Y';               %删除临时文件
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
    save(strcat(mailto_cur_mfile_path,mailto_demoTimestamp,'\BasicWorkspace.mat')); %保存工作空间
    mailto_content{end+1} = '已保存整个工作空间变量。';
elseif ~isempty(mailto_saveVar)
    try
        save(strcat(mailto_cur_mfile_path,mailto_demoTimestamp,'\Var.mat'),mailto_saveVar{:});
        mailto_saveVarStr = strcat(mailto_saveVar,'；  ');
        mailto_content{end+1} = strcat('已保存变量：',mailto_saveVarStr{:});
    catch Ecept_error
        mailto_content{end+1} = strcat('工作空间保存发生异常:\n identifier：',Ecept_error.identifier,'\n message：',Ecept_error.message);
        fprintf('\n\n');
        fprintf(strcat('工作空间保存发生异常:\n identifier：',Ecept_error.identifier,'\n message：',Ecept_error.message));
        fprintf('请检查您输入的变量名是否正确，并使用正确的语句');
        help mailto;
        mailto_delTempFiles = 'n';%不删除临时文件
    end
end
try
    mailto_h_fig = findall(0,'type','figure');
    mailto_h_fig_len = length(mailto_h_fig);
    mailto_content{end+1} = strcat('共检测到',num2str(mailto_h_fig_len),'张figure图。');
    for mailto_i = 1:mailto_h_fig_len
        if isempty(mailto_h_fig(mailto_i).Number)
            mailto_h_fig_save_name = mailto_h_fig(mailto_i).Name;
        else
            mailto_h_fig_save_name = num2str(mailto_h_fig(mailto_i).Number);
        end
        saveas(mailto_h_fig(mailto_i),strcat(mailto_cur_mfile_path,mailto_demoTimestamp,'/',mailto_h_fig_save_name,'.png'));
    end
    mailto_attachmentdir = dir(fullfile(mailto_cur_mfile_path,mailto_demoTimestamp));
    mailto_attachmentdir = mailto_attachmentdir(3:end); %去除.及..目录
    mailto_attachment = strcat({mailto_attachmentdir.folder},'\',{mailto_attachmentdir.name});
catch Ecept_error
    mailto_content{end+1} = strcat('图片保存发生异常：  identifier：',Ecept_error.identifier,'   message：',Ecept_error.message);
    mailto_attachment = {};
    mailto_delTempFiles = 'n';
end
mailto_content = HtmlMailMsg(mailto_profStatus,mailto_content);
%SendToServer(mailto_demoTimestamp,mailto_content,mailto_attachment)
Sendmail( emailto , mailto_subject , mailto_content , mailto_attachment );

fprintf('\n---------------------------------\n已成功发送邮件！\n');
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

