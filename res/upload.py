#coding:utf-8
#ftp演示，首先要在本机或远程服务器开启ftp功能
import sys,os,ftplib,socket
print("=====================FTP Client=====================");

HOST = 'v0.ftp.upyun.com'  #FTP主机
PORT = "21"
user = "script/online365"
password = "cx0eUfEnfyx4LiJr79dE9xjZARcJJLQY"
buffer_size = 8192

#连接登陆
def connect():
    try:
        ftp = ftplib.FTP(HOST)
        ftp.login(user, password)#登录，参数user，password，acct均是可选参数，
         #f.login(user="user", passwd="password")
        return ftp
    except (socket.error,socket.gaierror):
        print("FTP登陆失败，请检查主机号、用户名、密码是否正确")
        sys.exit(0)
    print('已连接到： "%s"' % HOST)

#中断并退出
def disconnect(ftp):
    ftp.quit()  #FTP.close()：单方面的关闭掉连接。FTP.quit():发送QUIT命令给服务器并关闭掉连接

#上传文件
def upload(ftp, filepath):
    f = open(filepath, "rb")
    file_name = os.path.split(filepath)[-1]
    try:
        ftp.storbinary('STOR %s'%file_name, f, buffer_size)
        print('upload Success:  "%s"' % file_name)
    except ftplib.error_perm:
        print('upload Failure:  "%s"' % file_name)
        return False
    return True

#下载文件
def download(ftp, filename):
    f = open(filename,"wb").write
    try:
        ftp.retrbinary("RETR %s"%filename, f, buffer_size)
        print('成功下载文件： "%s"' % filename)
    except ftplib.error_perm:
        return False
    return True

#获取目录下文件或文件夹想详细信息
def listinfo(ftp):
    ftp.dir()  


#查找是否存在指定文件    
def find(ftp,filename):
    ftp_f_list = ftp.nlst()  #获取目录下文件、文件夹列表
    if filename in ftp_f_list:
        return True
    else:
        return False



def main():
    ftp = connect()                  #连接登陆ftp
    dirpath = '/shA'                   #目录，不能使用lp/lp1这种多级创建，而且要保证你的ftp目录，右键属性不能是只读的
    try: ftp.mkd(dirpath)                 #新建远程目录
    except ftplib.error_perm:
        print("目录已经存在或无法创建")
    try:ftp.cwd(dirpath)             #重定向到指定路径
    except ftplib.error_perm:
        print('不可以进入目录："%s"' % dirpath)
    print(ftp.pwd())                        #返回当前所在位置
    # try: ftp.mkd("dir1")                  #在当前路径下创建dir1文件夹
    # except ftplib.error_perm:
    #     print("目录已经存在或无法创建")
    upload(ftp,"F:/ScriptWork/shihun/version.txt")       #上传本地文件
    upload(ftp,"F:/ScriptWork/shihun/endtime.txt")       #上传本地文件
    upload(ftp,"F:/ScriptWork/shihun/lib.lua")       #上传本地文件
    upload(ftp,"F:/ScriptWork/shihun/ShiHun.lua")       #上传本地文件
    upload(ftp,"F:/ScriptWork/shihun/picll.lua")       #上传本地文件
    upload(ftp,"F:/ScriptWork/shihun/startgame.lua")       #上传本地文件
    # filename="test1.txt"
    # ftp.rename("test.txt", filename) #文件改名
    # if os.path.exists(filename):   #判断本地文件是否存在
    #     os.unlink(filename)    #如果存在就删除
    # download(ftp,filename)        #下载ftp文件
    listinfo(ftp)                   #打印目录下每个文件或文件夹的详细信息
    files = ftp.nlst()              #获取路径下文件或文件夹列表
    print(files)


    # ftp.delete(filename)              #删除远程文件    
    # ftp.rmd("dir1")                  #删除远程目录
    ftp.quit()  #退出

if __name__ == '__main__':
    main()