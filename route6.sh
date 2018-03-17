#!/bin/sh
while [ true ]; do
pfix=`ip -6 route| grep default| grep ::/64|cut -d " " -f 3`
result=`ip -6 route|grep pppoe-wan |grep $pfix | grep -v 'default'`
if [[ "$result" != "" ]]
then
	ip -6 route del $pfix
 	ip -6 route add $pfix dev br-lan
fi
done
