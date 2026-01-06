#!/bin/bash

source ./common.sh

check_root

dnf list installed nginx &>>$LOGFILE
if [ $? -ne 0 ]
then
    dnf install nginx -y &>>$LOGFILE
    VALIDATE $? "Installing NginX"
else
    echo -e "NginX is already installed....$Y SKIPPING $N"
fi

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling NginX"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting NginX"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing default html file"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading Frontend Code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting Frontend Code"

cp /home/ec2-user/proj-expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copying expense.conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting NginX"