# Get vagrant machines ips
machines=('arch' 'ubuntu' 'centos')

ips=()

echo '# Seu inventario (/etc/ansible/hosts)'

for machine in "${machines[@]}"
do
    ip=$(vagrant ssh $machine -c "ip -4 -brief address show" | awk '{print $3}'| cut -d'/' -f 1 | tail -n 1)
    echo [$machine]
    echo $ip ansible_user=vagrant
    echo
    ips+=($ip)
done

echo [linux]

for ip in "${ips[@]}"
do
    echo $ip ansible_user=vagrant
done
