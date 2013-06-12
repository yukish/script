#!/bin/sh
# System backup script like the Time Machine.

today=`date +%F`
backup_dir=""
mkdir $backup_dir/system_$today
backup_location="$backup_dir/system_$today"

START=`date +%s`

#rsync -aAXv --link-dest="$backup_dir/`/bin/ls -1t $backup_dir | grep system | head -2 | tail -1`" /* $backup_location \
#        --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,/home/*/.gvfs}
rsync -n -aAXv --link-dest="$backup_dir/`/bin/ls -1t $backup_dir | grep system | head -2 | tail -1`" /* $backup_location \
        --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,/home/*/.gvfs}

FINISH=`date +%s`
echo "total time: $(( (${FINISH}-${START}) / 60 )) minutes, $(( (${FINISH}-${START}) % 60 )) seconds"
