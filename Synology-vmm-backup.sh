#!/bin/bash

synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=shutdown runner=admin guest_name="Windows2016"
sleep 15m

/var/packages/Virtualization/target/bin/vmm_backup_ova --dst=Backup --batch=1 --guests="Windows2016"
num_backups=$(find /volume1/Backup/Windows2016 -maxdepth 1 -type f | wc -l)
if [[ $num_backups -gt 3 ]]
    then
        mkdir /volume1/Backup/Windows2016/logs
        backup_old=$(find /volume1/Backup/Windows2016 -maxdepth 1 -type f -printf '%T+ %p\n' | sort > /volume1/Backup/Windows2016/logs/fich.txt)
        num_lin=$(cat /volume1/Backup/Windows2016/logs/fich.txt | wc -l )
        num_old=$(($num_lin-3))
        if [[ $num_old -gt 0 ]]
            then
                num_delete=$(($num_old+1))
                cat /volume1/Backup/Windows2016/logs/fich.txt | head -n $num_old | cut -d " " -f 2 > /volume1/Backup/Windows2016/logs/del_old.txt
                num_lin=$(cat /volume1/Backup/Windows2016/logs/del_old.txt | wc -l )
                for i in $(seq 1 $num_lin)
                    do
                        delete=$(cat /volume1/Backup/Windows2016/logs/del_old.txt | sed -n $i'p')
                        rm $delete
                    done
            else
                backup_old=$(find /volume1/Backup/Windows2016 -maxdepth 1 -type f -printf '%T+ %p\n' | sort | head -n 1 | cut -d " " -f 2)
                rm $backup_old
            fi
            rm -r /volume1/Backup/Windows2016/logs
fi

hyper_backup=$(find /volume1/Backup/Windows2016 -maxdepth 1 -type f -printf '%T+ %p\n' | sort | tail -n 1 | cut -d " " -f 2)
cp $hyper_backup /volume1/Backup/Windows2016/Hyper_Backup/WS2016.ova

synowebapi --exec api=SYNO.Virtualization.API.Guest.Action version=1 method=poweron runner=admin guest_name="Windows2016"