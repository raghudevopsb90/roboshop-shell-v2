source $(dirname $(realpath $0))/common.sh
component_name=valkey
echo Log file Output : ${log_file}

print_head "Install Valkey"
dnf install -y valkey &>>${log_file}
status_check

print_head "Update Valkey config"
sed -i -e 's/^bind 127.0.0.1.*/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/valkey/valkey.conf &>>${log_file}
status_check

print_head "Start Valkey service"
systemctl enable valkey &>>${log_file}
status_check

systemctl restart valkey &>>${log_file}
status_check
