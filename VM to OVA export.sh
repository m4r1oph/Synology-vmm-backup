#!/bin/bash

# Define variables for paths and VM name
VM_NAME="CPHM"
SHARED_FOLDER="Backup"
LOGS_FOLDER="/volume2/$SHARED_FOLDER/logs"

# Shutdown the virtual machine
synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=shutdown runner=admin guest_name="$VM_NAME"
sleep 15s

# Backup the virtual machine
/var/packages/Virtualization/target/bin/vmm_backup_ova --dst=$SHARED_FOLDER --batch=1 --guests="$VM_NAME"

# Count the number of backup files
num_backups=$(find /volume2/Backup/CPHM -maxdepth 1 -type f ! -name '.*' | wc -l)

# If there are more than 3 backup files, delete the oldest ones
if [[ $num_backups -gt 3 ]]; then
    mkdir -p $LOGS_FOLDER
    find /volume2/Backup/CPHM -maxdepth 1 -type f -printf '%T+ %p\n' | sort > $LOGS_FOLDER/fich.txt

    num_lin=$(wc -l < $LOGS_FOLDER/fich.txt)
    num_old=$(($num_lin - 3))

    if [[ $num_old -gt 0 ]]; then
        num_delete=$(($num_old + 1))
        head -n $num_old $LOGS_FOLDER/fich.txt | cut -d " " -f 2 > $LOGS_FOLDER/del_old.txt

        num_lin=$(wc -l < $LOGS_FOLDER/del_old.txt)

        for i in $(seq 1 $num_lin); do
            delete=$(sed -n ${i}p $LOGS_FOLDER/del_old.txt)
            rm $delete
        done
    fi

    rm -r $LOGS_FOLDER
fi

# Power on the virtual machine
synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=poweron runner=admin # guest_name="$VM_NAME"
