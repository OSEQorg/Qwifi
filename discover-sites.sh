#!/usr/bin/env bash
truncate -s0 /etc/dnsmasq.d/sites.conf
find /etc/nginx/sites-enabled -type f -not -name default -delete

for site in $(find /var/www/html/ -mindepth 1 -maxdepth 1 -type d -printf "%f\n"); do
    echo "address=/${site}.lan/192.168.4.1" >> /etc/dnsmasq.d/sites.conf
    cat <<EOF > "/etc/nginx/sites-enabled/${site}"
server {
	listen 80;
	server_name ${site}.lan;

	root /var/www/html/${site};
	index index.html index.htm;

	location / {
		try_files \$uri \$uri/ =404;
	}
}
EOF
done
