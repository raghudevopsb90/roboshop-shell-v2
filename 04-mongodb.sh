source $(dirname $(realpath $0))/common.sh
component_name=mongodb
echo Log file Output : ${log_file}

print_head "Copy MongoDB repo file"
cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check

print_head "Install MongoDB"
dnf install -y mongodb-org &>>${log_file}
status_check

print_head "Update MongoDB config"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${log_file}
status_check

print_head "Start MongoDB service"
systemctl enable mongod &>>${log_file}
status_check

systemctl restart mongod &>>${log_file}
status_check
