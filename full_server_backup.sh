#!/bin/bash
###################################################################
#Script Name	:full_backup.sh
#Requirements	:curlftpfs & rsync
#Description	:Make full disk backup and transfert to ftp server
#Author       :Ugo Ridolfi
#Email        :u.ridolfi@gmail.com
###################################################################
PATH=/bin:/usr/bin:/sbin:/usr/sbin
FILENAME=full_disk-`date +%Y%m%d%H%M`
FTP_ADDRESS=ftp.yourserver.com
FTP_USERNAME='xxxxxxxxxx'
FTP_PASSWORD='xxxxxxxxxx'
DESTINATION_DIR=/path/to/mount/dir

mkdir $DESTINATION_DIR && mkdir /var/tmp/rsync && mkdir /var/tmp/rsync/tmp
sleep 1
curlftpfs $FTP_USERNAME:$FTP_PASSWORD@$FTP_ADDRESS $DESTINATION_DIR
sleep 3
rsync -qaHAXS  --temp-dir=/var/tmp/rsync/tmp --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found",$DESTINATION_DIR,"/var/tmp/rsync"} / /var/tmp/rsync 2> /var/tmp/rsync/error_backup-$FILENAME.log
if [ $? != "0" ]
  then
   cp /var/tmp/rsync/error_backup-$FILENAME.log $DESTINATION_DIR/
   echo "There was a problem with backup process!"
  else
   tar -cvpf /root/$FILENAME.tar.gz /var/tmp/rsync
   sleep 3
   rm -r /var/tmp/rsync
   sleep 1
   cp /root/$FILENAME.tar.gz $DESTINATION_DIR/
   sleep 1
   rm /root/$FILENAME.tar.gz
   sleep 1
   umount $DESTINATION_DIR && rm -r $DESTINATION_DIR
   echo "Backup finished, all done!"
fi
