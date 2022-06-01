#!/bin/bash

synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=shutdown runner=admin guest_name="NAME_OF_VM"
sleep 15m

/var/packages/Virtualization/target/bin/vmm_backup_ova --dst=Backup --batch=1 --guests="NAME_OF_VM"
num_backups=$(find /ROUTE/TO/THE/DESTINATION/FOLDER/ -maxdepth 1 -type f | wc -l)
if [[ $num_backups -gt 3 ]]
    then
        mkdir /ROUTE/TO/THE/DESTINATION/FOLDER/logs
        backup_old=$(find /ROUTE/TO/THE/DESTINATION/FOLDER/ -maxdepth 1 -type f -printf '%T+ %p\n' | sort > /ROUTE/TO/THE/DESTINATION/FOLDER/logs/fich.txt)
        num_lin=$(cat /ROUTE/TO/THE/DESTINATION/FOLDER/logs/fich.txt | wc -l )
        num_old=$(($num_lin-3))
        if [[ $num_old -gt 0 ]]
            then
                num_delete=$(($num_old+1))
                cat /ROUTE/TO/THE/DESTINATION/FOLDER/logs/fich.txt | head -n $num_old | cut -d " " -f 2 > /ROUTE/TO/THE/DESTINATION/FOLDER/logs/del_old.txt
                num_lin=$(cat /ROUTE/TO/THE/DESTINATION/FOLDER/logs/del_old.txt | wc -l )
                for i in $(seq 1 $num_lin)
                    do
                        delete=$(cat /ROUTE/TO/THE/DESTINATION/FOLDER/logs/del_old.txt | sed -n $i'p')
                        rm $delete
                    done
            else
                backup_old=$(find /ROUTE/TO/THE/DESTINATION/FOLDER/ -maxdepth 1 -type f -printf '%T+ %p\n' | sort | head -n 1 | cut -d " " -f 2)
                rm $backup_old
            fi
            rm -r /ROUTE/TO/THE/DESTINATION/FOLDER/logs
fi

hyper_backup=$(find /ROUTE/TO/THE/DESTINATION/FOLDER/ -maxdepth 1 -type f -printf '%T+ %p\n' | sort | tail -n 1 | cut -d " " -f 2)
cp $hyper_backup /volume1/Backup/Windows2016/Hyper_Backup/WS2016.ova

synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=poweron runner=admin guest_name="NAME_OF_VM"
