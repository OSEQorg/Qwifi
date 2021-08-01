# Instructions for building an image

# Download and flash image

- Download a Raspbian image and flash it to a USB stick
- Mount the USB stick, and create a `ssh` file on the =boot= partition.

# Resize partition [optional]

The size of your USB stick determines the minimum size of USB stick the final image can be flashed on. If you have a big USB stick, you probably want to disable the auto resize on first boot.

- Edit the file `cmdline.txt` and remove `init=/usr/lib/raspi-config/init_resize.sh` from it (we don't want the Pi to auto resize on boot).
- Directly after the first boot you have to resize the root partition by hand:

``` bash
sudo fdisk /dev/sda
p # show partitions
d # delete
2 # 2nd partition
n # create new partition
p # primary
# keep the first sector from the listing
+3G # resize partition to 3GiB
n # don't remove Ext4 signature
wq # write and save

# resize the ext4 filesystem
sudo resize2fs /dev/sda2
```

# First boot

- Boot the Pi with the USB stick
- Connect to pi@raspberrypi. If this doesn't work you need to log in to your
  router and find out what the IP address of the Pi is.

# Update packages

First update all system packages, this ensures the latest security updates are present.

```bash
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo reboot
```

# WiFi hotspot

Sets up a WiFi hotspot with the SSID `qwifi` without a password.

```bash
sudo raspi-config nonint do_hostname "qwifi.lan"
# find your country in /usr/share/zoneinfo/iso3166.tab
sudo raspi-config nonint do_wifi_country "NL"
sudo rfkill unblock
```

```bash
sudo apt-get install -y hostapd
cat <<EOF | sudo tee /etc/hostapd/hostapd.conf
country_code=NL
interface=wlan0
ssid=qwifi
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=0
EOF
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
```

# Routing

This is only necessary when you have a public Internet connection on eth0 and
want to share that via WiFi.

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo apt-get install -y iptables-persistent
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save
```

# DHCP and DNS server

```bash
cat <<EOF | sudo tee -a /etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

echo "DNSMASQ_EXCEPT=lo" | sudo tee -a /etc/default/dnsmasq

sudo apt-get install -y dnsmasq
# choose 'Y' to keep the current version of the config file.
cat <<EOF | sudo tee /etc/dnsmasq.conf
interface=wlan0
dhcp-range=192.168.4.20,192.168.4.200,255.255.255.0,24h
dhcp-option=3,192.168.4.1 # gateway
dhcp-option=6,192.168.4.1 # dns server
domain=lan
address=/qwifi.lan/192.168.4.1
log-queries
conf-dir=/etc/dnsmasq.d,*.conf
EOF
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq
```

# Web server

```bash
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo rm /var/www/html/index.nginx-debian.html
sudo sed -i '0,/try_files.*$/s//&\nautoindex on;/' /etc/nginx/sites-enabled/default
```

Nginx logs can quickly flood the filesystem, that is why we first need to
disable it. This also improves the privacy of our users.

```bash
cat <<EOF | sudo tee /etc/nginx/conf.d/disable-logging.conf
access_log off;
error_log off;
EOF
```

# Dynamic site configuration

Copy the file `discover-sites.sh` from your host to the Pi.
```bash
scp discover-sites.sh pi@raspberrypi:
```

Move the file on the Pi to the right location and make it executable:

```bash
sudo mv /home/pi/discover-sites.sh /opt/
sudo chmod +x /home/pi/discover-sites.sh
```

Create a SystemD service that will run discover-sites on boot up, before the network is started.

```bash
cat <<EOF | sudo tee /lib/systemd/system/discover-sites.service
[Unit]
Description=Discover sites
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/opt/discover-sites.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable discover-sites
```

# Testing

Reboot to make all changes effective.

```bash
sudo reboot
```

Test if the WiFi hotspot works. You should be able to connect to the `qwifi`
SSID without password. When you navigate to `http://qwifi.lan` you should see a
default Nginx page.

# Cleanup

```bash
sudo apt-get clean
sudo find /var/log -type f -mindepth 1 -print -delete
rm ~/.bash_history
sudo truncate -s 0 /etc/machine-id
sudo systemctl enable regenerate_ssh_host_keys
```

# TODO: create image

...
