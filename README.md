---
typora-copy-images-to: ./image
---

# 基于Fastlane+Jenkins+Github+MAMP+iPATools搭建本地ATO内网ipa安装环境

## 需要的安装的软件

* MAMP
* Fastlane
* Jenkins
* iPATools

## 第一步 安装MAMP

![DE1E4C0B-345C-474C-90EC-E85608ED0FBE](image/DE1E4C0B-345C-474C-90EC-E85608ED0FBE.png)

前往下载地址->https://www.mamp.info/en/downloads/

下载安装完毕 启动服务 设置端口如下

![46CAF440-CE51-401C-A0EB-CA60FADE9898](image/46CAF440-CE51-401C-A0EB-CA60FADE9898.png)

**需要注意的是端口要设置8888 如果设置其他接口请用iPATools工具设置默认端口是读取8888**

我们拖拽**/Applications/MAMP/htdocs**文件夹快捷菜单上面

![1ECA2141-A7C0-4E44-93A7-1252F94D1EAB](image/1ECA2141-A7C0-4E44-93A7-1252F94D1EAB.png)

**这个主要是方便我们以后操作文件**

## 第二部 配置存放plist文件的库

![96D17FB4-4AEB-4DB4-931C-AA839EC56ECA](image/96D17FB4-4AEB-4DB4-931C-AA839EC56ECA.png)

**我们要设置库名称为iPAToolsPlist如果是其他的需要通过iPATools 工具进行配置**

我们使用**SSH**的方式进行clone到我们的网站根目录**/Applications/MAMP/htdocs**

![668DA803-EABD-42FF-BA5C-FD2551B9BEB9](image/668DA803-EABD-42FF-BA5C-FD2551B9BEB9.png)

**为什么我们要使用SSH的方式呢？因为使用SSH这样对于我们脚本执行上传很方便！**

我们在**/Applications/MAMP/htdocs**新建一个文件夹ipa用来存放我们打包出来的ipa安装包



