# 源jar路径  即jenkins构建后存放的路径
SOURCE_PATH=/var/lib/jenkins/workspace
#jenkins工作空间名 docker 镜像/容器名字或者jar名字 这里都命名为这个
SERVER_NAME=jenkinsDemo
#服务器存放执行jar包的路径
BASE_PATH=/usr/jenkins-demo-jar
#项目版本
JAR_VERSION=0.0.1-SNAPSHOT
echo "最新构建代码 $SOURCE_PATH/$SERVER_NAME/target/$SERVER_NAME-$JAR_VERSION.jar 迁移至 $BASE_PATH ...."
#把项目从jenkins构建后的目录移动到我们的项目目录下同时重命名下
 mv $SOURCE_PATH/$SERVER_NAME/target/$SERVER_NAME-$JAR_VERSION.jar $BASE_PATH/$SERVER_NAME.jar
echo "迁移完成"
echo "准备部署"
echo "准备关闭原java进程"
#!/bin/bash
PID=$(ps -ef | grep $SERVER_NAME.jar | grep -v grep | awk '{ print $2 }')
if [ -z "$PID" ]
then
    echo "----"
else
    echo kill $PID
    kill $PID
fi
echo "原java进程已关闭"
 nohup java -XX:+HeapDumpOnOutOfMemoryError -jar /usr/$SERVER_NAME.jar --spring.profiles.active=prod >  $BASE_PATH/start.log
echo "$SERVER_NAME程序部署完成"
# 启动docker jdk镜像运行jar包
#关闭jdk8容器
# docker stop $SERVER_NAME
#删除jdk8容器
# docker rm $SERVER_NAME
# 使用jdk8容器运行目标jar
# -d 后台运行
# -p 定义开放端口
# -v 将服务器jar包映射到docker容器空间中 冒号前为服务器jar包路径，后为定义的容器空间路径
# --name 定义容器名称
# java:8  使用的jdk镜像，后接 java -jar即使用此镜像部署执行jar包(路径应为先前定义的docker容器空间的jar包路径)
# docker run -d -p 8090:8090 -v $BASE_PATH/$SERVER_NAME.jar:/usr/$SERVER_NAME.jar --name $SERVER_NAME java:8 java -jar /usr/$SERVER_NAME.jar
# echo "$SERVER_NAME容器创建完成"