i=0
domians=
for domain in `cat /root/hosts.csv`
do
#	echo ${domain}
#	echo "nslookup -query=aaaa ${domain}"
    v6orig=`nslookup -query=aaaa ${domain}`
    v6addr=`echo ${v6orig}|grep -Eo 'answer:.*Auth'| grep -Eo '([0-9,a-f]{0,4}[\:]){2,7}[0-9,a-f]{0,4}'`
#    echo "2"
#    echo ${v6addr}
    if [[ -z ${v6addr} ]]; then
        domains+='\n'
        domains+=${domain}
    fi
    clear
    echo "current domain:${domain}"
    echo "current ipv6addr:${v6addr}"
    i=$(( $i+1 ))
    echo "current num :${i}"
    echo "------------------------------"
    echo -e "noipv6 domains:${domains}"

#    if (( i%10 == 0 )); then
#		clear
#    fi
done
