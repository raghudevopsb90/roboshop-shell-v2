log_file=/tmp/roboshop.log
hs="\e[33m >>>>>>>>>>>>>"
he="<<<<<<<<<<<<<<< \e[0m"
script_path=$(dirname $(realpath $0))
artifacts_url=https://raw.githubusercontent.com/raghudevopsb90/roboshop-microservices/main/artifacts
mysql_host=mysql.rdevopsb90.online
mysql_root_password=RoboShop@1

if [ $(id -u) -ne 0 ]; then
  echo -e "\e[31m Run this script as root, Example: sudo bash $0 \e[0m"
  exit 1
fi

print_head() {
  echo -e "${hs} $1 ${he}"
  echo -e "${hs} $1 ${he}" &>>${log_file}
}

status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
    echo "Refer the log file for more information : ${log_file}"
    exit 1
  fi
}

app_pre_reqs() {
  print_head "Create Application User"
  id appuser &>>${log_file}
  if [ $? -ne 0 ]; then
    useradd -r -d /app -s /bin/false appuser &>>${log_file}
  fi
  status_check

  print_head "Copy SystemD Service file"
  cp ${script_path}/${component_name}.service /etc/systemd/system/${component_name}.service &>>${log_file}
  status_check

  print_head "Download Application Content"
  curl -sfL -o /tmp/${component_name}.zip ${artifacts_url}/${component_name}.zip &>>${log_file}
  status_check

  print_head "Create folder for application"
  rm -rf /app &>>${log_file}
  status_check

  mkdir -p /app &>>${log_file}
  status_check

  cd /app

  print_head "Extract application content"
  unzip /tmp/${component_name}.zip &>>${log_file}
  status_check
}

schema_load() {
  if [ "${schema_type}" == "mysql" ]; then
    print_head "Install MySQL Client"
    dnf install -y mysql8.4 &>>${log_file}
    status_check

    print_head "Load Schema, App User & Master Data"
    for file in ${schema_files}; do
      mysql -h ${mysql_host} -u root -p${mysql_root_password} < /app/db/${file} &>>${log_file}
      if [ $? -ne 0 ]; then
        false
        break
      fi
    done
    status_check
  fi
}

systemd_service() {
  schema_load

  print_head "Apply permission for application folder"
  chown -R appuser:appuser /app &>>${log_file}
  status_check

  chmod o-rwx /app -R &>>${log_file}
  status_check

  print_head "Start ${component_name} Service"
  systemctl daemon-reload &>>${log_file}
  status_check

  systemctl enable ${component_name} &>>${log_file}
  status_check

  systemctl restart ${component_name} &>>${log_file}
  status_check
}

nodejs_install() {
  print_head "Install NodeJS"
  curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - &>>${log_file}
  status_check

  dnf install -y nodejs &>>${log_file}
  status_check
}

nodejs_app() {
  nodejs_install
  app_pre_reqs

  print_head "Download App Dependencies"
  npm install --production &>>${log_file}
  status_check

  systemd_service
}

golang_app() {
  print_head "Install GoLang"
  dnf install -y golang git &>>${log_file}
  status_check

  app_pre_reqs

  print_head "Compile Application Code"
  go mod tidy &>>${log_file}
  status_check

  CGO_ENABLED=0 go build -o /app/${component_name} . &>>${log_file}
  status_check

  systemd_service
}

java_app() {
  print_head "Install Java & Maven"
  dnf install -y java-21-openjdk java-21-openjdk-devel maven &>>${log_file}
  status_check

  app_pre_reqs

  print_head "Build Application Code"
  mvn clean package -DskipTests &>>${log_file}
  status_check

  cp target/${component_name}.jar /app/${component_name}.jar &>>${log_file}
  status_check

  systemd_service
}

python_app() {
  print_head "Install Python & Pip"
  dnf install -y python3 python3-pip &>>${log_file}
  status_check

  app_pre_reqs

  print_head "Install App Dependencies"
  pip3 install -r requirements.txt ${extra_pip_packages} &>>${log_file}
  status_check

  systemd_service
}
