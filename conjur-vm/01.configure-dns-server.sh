#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
yum install -y dnsmasq net-tools bind-utils
cat << EOF > /etc/dnsmasq.d/conjurlab-dns.conf
listen-address=$CONJUR_IP,127.0.0.1
server=8.8.8.8
address=/apps-crc.testing/$CRC_IP
address=/crc.testing/$CRC_IP
expand-hosts
EOF
grep -qxF "$CONJUR_IP conjur-master.$LAB_DOMAIN" /etc/hosts || echo "$CONJUR_IP conjur-master.$LAB_DOMAIN" >> /etc/hosts
grep -qxF "$CRC_IP ocp-crc.$LAB_DOMAIN" /etc/hosts || echo "$CRC_IP ocp-crc.$LAB_DOMAIN" >> /etc/hosts

systemctl enable dnsmasq
systemctl restart dnsmasq
firewall-cmd --add-service=dns --permanent
firewall-cmd --reload

conn_name=$(nmcli con | grep ethernet | awk '{print $1}')
nmcli con mod $conn_name ipv4.dns 127.0.0.1
systemctl restart NetworkManager

set +x