#!/bin/bash
###################################################################
#Script Name	:full_server_backup.sh
#Requirements	:curlftpfs & rsync
#Description	:Make full disk backup and transfert to ftp server
#Author      	:Ugo Ridolfi
#Email       	:u.ridolfi@gmail.com
###################################################################
PATH=/bin:/usr/bin:/sbin:/usr/sbin
###########_CONFIGURATIONS_###########
FILENAME=full_disk-`date +%Y%m%d%H%M`
FTP_ADDRESS=ftp.yourserver.com
FTP_USERNAME='xxxxxxxxxx'
FTP_PASSWORD='xxxxxxxxxx'
FTP_STORAGE_SPACE_GB=xx
DESTINATION_DIR=/path/to/mount/ftp/directory
######################################

mkdir $DESTINATION_DIR && mkdir /var/tmp/rsync && mkdir /var/tmp/rsync/tmp
sleep 1
curlftpfs $FTP_USERNAME:$FTP_PASSWORD@$FTP_ADDRESS $DESTINATION_DIR
sleep 3
rsync -qaHAXS  --temp-dir=/var/tmp/rsync/tmp --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found",$DESTINATION_DIR,"/var/tmp/rsync"} / /var/tmp/rsync 2> /var/tmp/rsync/error_backup-$FILENAME.log
if [ $? != "0" ]
  then
   #_save_error_log
   cp /var/tmp/rsync/error_backup-$FILENAME.log $DESTINATION_DIR/
   sleep 1
   rm -r /var/tmp/rsync
   sleep 1
   umount $DESTINATION_DIR && sleep 3 && rm -r $DESTINATION_DIR
   echo "There was a problem with backup process!"
  else
   #_compress_disk_backup
   tar -cvpf /root/$FILENAME.tar.gz /var/tmp/rsync
   sleep 3
   rm -r /var/tmp/rsync
   sleep 1
   #_check_ftp_starage_free_space
   filesize=$(find /root -type f -name $FILENAME.tar.gz -printf "%s\n" | gawk -M '{t+=$1}END{print t}'| numfmt --to=si)
   echo 'Backup file size: ' $filesize
   ftp_files_size=$(find $DESTINATION_DIR -type f -name "*.tar.gz" -printf "%s\n" | gawk -M '{t+=$1}END{print t}'| numfmt --to=si)
   ftp_files_size=${ftp_files_size::-1}
   file_size=${filesize::-1}
   echo 'FTP files size: '$ftp_files_size'GB'
   if [ ${filesize: -1} == 'M' ]
    then
     file_size=$((file_size*1/1000))
   fi
   echo 'TOTAL_SIZE(FTP+BKP_FILE):'$((${ftp_files_size%.*}+${file_size%.*}))'GB'
   if [ $((${ftp_files_size%.*}+${file_size%.*})) '>' $FTP_STORAGE_SPACE_GB ]
    then
     #_delete_oldest_ftp_backup
     echo "Ftp storage is full. Delete oldest backup.."
     rm $DESTINATION_DIR/$(ls -t "$DESTINATION_DIR" | tail -1)
     sleep 1
   fi
   echo "Ftp has enough free space, send backup file..."
   #_save_backup_to_ftp
   cp /root/$FILENAME.tar.gz $DESTINATION_DIR/$FILENAME.tar.gz
   sleep 1
   rm /root/$FILENAME.tar.gz
   sleep 1
   umount $DESTINATION_DIR && sleep 3 && rm -r $DESTINATION_DIR
   echo "Backup finished, all done!"
fi
