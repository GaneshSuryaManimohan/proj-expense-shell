#!/bin/bash

source ./common.sh

check_root

echo "Please enter root password for MySQL::"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabling mysqld"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "starting mysqld"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

#On first run, the root password will be setup but, when we run the script again there will be failure because the root password is already setup.
#by default shell script is not idempotent, we can make it idempotent

mysql -h db.surya-devops.site -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "Setting up password for root"
else
    echo -e "Root password is already set....$Y SKIPPING $N"
fi