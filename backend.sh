#!/bin/bash

source ./common.sh

check_root

echo "Please enter root password for MySQL::"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
dnf module enable nodejs:20 -y &>>$LOGFILE
dnf list installed nodejs &>>$LOGFILE
if [ $? -ne 0 ]
then
    dnf install nodejs -y &>>$LOGFILE
else
    echo -e "nodejs is already installed....$Y SKIPPING $N"
fi

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
else
    echo -e "expense user is already present....$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE

cd /app 
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE

npm install &>>$LOGFILE

cp /home/ec2-user/proj-expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE

systemctl daemon-reload &>>$LOGFILE

systemctl start backend &>>$LOGFILE

systemctl enable backend &>>$LOGFILE

dnf list installed mysql &>>$LOGFILE
if [ $? -ne 0 ]
then
    dnf install mysql -y &>>$LOGFILE
else
    echo -e "mysql is already installed....$Y SKIPPING $N"
fi

mysql -h db.surya-devops.site -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE

systemctl restart backend &>>$LOGFILE
