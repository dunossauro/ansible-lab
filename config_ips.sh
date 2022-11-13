ssh_file=~/.ssh/id_rsa.pub

echo "- Configurando SSH"
if [[ ! -f "$ssh_file" ]]; then
    ssh-keygen
fi

echo "- Obtendo ip das vms"
centos_ip=$(vagrant ssh centos -c "hostname -I" | awk '{print $2}')
arch_ip=$(vagrant ssh arch -c "ip -4 -brief address show eth1" | awk '{print $3}'| cut -d'/' -f 1)
ubuntu_ip=$(vagrant ssh ubuntu -c "hostname -I" | awk '{print $2}')

echo "- Configurando o SSH nas vms"
ssh-copy-id -f vagrant@$centos_ip
ssh-copy-id -f vagrant@$arch_ip
ssh-copy-id -f vagrant@$ubuntu_ip

echo "Configure o seu arquivo de inventário: /etc/ansible/hosts"
echo

echo "[ubuntu]"
echo "$ubuntu_ip ansible_user=vagrant"
echo

echo "[arch]"
echo "$arch_ip ansible_user=vagrant"
echo

echo "[centos]"
echo "$centos_ip ansible_user=vagrant"
echo

echo "[linux]"
echo "$centos_ip ansible_user=vagrant"
echo "$ubuntu_ip ansible_user=vagrant"
echo "$arch_ip ansible_user=vagrant"
