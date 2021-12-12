
setup

sudo apt-get update
sudo apt-get upgrade
sudo reboot

sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack -i

git clone https://opendev.org/openstack/devstack -b stable/wallaby
cd devstack
nano local.conf 

[[local|localrc]]

HOST_IP=192.168.1.71
ADMIN_PASSWORD=vg52xgt72!
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD


настройка ДНС


sudo nano /etc/nsswitch.conf

hosts:          files resolve dns

nano /etc/systemd/resolved.conf

[Resolve]
DNS=8.8.8.8 8.8.8.4 192.168.1.1

./stack.sh

Далее openstack доступен по адресу:


https://192.168.1.71/dashboard 

http://109.195.21.216:6080/dashboard

Пользователь test пароль test1


Делаем инстанс доступным из компьютера локальной сети. Создаем маршрут на машине или роутере


route add 172.24.4.0 mask 255.255.255.0 192.168.1.71



losetup -f --show /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
vgchange -a y stack-volumes-lvmdriver-1
systemctl restart devstack@c-vol.service



















