#!/bin/bash

date=$(date "+%Y_%m_%d")
#backaup dir ($HOME) сохраняем директорию
backupdir="/home/ali"
#backup saved dir тут сохроняем бэкап 
backupsave="/home/backup"
#backup path fo variable
backuppath="$backupsave"/backup.-"$date.tar.gz"

#добавить проверку на директорию переменые с директориями


if tar -zcpf $backuppath $backupdir 
then
  echo Data from $backupdir was backed up succesfully
  exit 0
else
  echo "En error occured during the backup"
  exit 1
fi
