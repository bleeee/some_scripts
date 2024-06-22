apt update -y && apt upgrade -y
apt install minicom p7zip-full python3-smbus python3-pillow python3-numpy python3-rpi.gpio vlc wireguard ffmpeg udhcpc traceroute dnsutils -y
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.60.tar.gz
wget http://www.waveshare.net/w/upload/0/06/Fan_HAT.7z
tar zxvf bcm2835-1.60.tar.gz
cd bcm2835-1.60/
sudo ./configure
sudo make && sudo make check && sudo make install
cd ..
7z x Fan_HAT.7z  -r -o./Fan_HAT
sed -i 'N;$!P;$!D;$i sudo nohup python3 /root/Fan_HAT/python/main.py >dev/null 2>&1 &' /etc/rc.local
sed -i 's/Temp(Celsius)/(°C)CPU/g' /root/Fan_HAT/python/main.py
sed -i 's/,16)/,8)/g' /root/Fan_HAT/python/main.py
sed -i 's/(85,/(47,/g' /root/Fan_HAT/python/main.py
mkdir carcam
cd carcam
https://github.com/bluenviron/mediamtx/releases/download/v1.8.3/mediamtx_v1.8.3_linux_arm64v8.tar.gz
tar zxvf mediamtx_v1.8.3_linux_arm64v8.tar.gz
wget https://github.com/bleeee/some_scripts/raw/master/stream.sh.live
wget https://github.com/bleeee/some_scripts/raw/master/stream.sh.debug
cp stream.sh.live stream.sh
chmod +x stream.sh
chmod +x stream.sh.live
chmod +x stream.sh.debug
cd ..
wget -O /etc/systemd/system/stream.service https://github.com/bleeee/some_scripts/raw/master/stream.service
wget -O /etc/wireguard/wg0.conf https://github.com/bleeee/some_scripts/raw/master/wg0.conf
wget -O /root/check_ping.sh https://github.com/bleeee/some_scripts/raw/master/check_ping.sh
wget -O /root/temp.sh https://github.com/bleeee/some_scripts/raw/master/temp.sh
chmod +x check_ping.sh
chmod +x temp.sh
(crontab -l ; echo "* * * * * /root/check_ping.sh") | crontab -
(crontab -l ; echo "*/10 * * * * /root/temp.sh") | crontab -
read -p "请输入私钥: " PrivateKey 
read -p "请输入公钥: " PublicKey 
read -p "请输入PSK: " PresharedKey 
read -p "请输入地址: " Endpoint
sed -i "s|^PrivateKey = .*|PrivateKey = $PrivateKey|" /etc/wireguard/wg0.conf
sed -i "s|^PublicKey = .*|PublicKey = $PublicKey |" /etc/wireguard/wg0.conf
sed -i "s|^PresharedKey = .*|PresharedKey = $PresharedKey |" /etc/wireguard/wg0.conf
sed -i "s|^Endpoint = .*|Endpoint = $Endpoint|" /etc/wireguard/wg0.conf
systemctl daemon-reload
systemctl enable wg-quick@wg0
systemctl enable stream.service
#CONNECTION_NAME=$(nmcli connection show | grep usb0 | awk '{$NF=""; $(NF-1)=""; $(NF-2)=""; print $0}' | sed 's/[[:space:]]*$//')
#nmcli connection modify "$CONNECTION_NAME" ipv4.dns "1.1.1.1"
#nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns yes
dhclient -v usb0
udhcpc -i usb0
route add -net 0.0.0.0 usb0
