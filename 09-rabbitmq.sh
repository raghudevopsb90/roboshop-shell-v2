source $(dirname $(realpath $0))/common.sh
component_name=rabbitmq
echo Log file Output : ${log_file}

print_head "Copy RabbitMQ repo file"
cp ${script_path}/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>${log_file}
status_check

print_head "Install Erlang & RabbitMQ"
dnf install -y erlang rabbitmq-server &>>${log_file}
status_check

print_head "Start RabbitMQ service"
systemctl enable rabbitmq-server &>>${log_file}
status_check

systemctl restart rabbitmq-server &>>${log_file}
status_check

print_head "Enable Management Plugin"
rabbitmq-plugins enable rabbitmq_management &>>${log_file}
status_check

systemctl restart rabbitmq-server &>>${log_file}
status_check

print_head "Create Application User"
rabbitmqctl list_users | grep -w roboshop &>>${log_file}
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop RoboShop@1 &>>${log_file}
fi
rabbitmqctl set_user_tags roboshop administrator &>>${log_file}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${log_file}
status_check
