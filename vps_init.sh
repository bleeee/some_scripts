#! /bin/bash
apt-get update -y&& apt-get upgrade -y && apt-get dist-upgrade -y&& apt-get install openvpn lzop -y
ip=""
netcard=""
url="www.baidu.com/openvpn.tar.gz"
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

set_iptables(){
netcard=`ip addr| grep $ip|grep -Eo 'global .*$'| grep -Eo ' .*$'| sed 's/ //g'`
echo ${netcard}
iptables -t nat -D POSTROUTING -o ${netcard} -s 192.168.88.0/24 -j SNAT --to-source ${ip}
iptables -t nat -D PREROUTING -i ${netcard} -d ${ip} -j DNAT --to-destination 192.168.88.6
iptables -t nat -A POSTROUTING -o ${netcard} -s 192.168.88.0/24 -j SNAT --to-source ${ip}
iptables -t nat -A PREROUTING -i ${netcard} -d ${ip} -j DNAT --to-destination 192.168.88.6
}
modify_sysctl(){
sed  -i 's/\#net\.ipv4\.ip_forward\=1/net\.ipv4\.ip_forward\=1/g'  /etc/sysctl.conf
sed  -i 's/\#net\.ipv4\.conf\.all\.send_redirects = 0/net\.ipv4\.conf\.all\.send_redirects = 0/g' /etc/sysctl.conf
sed  -i 's/\#net\.ipv4\.conf\.all\.accept_redirects = 0/net\.ipv4\.conf\.all\.accept_redirects = 0/g' /etc/sysctl.conf

sysctl -p
}
get_config(){
wget ${url} -O /tmp/ovpn.tar.gz
tar -zxvf /tmp/ovpn.tar.gz -C /
chmod +x /etc/openvpn/checkpsw.sh
}
Get_IP
set_iptables
modify_sysctl
get_config
openvpn --config /etc/openvpn/server.conf --daemon vps
