# Instructions for building an image

## Requirements

- Linux PC
- Ethernet switch between Pi and PC
- Phone or laptop to test end result

## Download and flash image

- Download a Raspbian image and flash it to a USB stick
- Mount the boot partition, and create an empty file named `ssh` on it.

### Disable resize-on-first-boot

Raspbian resizes the root partition to fit the entire medium on the first
boot. We don't want that now, because the image needs to be as small as
possible. We'll resize the root partition by hand on the first boot. Resize on
first boot will be setup again when the image build is finished.

- Edit the file `cmdline.txt` and remove
  `init=/usr/lib/raspi-config/init_resize.sh` from it (we don't want the Pi to
  auto resize on boot).
- Mount the root partition and move the file `etc/init.d/resize2fs_once` to `home/pi`.
- Remove the symlink `etc/rc3.d/S01resize2fs_once`.

## First boot

- Boot the Pi with the USB stick
- Connect to pi@raspberrypi. If this doesn't work you need to log in to your
  router and find out what the IP address of the Pi is.

### Resize root partition

``` bash
sudo fdisk /dev/sda
p # show partitions
d # delete
2 # 2nd partition
n # create new partition
p # primary

## Download and flash image# keep the first sector from the listing
+2G # resize partition to 2GiB
n # don't remove Ext4 signature
wq # write and save

# resize the ext4 filesystem
sudo resize2fs /dev/sda2
```

## Update packages

First update all system packages, this ensures the latest security updates are present.

```bash
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo reboot
```

## WiFi hotspot

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

## Routing

This is only necessary when you have a public Internet connection on eth0 and
want to share that via WiFi.

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo apt-get install -y iptables-persistent
# when asked about saving the current iptables rules you can either choose Yes or No, it doesn't matter.
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save
```

## DHCP and DNS server

```bash
cat <<EOF | sudo tee -a /etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

echo "DNSMASQ_EXCEPT=lo" | sudo tee -a /etc/default/dnsmasq

sudo apt-get install -y dnsmasq
# choose 'N' to keep the current version of the config file.
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

## Web server

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

## Dynamic site configuration

Copy the file `discover-sites.sh` from your host to the Pi.
```bash
scp discover-sites.sh pi@raspberrypi:
```

Move the file on the Pi to the right location and make it executable:

```bash
sudo mv /home/pi/discover-sites.sh /opt/
sudo chmod +x /opt/discover-sites.sh
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

## Testing

Reboot to make all changes effective.

```bash
sudo reboot
```

Test if the WiFi hotspot works. You should be able to connect to the `qwifi`
SSID without password. When you navigate to `http://qwifi.lan` you should see a
empty directory listing.

## Restore resize-on-first-boot

Edit `/boot/cmdline.txt` and append `init=/usr/lib/raspi-config/init_resize.sh`
to the first line (make sure there is a space before "init").

```bash
sudo mv /home/pi/resize2fs_once /etc/init.d/
cd /etc/rc3.d
sudo ln -sf ../init.d/resize2fs_once S01resize2fs_once
```

## Cleanup

```bash
sudo apt-get clean
sudo find /var/log -type f -mindepth 1 -print -delete
rm ~/.bash_history
sudo truncate -s 0 /etc/machine-id
sudo systemctl enable regenerate_ssh_host_keys
```

## Baking the image

Power off the pi:

```bash
sudo poweroff
```

Wait for the green light to stop blinking. Remove the power cable and remove the
USB stick or SD card from the Pi. Insert it in your computer.

Lookup the disk name with:

```bash
lsblk
```

We'll use `/dev/sda` for the example, replace this with the disk you found in
the above command.

```bash
sudo dd if=/dev/sda of=qwifi.img bs=1M count=2400
gzip -k qwifi.img
```
