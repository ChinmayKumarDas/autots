echo "Please provide the subscription details"
read sub
az account set --subscription $sub
az account show
echo "***************************************************************************************"
echo "***************************************************************************************"
echo "Is the subscription is correct, please type YES or NO. This is case sensitive in nature"
read option
#if [ "$option" = 'YES' ]
#       then
#               echo "Glad to hear that you would like to continue"
#       else
#               exit
#fi
case $option in
YES)
echo "Glad to know that subscription is correct and you would like to continue"
;;
*)
echo "Sorry, it is a pleasure working with you"
exit
;;
esac
echo "**************************************************************************************"
echo "**************************************************************************************"

echo "Please provide ResourceGroup name"
read ResourceGroup
echo "Please provide the faulty VM name"
read flvm
#az group create --name $ResourceGroup --location eastus
#publisher=`az vm show -g $ResourceGroup -n $vm | grep -i imagereference -A10  | grep -i publisher`
publisher=`az vm show -g $ResourceGroup -n $flvm | grep -i imagereference -A10  | grep -i publisher | cut -d: -f2  | cut -d\" -f2`
offer=`az vm show -g $ResourceGroup -n $flvm | grep -i imagereference -A10  | grep -i offer | cut -d: -f2  | cut -d\" -f2`
sku=`az vm show -g $ResourceGroup -n $flvm | grep -i imagereference -A10  | grep -i sku | cut -d: -f2  | cut -d\" -f2`
OSVERSION=$offer$sku
echo "                                     "
echo "                                     "
echo  "The version of the OS is $OSVERSION"
echo "                                     "
echo "                                     "
#echo "The value of Publisher is $publisher  Offer is $offer Sku is $sku"
#if [ "$publisher" = 'RedHat' ]
#  then
#   echo "Publisher is $publisher"
#       elif [ "$publisher" = 'OpenLogic' ]
#         then
#           echo "Publisher is $publisher"
#       elif [ "$publisher" = 'SUSE' ]
#          then
#            echo "Publisher is $publisher"
#       elif [ "$publisher" = 'Canonical' ]
#          then
#           echo "Publisher is $publisher"
#else
#echo "Publisher not found"
#fi
case $OSVERSION in
CentOS6.8)
image=OpenLogic:CentOS:6.8:6.8.20170517
echo "Please find the image will be used for build the Test Vm   $image"
;;
CentOS6.9)
image=OpenLogic:CentOS:6.9:6.9.20180530
echo "Please find the image will be used for build the Test Vm   $image"
;;
CentOS7.1)
image=OpenLogic:CentOS:7.1:7.1.20160308
echo "Please find the image will be used for build the Test Vm   $image"
;;
CentOS7.2)
image=OpenLogic:CentOS:7.2:7.2.20170517
echo "Please find the image will be used for build the Test Vm   $image"
;;
CentOS7.3)
image=OpenLogic:CentOS:7.3:7.3.20170925
echo "Please find the image will be used for build the Test Vm   $image"
;;
CentOS7.4)
image=OpenLogic:CentOS:7.4:7.4.20180704
echo "Please find the image will be used for build the Test Vm   $image"
;;
CentOS7.5)
image=OpenLogic:CentOS:7.5:7.5.20180815
echo "Please find the image will be used for build the Test Vm   $image"
;;
RHEL6.8)
image=RedHat:RHEL:6.8:6.8.2017090906
echo "Please find the image will be used for build the Test Vm   $image"
;;
RHEL6.9)
image=RedHat:RHEL:6.9:6.9.2018010506
echo "Please find the image will be used for build the Test Vm   $image"
;;
RHEL7.2)
image=RedHat:RHEL:7.2:7.2.2017090716
echo "Please find the image will be used for build the Test Vm   $image"
;;
RHEL7.3)
image=RedHat:RHEL:7.3:7.3.2017090723
echo "Please find the image will be used for build the Test Vm   $image"
;;
RHEL7.4)
image=RedHat:RHEL:7.4:7.4.2018010506
echo "Please find the image will be used for build the Test Vm   $image"
;;
SLES11-SP4)
image=SUSE:SLES:11-SP4:2018.08.17
echo "Please find the image will be used for build the Test Vm   $image"
;;
SLES12-SP2)
image=SUSE:SLES:12-SP2:2017.03.20
echo "Please find the image will be used for build the Test Vm   $image"
;;
SLES12-SP3)
image=SUSE:SLES:12-SP3:2018.08.17
echo "Please find the image will be used for build the Test Vm   $image"
;;
UbuntuServer12.04.5-LTS)
image=Canonical:UbuntuServer:12.04.5-LTS:12.04.201705020
echo "Please find the image will be used for build the Test Vm   $image"
;;
UbuntuServer14.04.5-LTS)
image=Canonical:UbuntuServer:14.04.5-LTS:14.04.201808180
echo "Please find the image will be used for build the Test Vm   $image"
;;
UbuntuServer16.04-LTS)
image=Canonical:UbuntuServer:16.04.0-LTS:16.04.201808140
echo "Please find the image will be used for build the Test Vm   $image"
;;
UbuntuServer17.1)
image=Canonical:UbuntuServer:17.10:17.10.201807060
echo "Please find the image will be used for build the Test Vm   $image"
;;
UbuntuServer18.04-LTS)
image=Canonical:UbuntuServer:18.04-LTS:18.04.201808310
echo "Please find the image will be used for build the Test Vm   $image"
;;
*)
echo "Sorry, image is not available in troubleshooting data base"
exit
;;
esac
echo "                                                           "
echo "                                                           "
echo "Initiating the shutdown of $flvm"
echo "********************************"
echo "********************************"
echo "********************************"

FVMS=`az vm stop -g $ResourceGroup  --name $flvm | grep status | cut -d: -f2  | cut -d'"' -f2`
if [ "$FVMS" = 'Succeeded' ]
  then
    echo "$flvm is down now"
  else
   echo "Please continue"
fi
echo "****************************************************"
echo "****************************************************"
echo "Creating a snapshot of managed Disk"
flosDiskId=`az vm show    -g $ResourceGroup  -n $flvm  --query "storageProfile.osDisk.managedDisk.id" -o tsv`

echo "Please check the storage account associated with disk"
storageAccountType=`az vm show -g $ResourceGroup -n $flvm --query "storageProfile.osDisk.managedDisk.storageAccountType" -o tsv`
echo $storageAccountType

echo "Please provide the name of snapshot disk"
read osDiskbackup
echo "snapshot is gretting created"
echo "****************************"
echo "****************************"
az snapshot create -g $ResourceGroup --source "$flosDiskId" --name $osDiskbackup

echo "Please provide the name of disk to be created from $osDiskbackup"
read ossnap
sdisksource=`az snapshot show -g $ResourceGroup --name $osDiskbackup --query "id" -o tsv`
echo "Disk is getting created from snapshot"
echo "****************************"
echo "****************************"
#az disk create -g $ResourceGroup -n $ossnap --source $sdisksource

az disk create -g $ResourceGroup -n $ossnap --sku $storageAccountType --source $sdisksource

diskId=$(az disk show -g $ResourceGroup -n $ossnap --query 'id' -o tsv)

echo "Please provide the name of the VM, you would like to create for troubleshooting"
read tsvm
az vm create --resource-group $ResourceGroup --name $tsvm --image $image --admin-user azuser --admin-password Redhat@12345
if [ $? -eq 0 ]
then
echo "$tsvm is successfully created"
echo "Attaching $ossnap disk to $tsvm"
echo "Attaching is progress"
az vm disk attach -g $ResourceGroup --vm-name $tsvm --disk $diskId
echo "$ossnap disk is successfully attached"
else
echo "$tsvm is not created, please check the logs for further analysis"
fi
#az vm create \
#  --resource-group myResourceGroup \
#  --name myVM \
#  --image centos \
#  --admin-username azureuser \
#  --admin-password redhat
#az vm disk attach -g $ResourceGroup --vm-name $tsvm --disk $diskId
echo "Copying mount.sh script to newly created vm"
scp mount.sh azuser@`az vm list-ip-addresses -n $tsvm --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -o tsv`:/tmp/
echo "Now lets login to the $tsvm"
ssh `az vm list-ip-addresses -n $tsvm --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -o tsv` -l azuser -t  "sh /tmp/mount.sh"
echo "Please let us know the result of mount.sh i.e. whether it is successful or unsuccessful"
read result
case $result in
successful)
echo "Be patient!!!! Realx.....Performing Disk Swap Operation"
#scp umount.sh azuser@`az vm list-ip-addresses -n $tsvm --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -o tsv`:/tmp/
#ssh `az vm list-ip-addresses -n $tsvm --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -o tsv` -l azuser -t  "sh -vx /tmp/umount.sh"
;;
unsuccessful)
echo "Please try to perform manual troubleshooting"
;;
*)
echo "Sorry, we do not have this option $result provided by you"
exit
;;
esac

echo "*********************************************************"
echo "*********************************************************"
echo "*********************************************************"
echo "Please let us know if you would like to swap the OS disk. i.e. YES or NO"
read choice
case $choice in
YES)
az vm disk detach -g $ResourceGroup --vm-name $tsvm -n $ossnap
az vm update --name $flvm --resource-group $ResourceGroup --os-disk $diskId
echo "Please check the status of the $flvm"
;;
NO)
echo "Please continue your steps to make the $flvm up"
;;
*)
exit
;;
esac