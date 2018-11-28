#!/bin/bash

######################################
##   CREATE A NEW SNAPSHOT BACKUP   ##
######################################
## This script takes in three arguments the name of your instance, the region, and the number of snapshots to keep.

NameOfYourInstance=$1
NameOfYourBackup="autosnap-${NameOfYourInstance}-$(date +%Y-%m-%d_%H.%M)"
Region=$2

aws lightsail create-instance-snapshot --instance-snapshot-name ${NameOfYourBackup} --instance-name $NameOfYourInstance --region $Region

## Delay before initiating clean up of old snapshots
sleep 30

###############################################
##   DELETE OLD SNAPSHOTS + RETAIN SNAPSHOTS ##
###############################################
# Set number of snapshots you'd like to keep in your account
snapshotsToKeep=$3
echo "Number of Instance Snapshots to keep: ${snapshotsToKeep}"

SnapshotNames=$(aws lightsail get-instance-snapshots | jq '.instanceSnapshots | map(select(.name|startswith("'autosnap-${instance_name}'"))) | .[].name')
numberOfSnapshots=$(echo "$SnapshotNames" | wc -l)

# loop through all snapshots
while IFS= read -r line 
do 
let "i++"

	# delete old snapshots condition
	if (($i <= $numberOfSnapshots-$snapshotsToKeep))
	then
		snapshotToDelete=$(echo "$line" | tr -d '"')

		# delete snapshot command
		aws lightsail delete-instance-snapshot --instance-snapshot-name $snapshotToDelete 
	fi

done <<< "$SnapshotNames"

exit 1
