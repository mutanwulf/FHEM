#!/bin/bash
 
mountIp="192.168.3.10"
mountDir="backup"
mountUser="admin"
mountPass="password"
mountSubDir="fhem"
localMountPoint="/media/hitachi/share"
TelnetPort="7073"
 
#optional
backupsMax="90"
localBackupDir="/backup"
pushoverUser=""
pushoverToken=""
###################################
 
perl /opt/fhem/fhem.pl $TelnetPort "setreading FHEM.Backup info backup starting now"
 
if [ ! -e "$localBackupDir" ]
then
echo "$localBackupDir wird erstellt"
mkdir -p "$localBackupDir"
else
echo "$localBackupDir bereits vorhanden"
fi
 
tar --exclude=backup -cvzf "/$localBackupDir/$(date +%y%m%d_%H%M%S)_fhem_backup.tar.gz" "/opt/fhem" &>/dev/null
 
localIp=$(hostname -I|sed 's/\([0-9.]*\).*/\1/')
 
if [ ! -e "$localMountPoint" ]
then
echo "$localMountPoint wird erstellt"
mkdir -p "$localMountPoint"
else
echo "$localMountPoint bereits vorhanden"
fi
 
#sleep 1
 
if [ "$(ls -A $localMountPoint)" ]
 then
 if [ ! -e "$localMountPoint/$mountSubDir/$localIp" ]
 then
 mkdir -p "$localMountPoint/$mountSubDir/$localIp"
 else
 echo "$localMountPoint/$mountSubDir/$localIp existiert bereits"
 fi
 find "$localBackupDir" -name '*fhem_backup.tar.gz' | while read file
 do
  fileSize="0"
  fileSizeMB=$(du -h $file)
  fileSizeMB=${fileSizeMB%%M*}
  filename=${file##*/}
  echo "$filename ($fileSizeMB MB) wird in den Backupordner verschoben"
 if [[ "$pushoverToken" != "" && "pushoverUser" != "" ]]
 then
  curl -s -F "token=$pushoverToken" -F "user=$pushoverUser" -F "title=FHEM $localIp" -F "message=Backup mit $fileSizeMB MB wird erstellt" https://api.pushover.net/1/messages.json
 fi

 #mv "$file" "$localMountPoint/$mountSubDir/$localIp/$filename"
 cp "$file" "$localMountPoint/$mountSubDir/$localIp/$filename"
 rm "$file"
 perl /opt/fhem/fhem.pl $TelnetPort "set FHEM.Backup off"
 perl /opt/fhem/fhem.pl $TelnetPort "setreading FHEM.Backup backup $filename"
 perl /opt/fhem/fhem.pl $TelnetPort "setreading FHEM.Backup backupMB $fileSizeMB"
 perl /opt/fhem/fhem.pl $TelnetPort "setreading FHEM.Backup info backup done"
 done
 else
  echo "Mounten hat anscheinend nicht geklappt, skip."
  exit
fi
 
#Löschen alter Backups
if [[ "$backupsMax" != "" && "$backupsMax" != "0" ]]
then
 perl /opt/fhem/fhem.pl $TelnetPort "setreading FHEM.Backup backupFilesMax $backupsMax"
 backupsCurrent=`ls -A "$localMountPoint/$mountSubDir/$localIp" | grep -c "_fhem_backup.tar.gz"`
 backupsDelete=$(($backupsCurrent-$backupsMax))
 if [ "$backupsDelete" -gt "0" ]
 then
 echo "$backupsCurrent Backups vorhanden - nur $backupsMax aktuelle Backups werden vorgehalten - $backupsDelete Backups werden gelöscht"
 ls -d "/$localMountPoint/$mountSubDir/$localIp/"* | grep "_fhem_backup.tar.gz" | head -$backupsDelete | xargs rm
 else
 echo "$backupsCurrent Backups vorhanden - bis $backupsMax aktuelle Backups werden vorgehalten"
 fi
 else
 perl /opt/fhem/fhem.pl $TelnetPort "setreading FHEM.Backup backupFilesMax no limit"
fi
 
backupsCurrent=`ls -A "$localMountPoint/$mountSubDir/$localIp" | grep -c "_fhem_backup.tar.gz"`
perl /opt/fhem/fhem.pl $TelnetPort "setreading FHEM.Backup backupFiles $backupsCurrent"
 
 
#echo "Mount wieder unmounten"
#umount "$localMountPoint"
