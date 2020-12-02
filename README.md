# full-server-ftp-backup
Simple bash script for automatize full server backup, compressed it into .tar.gz and send to remote ftp.

Requirements are curlftpfs, rsync and gawk:
```bash
$ sudo apt update
$ sudo apt install -y curlftpfs
$ sudo apt install -y rsync
$ sudo apt install -y gawk
```
Edit CONFIGURATIONS and copy full_server_backup.sh inside /usr/bin and ```chmod +x``` it.  
Add it to ```sudo crontab -e``` like this ```30 4 * * * /usr/bin/full_server_backup.sh``` and you are done.

Tested on Debian 10 (buster).
