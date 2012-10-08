#!/bin/sh

if [ ! -d "$PWD/backups" ]; then
	mkdir $PWD/backups
fi
echo "webapps_directory: \""$PWD"/webapps\"" > config.yaml
echo "backup_directory: \""$PWD"\"/backups" >> config.yaml
echo "log_to_file: true" >> config.yaml
echo "log_file: \""$PWD"/backup_log.txt\"" >> config.yaml
echo "log_to_stdout: false" >> config.yaml
echo "tarsnap: false" >> config.yaml
echo "targz: true" >> config.yaml
