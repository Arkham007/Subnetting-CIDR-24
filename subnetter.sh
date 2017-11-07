#!/bin/bash
# Sohail Muhammad
# Class C subnet calculator

subnet=$1
init=1
count=$2

network=`echo $1 | cut -d'/' -f1`
notation=`echo $1 | cut -d'/' -f2`

targetPower=$(echo "32-$notation"|bc)
totalHosts=`echo "2^(32-$notation)"|bc`
host=$(echo "$totalHosts/$count"|bc)

firstOctet=$(echo $network | awk -F\. '{print $1}')
secondOctet=$(echo $network | awk -F\. '{print $2}')
thirdOctet=$(echo $network | awk -F\. '{print $3}')
forthOctet=$(echo $network | awk -F\. '{print $4}')
power=1

iteration=$count
totalHosts=$(echo "$totalHosts-(2^$power)"|bc)
host=$(echo "$totalHosts/$iteration"|bc)

while [ $init -le $count ]
do
 power=1
    while [ $power -le $targetPower ]
    do
         if [ $(echo "2^$power"|bc) -ge $host ]
         then
            finalpower=$power
            ((--iteration))
            tmpgateway=$(echo "$forthOctet+1"|bc)
            gateway=$(echo $firstOctet"."$secondOctet"."$thirdOctet"."$tmpgateway)
            subnet=$(echo $firstOctet"."$secondOctet"."$thirdOctet"."$forthOctet"/"$(echo "(32-$finalpower)"|bc))
            network=$(echo $firstOctet"."$secondOctet"."$thirdOctet"."$forthOctet)
            tmpbroadcast=$(echo "$forthOctet+2^$finalpower-1"|bc)
            broadcast=$(echo $firstOctet"."$secondOctet"."$thirdOctet"."$tmpbroadcast)
            finalhost=$(echo "2^$finalpower"-3|bc)
            echo "subnet = $subnet network = $network broadcast = $broadcast gateway = $gateway hosts = $finalhost"
            break
         fi
         ((++power))
    done

    forthOctet=$(echo "$forthOctet+(2^$finalpower)"|bc)
    totalHosts=$(echo "$totalHosts-(2^$finalpower)"|bc)
if [ $totalHosts -le 0 ]
then
exit 1
fi
    host=$(echo "$totalHosts/$iteration"|bc)
    ((++init))
done