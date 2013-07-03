#!/bin/bash
# System backup script like the Time Machine.

today=`date +%F`
backup_dir=""
backup_location="$backup_dir/system_$today"
# The second from last update directory: ${link_destination[1]}
link_destination=(`/bin/ls -1t $backup_dir | grep 'system_[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}'`)

if [ ! -d "$backup_location" ]; then
	mkdir $backup_location
fi

START=`date +%s`

#rsync -aAXv --link-dest="${link_destination[1]}" /* $backup_location \
#        --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,/home/*/.gvfs}
rsync -n -aAXv --link-dest="${link_destination[1]}" /* $backup_location \
        --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,/home/*/.gvfs}

FINISH=`date +%s`
echo "total time: $(( (${FINISH}-${START}) / 60 )) minutes, $(( (${FINISH}-${START}) % 60 )) seconds"
