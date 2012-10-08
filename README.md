Webfaction Backup Script
============

Ruby script to backup known cms hosted on webfaction.com
Supported CMS are:
* Wordpress
* Joomla!
(not sure if it will recognize too old versions)

## How to use:

```sh
cd $HOME
git clone https://github.com/ape-box/webf-backups.git
cd webf-backups
sh ./update_directories.sh
````

If you have installed tarsnap set "tarsnap: true" in config.yaml


## How to schedule:

```sh
# to see scheduled jobs
crontab -l

# to edit scheduled jobs
crontab -e
````


### Edit crontab:
If you want to backup one a month, add:
```sh
* 3 1 * * ruby $HOME/webf-backups/backup.rb >/dev/null 2>&1
````

If you want to backup one a week, add:
```sh
* 3 */7 * * ruby $HOME/webf-backups/backup.rb >/dev/null 2>&1
````

