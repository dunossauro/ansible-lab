# sync ssh from ansible hosts
ips=$(cat /etc/ansible/hosts | tail -n 3 | cut -f 1 -d' ')

echo "* Limpando know hosts"
rm -rf ~/.ssh/known_hosts

for ip in $ips
do
    ssh-copy-id vagrant@$ip
done

ansible linux -m ping
