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

profStatus = profile('status');
if strcmp(profStatus.ProfilerStatus,'off')
    fprintf('若希望统计程序运行性能，请在您的程序最前添加代码：\n profile on;')
    profStatus = 0;
else
    profile off;
    profStatus = 1;
end
%% 默认设置
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
    evalin('base',['save(strcat(''' , curMfilePath , ''',''' , demoTimestamp, ''',''\BasicWorkspace.mat''))']); %保存工作空间
    content{end+1} = '已保存整个工作空间变量。';
elseif ~isempty(saveVar)
    try
        saveVarStr = strcat('''',saveVar,''',');
        saveVarStr{end} = saveVarStr{end}(1:end-1);
        %saveVarStr = strcat(saveVar,'；  ');
        evalin('base',['save(strcat(''' , curMfilePath , ''',''' , demoTimestamp, ''',''\Var.mat''),',saveVarStr{:} ,')']);
        %save(strcat(curMfilePath,demoTimestamp,'\Var.mat'),saveVar{:});
        
        content{end+1} = strcat('已保存变量：',saveVarStr{:});
    catch Ecept_error
        content{end+1} = strcat('工作空间保存发生异常:\n identifier：',Ecept_error.identifier,'\n message：',Ecept_error.message);
        fprintf('\n\n');
        fprintf(strcat('工作空间保存发生异常:\n identifier：',Ecept_error.identifier,'\n message：',Ecept_error.message));
        fprintf('请检查您输入的变量名是否正确，并使用正确的语句');
        help mailto;
        delTempFiles = 'n';%不删除临时文件
    end
end
try
    Hfig = findall(0,'type','figure');
    HfigLen = length(Hfig);
    content{end+1} = strcat('共检测到',num2str(HfigLen),'张figure图。');
    for i = 1:HfigLen
        if isempty(Hfig(i).Number)
            h_fig_save_name = Hfig(i).Name;
        else
            h_fig_save_name = num2str(Hfig(i).Number);
        end
        saveas(Hfig(i),strcat(curMfilePath,demoTimestamp,'/',h_fig_save_name,'.png'));
    end
    attachmentdir = dir(fullfile(curMfilePath,demoTimestamp));
    attachmentdir = attachmentdir(3:end); %去除.及..目录
    attachment = strcat({attachmentdir.folder},'\',{attachmentdir.name});
catch Ecept_error
    content{end+1} = strcat('图片保存发生异常：  identifier：',Ecept_error.identifier,'   message：',Ecept_error.message);
    attachment = {};
    delTempFiles = 'n';
end
content = HtmlMailMsg(profStatus,content);
%SendToServer(demoTimestamp,content,attachment)
fprintf(['\n邮件将发送至:',emailto,'\n']);
Sendmail( emailto , subject , content , attachment );

fprintf('\n---------------------------------\n已成功发送邮件！\n');
if(~exist('delTempFiles','var'))
    delTempFiles ='Y';
end
if sum(delTempFiles == 'Y'| delTempFiles == 'y')
    rmdir(strcat(curMfilePath,demoTimestamp),'s');
end

function [emailto,subject,content,saveVar,delTempFiles] = sortInputs(varargin)
emailto = 'noahbear@sina.com';           %默认联系人邮箱
subject = '发自你的MATLAB';      %默认邮件主题
content = {};
saveVar = {};                    %默认不保存工作空间
delTempFiles ='Y';               %删除临时文件
if nargin == 0
    % 使用默认设置
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




