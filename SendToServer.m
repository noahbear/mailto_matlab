function res = SendToServer(demoTimestamp,theMessage,attachments)
% author: [Harbin Engneering Univ] noahbear@sina.com  http://www.noahbear.top

%serverURL = 'https://www.noahbear.top/sites/matlab/recv.php';
%serverURL = 'http://localhost/b.php';
serverURL = 'https://www.noahbear.top/cgi-bin/h.py';

MsgURL = [serverURL, '?tid=', char(demoTimestamp), '&type=html'];
opt = weboptions;
opt.CharacterEncoding = 'UTF-8';
opt.MediaType = 'text/html';
res = webwrite(MsgURL,theMessage,opt);
for i = 1:length(attachments)
    PngFilePath = attachments{i};
    [~,name,ext]=fileparts(PngFilePath);
    f = fopen(PngFilePath, 'r');
    data = char(fread(f)');
    fclose(f);
    PngURL = [serverURL, '?tid=', char(demoTimestamp), '&type=', ext(2:end), '&name=', name];
    d = {''}
    
    
    opt = weboptions;
    opt.CharacterEncoding = 'ISO-8859-1';
    opt.MediaType = 'application/octet-stream';
    res = webwrite(PngURL,data,opt);
end
