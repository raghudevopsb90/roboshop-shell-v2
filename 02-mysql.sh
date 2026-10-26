source $(dirname $(realpath $0))/common.sh
component_name=mysql
echo Log file Output : ${log_file}

print_head "Install MySQL Server"
dnf install -y mysql8.4-server &>>${log_file}
status_check

print_head "Start MySQL Server"
systemctl enable mysqld &>>${log_file}
status_check

systemctl restart mysqld &>>${log_file}
status_check

print_head "Setup MySQL Root Password"
mysql -u root -p${mysql_root_password} -e "SELECT 1;" &>>${log_file}
if [ $? -ne 0 ]; then
  mysql -u root -e "
    CREATE USER 'root'@'%' IDENTIFIED BY '${mysql_root_password}';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT Option;
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password}';
    FLUSH PRIVILEGES;
  " &>>${log_file}
fi
status_check
