echo "* Start vm"
vagrant up arch

echo "* Get DHCP ip"
arch_ip=$(vagrant ssh arch -c "ip -4 -brief address show eth1" | awk '{print $3}'| cut -d'/' -f 1)
echo "** vm IP: $arch_ip"

echo "* Put IP on ansible/hosts"
printf "[test]\n$arch_ip ansible_user=vagrant" > /etc/ansible/hosts

echo "* Copy ssh to vm"
ssh-copy-id vagrant@$arch_ip

echo "* Ping vm"
ansible test -m ping
