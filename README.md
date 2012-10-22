Webfaction Backup Script
============

Ruby script to backup known cms hosted on webfaction.com
Supported CMS are:
* Wordpress
* Joomla!

not sure if it will recognize too old versions

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
If you want to backup once a month, add:
```sh
# run on 3:00 every first day or the month
* 3 1 * * /usr/local/bin/ruby /home/[username]/webf-backups/backup.rb 2>> $HOME/cron.log

# alternatively
@monthly /usr/local/bin/ruby /home/[username]/webf-backups/backup.rb 2>> $HOME/cron.log
````

If you want to backup once a week, add:
```sh
# run on 3:00 every first day or the month
* 3 * * fri /usr/local/bin/ruby /home/[username]/webf-backups/backup.rb $HOME/cron.log

# alternatively
@weekly /usr/local/bin/ruby /home/[username]/webf-backups/backup.rb 2>> $HOME/cron.log
````

For more on cron see : http://en.wikipedia.org/wiki/Crontab

