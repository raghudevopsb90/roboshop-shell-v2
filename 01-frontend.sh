source $(dirname $(realpath $0))/common.sh
component_name=frontend
echo Log file Output : ${log_file}

print_head "Install Nginx"
dnf install -y nginx &>>${log_file}
status_check

nodejs_install

print_head "Download ${component_name} Code"
curl -sfL -o /tmp/${component_name}.zip ${artifacts_url}/${component_name}.zip &>>${log_file}
status_check

print_head "Create App Directory"
rm -rf /tmp/${component_name} &>>${log_file}
status_check

mkdir -p /tmp/${component_name} &>>${log_file}
status_check

cd /tmp/${component_name}

print_head "Extract App Code"
unzip /tmp/${component_name}.zip &>>${log_file}
status_check

print_head "Install App Dependencies & Build Html Code"
npm install &>>${log_file}
status_check

npm run build &>>${log_file}
status_check

print_head "Copy Built Code to Nginx"
rm -rf /usr/share/nginx/html/* &>>${log_file}
status_check

cp -r out/* /usr/share/nginx/html/ &>>${log_file}
status_check

print_head "Copy Nginx Config"
cp ${script_path}/nginx.conf /etc/nginx/nginx.conf &>>${log_file}
status_check

nginx -t &>>${log_file}
status_check

print_head "Start Nginx Service"
systemctl enable nginx &>>${log_file}
status_check

systemctl restart nginx &>>${log_file}
status_check
