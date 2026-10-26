source $(dirname $(realpath $0))/common.sh
component_name=shipping
echo Log file Output : ${log_file}
schema_type=mysql
schema_files="schema.sql app-user.sql"

java_app
