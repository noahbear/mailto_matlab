# mailto
##### 本程序用于运行程序结束后发送邮件提示并将
##### MATLAB所有figure保存为.png图片附件一并发送至指定邮箱!
##### Author: noahbear@sina.com   https://www.noahbear.top

* 使用方法：
    ##### 将以下代码添加至您的脚本最后
    ```
    mailto('xxxx@xxx.xx');
    ```
    ##### 若希望统计程序运行性能，请在您的程序最前添加代码:
    ```
    profile on;
    ```

    ##### [可选]若希望保存工作空间，并发送.mat格式邮件附件请使用参数：
     ```
     mailto('saveVar', 'workspace');     %保存整个工作空间
     mailto('saveVar', 'a,b,c');         %保存变量 a, b, c
     ```
    ##### [可选]其他可选参数：
     ```
     mailto('subject', '发自你的MATLAB'); %设定邮件主题
     mailto('delTempFiles', 'N');        %是否删除临时文件（如png图、mat文件）[Y/N]
     ```
  
* 使用范例
   ```
   mailto('noahbear@sina.com','subject','测试程序','saveVar','workspace');
   ```
