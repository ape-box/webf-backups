#!/bin/sh

if [ ! -d "$PWD/backups" ]; then
	mkdir $PWD/backups
fi
echo "webapps_directory: \""$HOME"/webapps\"" > config.yaml
echo "backup_directory: \""$PWD"\"/backups" >> config.yaml
echo "log_to_file: true" >> config.yaml
echo "log_file: \""$PWD"/backup_log.txt\"" >> config.yaml
echo "log_to_stdout: false" >> config.yaml
echo "tarsnap: true" >> config.yaml
echo "targz: false" >> config.yaml
