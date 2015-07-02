#/bin/bah

INIT_SSH=true
INIT_RHSM=true
INIT_DNSMASQ=true
INIT_RESOLVCONF=true
INIT_HOSTS=true

if [ "$INIT_SSH" == "true" ]; then
    ssh-copy-id vagrant@ose300-master
    ssh-copy-id vagrant@ose300-node1
    ssh-copy-id vagrant@ose300-node2
fi

if [ "$INIT_RHSM" == "true" ]; then
    scp setup-subscription-manager.sh .rhn-* vagrant@ose300-master:
    scp setup-subscription-manager.sh .rhn-* vagrant@ose300-node1:
    scp setup-subscription-manager.sh .rhn-* vagrant@ose300-node2:
    ssh vagrant@ose300-master sudo sh setup-subscription-manager.sh &
    ssh vagrant@ose300-node1 sudo sh setup-subscription-manager.sh &
    ssh vagrant@ose300-node2 sudo sh setup-subscription-manager.sh &
    wait
    ssh vagrant@ose300-master rm setup-subscription-manager.sh .rhn-\*
    ssh vagrant@ose300-node1 rm setup-subscription-manager.sh .rhn-\*
    ssh vagrant@ose300-node2 rm setup-subscription-manager.sh .rhn-\*
fi

ssh vagrant@ose300-master sudo yum remove NetworkManager\* -y
ssh vagrant@ose300-node1 sudo yum remove NetworkManager\* -y
ssh vagrant@ose300-node2 sudo yum remove NetworkManager\* -y

if [ "$INIT_DNSMASQ" == "true" ]; then
    scp setup-dnsmasq.sh vagrant@ose300-node1:
    ssh vagrant@ose300-node1 sudo sh setup-dnsmasq.sh
    ssh vagrant@ose300-node1 rm setup-dnsmasq.sh
fi

if [ "$INIT_RESOLVCONF" == "true" ]; then
    ssh vagrant@ose300-master sudo sh -c '"echo \"nameserver 192.168.232.201
$(cat /etc/resolv.conf)\" > /etc/resolv.conf"'
    ssh vagrant@ose300-node1 sudo sh -c '"echo \"nameserver 192.168.232.201
$(cat /etc/resolv.conf)\" > /etc/resolv.conf"'
    ssh vagrant@ose300-node2 sudo sh -c '"echo \"nameserver 192.168.232.201
$(cat /etc/resolv.conf)\" > /etc/resolv.conf"'
fi

if [ "$INIT_HOSTS" == "true" ]; then
    ssh vagrant@ose300-master sudo sh -c '"cat << EOM >> /etc/hosts

192.168.232.101 ose300-master.example.com ose300-master
192.168.232.201 ose300-node1.example.com ose300-node1
192.168.232.202 ose300-node2.example.com ose300-node2
EOM"'
    ssh vagrant@ose300-node1 sudo sh -c '"cat << EOM >> /etc/hosts

192.168.232.101 ose300-master.example.com ose300-master
192.168.232.201 ose300-node1.example.com ose300-node1
192.168.232.202 ose300-node2.example.com ose300-node2
EOM"'
    ssh vagrant@ose300-node2 sudo sh -c '"cat << EOM >> /etc/hosts

192.168.232.101 ose300-master.example.com ose300-master
192.168.232.201 ose300-node1.example.com ose300-node1
192.168.232.202 ose300-node2.example.com ose300-node2
EOM"'

    ssh vagrant@ose300-master sudo hostnamectl set-hostname ose300-master.example.com
    ssh vagrant@ose300-node1 sudo hostnamectl set-hostname ose300-node1.example.com
    ssh vagrant@ose300-node2 sudo hostnamectl set-hostname ose300-node2.example.com
fi
