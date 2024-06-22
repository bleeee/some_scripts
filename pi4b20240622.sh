apt update -y && apt upgrade -y
apt install minicom p7zip-full python3-smbus python3-pillow python3-numpy python3-rpi.gpio vlc -y
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
