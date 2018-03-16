#! /bin/bash
ip=""
netcard=""
Get_IP(){
  while true
  do
    if [[ -z "${ip}" ]]; then
      ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
      echo ${ip}
    fi
    if [[ -z "${ip}" ]]; then
      ip=$(wget -qO- -t1 -T2 -4 api.ip.sb/ip)
      echo ${ip}
    fi
    if [[ -z "${ip}" ]]; then
      ip=$(wget -qO- -t1 -T2 members.3322.org/dyndns/getip)
      echo ${ip}
    fi
    if [[ -n "${ip}" ]]; then
      break
    fi
  done
  echo "done with ip : ${ip}"
}

enable_iptables(){
netcard=`ip addr| grep $ip|grep -Eo 'global .*$'| grep -Eo ' .*$'| sed 's/ //g'`
echo ${netcard}
iptables -t nat -D POSTROUTING -o ${netcard} -s 192.168.88.0/24 -j SNAT --to-source ${ip}
iptables -t nat -D PREROUTING -i ${netcard} -d ${ip} -j DNAT --to-destination 192.168.88.6
iptables -t nat -A POSTROUTING -o ${netcard} -s 192.168.88.0/24 -j SNAT --to-source ${ip}
iptables -t nat -A PREROUTING -i ${netcard} -d ${ip} -j DNAT --to-destination 192.168.88.6
}
/etc/init.d/ssr stop
Get_IP
enable_iptables
openvpn --config /etc/openvpn/server.conf --daemon vps
