#!/bin/bash

# Original proposal available on https://github.com/m4r1oph/Synology-vmm-backup/
# Define variables for paths and VM name
# Use pipe caracter for multi VM
VM_NAME="VM-Test|VM-Test-1"
VOLUME="/volume1"
SHARED_FOLDER="Backup"
NUMBER_BACKUPS=3



# Shutdown the virtual machine
VM=$(echo $VM_NAME | tr "|" "\n")
for vm in $VM
do
    synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=shutdown runner=admin guest_name="$vm"
    sleep 15s
done


# Backup the virtual machine
/var/packages/Virtualization/target/bin/vmm_backup_ova --dst=$SHARED_FOLDER --batch=1 --guests="$VM_NAME" --retent=$NUMBER_BACKUPS


# Power on the virtual machine
for vm in $VM
do
    synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=poweron runner=admin guest_name="$vm"
done
