#!/bin/sh

if [ ! -d "$PWD/backups" ]; then
	mkdir $PWD/backups
fi
echo "webapps_directory: \""$HOME"/webapps\"" > config.yaml
echo "backup_directory: \""$PWD"/backups\"" >> config.yaml
echo "tmp_directory: \""$PWD"/tmp\"" >> config.yaml
echo "log_to_file: true" >> config.yaml
echo "log_file: \""$PWD"/backup_log.txt\"" >> config.yaml
echo "log_to_stdout: false" >> config.yaml
echo "tarsnap: true" >> config.yaml
echo "tarsnap_bin: \""$HOME"/bin/tarsnap" >> config.yaml
echo "targz: false" >> config.yaml
echo "clamdscan: \"$HOME/clamav/bin/clamdscan\"" >> config.yaml
echo "clamd_restart: \"$HOME/bin/clamd-restart\"" >> config.yaml
