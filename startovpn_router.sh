iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE
iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE
iptables -D FORWARD -o tun0 -j ACCEPT                
iptables -D FORWARD -o br-lan -j ACCEPT
iptables -D FORWARD -o tun0 -j ACCEPT                
iptables -D FORWARD -o br-lan -j ACCEPT
echo `openvpn --config /etc/openvpn/la.conf --daemon la-vps`
iptables -t nat -I POSTROUTING -o tun0 -j MASQUERADE
iptables -I FORWARD -o tun0 -j ACCEPT
iptables -I FORWARD -o br-lan -j ACCEPT
