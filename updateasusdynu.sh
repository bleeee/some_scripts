anip=`ip addr | grep ppp0| grep -Eo 'inet.*peer'| grep -Eo " .* "|sed 's/ //g'`
trueflag=""
for line in `nslookup ${hostname} ns1.dynu.com| grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
do
    if [[ ${line} == ${wanip} ]]; then
        trueflag="Already updated!"
        echo ${trueflag}
    fi
done
if [[ -z "${trueflag}" ]]; then
    wanipv6=`cat /tmp/ipv6_client_list | grep ${pcname}| grep -Eo '2001.*'`
    wget --spider --no-check-certificate "http://api.dynu.com/nic/update?hostname=${hostname}&myip=${wanip}&myipv6=${wanipv6}&password=${mypass}
    echo "updated!"
fi
