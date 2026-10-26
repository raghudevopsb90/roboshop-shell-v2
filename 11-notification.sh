source $(dirname $(realpath $0))/common.sh
component_name=notification
echo Log file Output : ${log_file}
extra_pip_packages=gunicorn

python_app
