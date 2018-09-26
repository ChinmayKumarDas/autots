#!/bin/bash
echo "We will go to mount the newly added disk"
echo "Please find the output of lsblk"
lsblk
sudo mkdir /rescue -p
sudo mkdir /tmp/mnt
echo "Please provide the disk you would like to mount as a part of rescue e.e. sda sdb sdc etc."
read filesystem
#echo -e "Please find the partitions on $filesystem \n `lsblk /dev/$filesystem | egrep "\└" | cut -d'└' -f 2 | cut -d"" -f2 | cut -d" " -f1`"
#a=`lsblk /dev/$filesystem | egrep "\└" | cut -d'└' -f 2 | cut -d"" -f2 | cut -d" " -f1|wc -l`
#for partitions in `ls -ltr /dev/sdc* | sed 1d | awk -F" " '{print $10}'`; do blkid $partitions; done | cut -d: -f1 >/tmp/partitions
sudo ls -ltr /dev/sdc* | sed 1d | awk -F" " '{print $10}' >/tmp/partitions
echo -e "Please find the partitions present in $filesystem \n `ls -ltr /dev/sdc* | sed 1d | awk -F" " '{print $10}'`"
root_fs() {

for i in `cat /tmp/partitions`
do
fssystem=$(sudo blkid $i | awk -F"\"" '{ print $4 }')
if [ "$fssystem" == "xfs" ]
then
  sudo mount -o nouuid $i /tmp/mnt
   if  [ -d /tmp/mnt/etc ]
        then echo "$i is root file system, hence mounting it on /rescue"
          sudo   umount -fl /tmp/mnt
          sudo   mount -o nouuid $i /rescue
        else
          echo "$i is not root file system"
          sudo   umount -fl /tmp/mnt
   fi

else
  sudo mount  $i /tmp/mnt
   if  [ -d /tmp/mnt/etc ]
        then echo "$i is root file system, hence mounting it on /rescue"
          sudo   umount -fl /tmp/mnt
          sudo   mount  $i /rescue
        else
          echo "$i is not root file system"
          sudo   umount -fl /tmp/mnt
   fi

fi
 done
         }

boot_fs() {
  echo "Please specify the boot directory i.e grub or grub2"
  read boot
for i in `cat /tmp/partitions`
 do
fssystem=$(sudo blkid $i | awk -F"\"" '{ print $4 }')
if [ "$fssystem" == "xfs" ]
then
  sudo mount -o nouuid $i /tmp/mnt
   if  [ -d /tmp/mnt/$boot ]
        then echo "$i is boot file system, hence mounting it on /rescue/boot"
          mkdir /rescue/boot
          sudo umount -fl /tmp/mnt
          sudo mount -o nouuid $i /rescue/boot
   else
       echo "$i is not boot file system"
       sudo umount -fl /tmp/mnt
   fi

else
  sudo mount  $i /tmp/mnt
   if  [ -d /tmp/mnt/$boot ]
        then echo "$i is boot file system, hence mounting it on /rescue/boot"
          mkdir /rescue/boot
          sudo umount -fl /tmp/mnt
          sudo mount  $i /rescue/boot
   else
       echo "$i is not boot file system"
       sudo umount -fl /tmp/mnt
   fi
fi

 done
           }



fstab_correction() {
if [ -f /rescue/etc/fstab ]
  then
    echo "Performing the minimum mounts i.e. /root and /boot to bring up the VM"
        sudo cp /rescue/etc/fstab /rescue/etc/fstab.$(date +%F-%T)
        sudo sed -i 's/^/#/g' /rescue/etc/fstab
        sudo chmod 777 /rescue/etc/fstab
#        grep sdc* /etc/mtab >>/rescue/etc/fstab
        sudo grep sdc[[:digit:]] /etc/mtab  >>/rescue/etc/fstab

for i in `cat /tmp/partitions`; do sudo sed -i "s|${i}|$(sudo blkid $i | cut -d: -f2 | cut  -d" " -f2)|" /rescue/etc/fstab; done
sudo sed -i -e "s|/rescue| /|"  -e "s|//| /|" /rescue/etc/fstab
  else
     echo "fstab is not present !!!!! Please do manual recovery"
fi
       }



#     for id_blkid in `cat /tmp/partitions`
#       do blkid $id_blkid | cut -d: -f2 | cut -d" " -f2 >>/tmp/uuid
#     done
#     for UID in `cat /tmp/uuid`
#      do
#        for part in `cat /tmp/partitions`
#         do
#           sed -i "s|${part}|${UID}|" /rescue/etc/fstab
#         done
#      done



#    for i in `cat /tmp/partitions`; do grep $i  /proc/mounts >> /rescue/etc/fstab; done



unmount() {
sudo umount -fl /rescue/boot
sudo umount -fl /rescue
}







echo -e "Please provide which troubleshooting you want to perform \n1. fstab \n2. grub \n3. fserror "
read ts

case $ts in
1)
root_fs
boot_fs
fstab_correction
unmount
echo -e "**************************\n*********************************************\n**************************************\n"

echo "fstab issue is fixes and it will exit from the rescue VM"
;;
*)
echo "Sorry, other options are still under developement"
exit
;;
esac



#a=`ls -ltr /dev/sdc* | sed 1d | awk -F" " '{print $10}' | wc -l`
#counter=1
#while [  $counter -le $a ]; do
#             echo "Please provide the name of the filesystem to be mounted on /rescue e.g /dev/sdc1 /dev/sdc2 etc."
#             read disk
#     for i in $parttition_list
#          do
#             mount $i /tmp/mnt
#             if  [ -d /tmp/mnt/etc ]
#               then echo "$disk is root file system, hence mounting it on /rescue"
#                    umount -fl /tmp/mnt
#                    mount $disk /rescue
#                 else
#              fi
#             echo "Please provide us the dircetory name where you want to mount $disk e.g /rescue, /rescue/boot etc."
 #            read dir
 #            mkdir -p $dir
 #            mount $disk /tmp/mount
#
 #            mount $disk $dir
 #           counter=`expr $counter + 1`
 #        done


