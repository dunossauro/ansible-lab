vagrant up
bash arch_scripts/get_vagrant_ips.sh > ansible_hosts
vagrant ssh ansible_main -c "sudo pacman -Sy ansible sshpass --noconfirm --needed"
vagrant ssh ansible_main -c "sudo cp /vagrant/ansible_hosts /etc/ansible/hosts"
vagrant ssh ansible_main -c 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""'
vagrant ssh ansible_main -c "bash /vagrant/arch_scripts/ips_from_hosts.sh"
