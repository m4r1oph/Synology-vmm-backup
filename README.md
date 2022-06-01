# Synology-vmm-backup
Script for automate the export of VM's in Synology
\
HOW TO TO RUN:\
\
You have to create a scheduled task in control panel, select the option user defined script, give him root permisions and put --> bash /route/to/your/script\
\
TASKS PERFORMED IN ORDER:\
\
1.-Shutdowns the VM\
2.-Start the backup\
3.-Check the number of existing backups, if it exceeds 3, delete the oldest ones and keep the last 3.\
4.-Copies the last one to another folder, thats useful if you want to create a Hyper Backup task to export this other storage device.\
5.-Starts the VM again.\
\
\
NOTES:\
\
There's no need to shutdown the VM before the export, but in my case I want to keep consistency on the Backups avoiding potential errors.\
You can edit the number of copies that you want to keep.

