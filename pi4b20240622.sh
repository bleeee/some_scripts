apt update -y && apt upgrade -y
apt install minicom p7zip-full python3-smbus python3-pillow python3-numpy python3-rpi.gpio
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.60.tar.gz
wget http://www.waveshare.net/w/upload/0/06/Fan_HAT.7z
tar zxvf bcm2835-1.60.tar.gz
cd bcm2835-1.60/
sudo ./configure
sudo make && sudo make check && sudo make install
cd ..
7z x Fan_HAT.7z  -r -o./Fan_HAT
sed -i '2i /root/Fan_HAT/python/main.py' /etc/rc.local
