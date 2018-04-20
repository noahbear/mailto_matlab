function mailto(varargin)
%% 本程序用于运行程序结束后发送邮件提示
% 本程序用于运行程序结束后发送邮件提示
% 并将MATLAB所有figure保存为.png图片附件一并发送至指定邮箱！
%                 Author: noahbear@sina.com   https://www.noahbear.top
%     _______________________________________________________________
%    使用方法：（将以下代码添加至您的脚本最后）
%     mailto('xxxx@xxx.xx');
%     _______________________________________________________________
%    若希望统计程序运行性能，请在您的程序最前添加代码：
%     profile on;
%     _______________________________________________________________
%    【可选】若希望保存工作空间，并发送.mat格式邮件附件请使用参数：
%           mailto('saveVar', 'workspace');     %保存整个工作空间
%           mailto('saveVar', 'a,b,c');         %保存变量 a, b, c
%    【可选】其他可选参数：
%           mailto('subject', '发自你的MATLAB'); %设定邮件主题
%           mailto('delTempFiles', 'N');        %是否删除临时文件（如png图、mat文件）【Y/N】
%     ------------------------------使用范例-------------------------
%     mailto('noahbear@sina.com','subject','测试程序','saveVar','workspace');
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
fprintf(['\n邮件将发送至:',emailto,'\n']);
Sendmail( emailto , mailto_subject , mailto_content , mailto_attachment );

fprintf('\n---------------------------------\n已成功发送邮件！\n');
if(~exist('mailto_delTempFiles','var'))
    mailto_delTempFiles ='Y';
end
if sum(mailto_delTempFiles == 'Y'| mailto_delTempFiles == 'y')
    rmdir(strcat(mailto_cur_mfile_path,mailto_demoTimestamp),'s');
end

function [emailto,mailto_subject,mailto_content,mailto_saveVar,mailto_delTempFiles] = sortInputs(varargin)
emailto = '840529151@qq.com';           %默认联系人邮箱
mailto_subject = '发自你的MATLAB';      %默认邮件主题
mailto_content = {};
mailto_saveVar = {};                    %默认不保存工作空间
mailto_delTempFiles ='Y';               %删除临时文件
if nargin == 0
    % 使用默认设置
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




