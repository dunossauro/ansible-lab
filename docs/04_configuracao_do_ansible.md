# Entendo a estrutura do ansible

TODO: Criar uma intro bonita e explicar diversas coisas legais

### Arquivo de inventário

Por padrão o arquivo de inventário das máquinas ficam no `/etc/ansible/hosts`. Vamos criar esse arquivo agora.

```bash
sudo nano /etc/ansible/hosts
```
É nesse arquivo que colocamos os endereços dos nós que serão controlados pelo ansible. O arquivo tem o seguinte formato:

```txt
[<nome_do_grupo>]
<endereço_da_maquina>  <opções>
```

Por exemplo, vamos cadastrar nossa outra vm `arch` que será controlado pelo `main`. Para isso, precisamos iniciar essa máquina virtual. Antes disso, temos que sair do ssh em `main`:

```bash
exit

logout
```

Agora voltamos a maquina principal. A máquina onde as máquinas virtuais foram instaladas. Para super o `arch`:

```bash
vagrant up arch
```

Com isso, agora devemos ter duas máquinas no nosso virtual box:

![](./images/virtualbox_03.png)

Com nossa vm já de pé, podemos enviar um comando para o vagrant nos dizer o endereço ip da máquina `arch`:

```bash
vagrant ssh arch -c "ip addr"
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:fa:60:9b brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 metric 1024 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86241sec preferred_lft 86241sec
    inet6 fe80::a00:27ff:fefa:609b/64 scope link 
       valid_lft forever preferred_lft forever
```

Podemos ver que o IP associado a `arch` é `10.0.2.15`. Que é o endereço que colocaremos no nosso inventário.

Agora vamos voltar a nossa máquina `main` via ssh:

```bash
vagrant ssh main
```

E vamos alterar nosso arquivo `/etc/ansible/hosts` dessa forma e com o comando `sudo nano /etc/ansible/hosts`:

```txt
[arch]
10.0.2.15
```

Dessa forma dissemos ao ansible que existe um grupo chamado `arch`, uma dessas máquinas tem o ip `10.0.2.15`. Assim, podemos enviar comandos para o grupo `arch`.

### Primeiro comando remoto

E podemos checar enviando um `ping` para a vm `arch` usando o seguinte comando `ansible arch -m ping`:

```bash
ansible arch -m ping

The authenticity of host '10.0.2.15 (10.0.2.15)' can't be established.
ED25519 key fingerprint is SHA256:FyOy2yTlOHSLJXVF+lmYjPywdfmQprApMWrsQ7KxUlI.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: localhost
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
10.0.2.15 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Warning: Permanently added '10.0.2.15' (ED25519) to the list of known hosts.\r\nvagrant@10.0.2.15: Permission denied (publickey,password).",
    "unreachable": true
}
```

Um erro ocorreu por conta da segurança. O SSH da vm `arch` não permitiu que o ansible fizesse a conexão. Para isso precisamos trocar chaves entre os hosts para que aconteça de maneira segura.

## Troca de chaves SSH

Vamos voltar ao shell e digitar os seguintes comandos:

```bash
ssh-keygen  # para gerar uma chave ssh para nossa vm `main`
ssh-copy-id vagrant@10.0.2.15  # Para copiar a chave de `main` para `arch`
```

Se executarmos o ping novamente obteremos sucesso:

```bash
ansible arch -m ping

10.0.2.15 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}

```

Isso significa que a comunicação com os dois nós está acontecendo de maneira correta. Mas, faltou entender o que o comando `ansible arch -m ping` significa:

- ansible: Chama o ansible
- arch: O nome do grupo do inventário
- -m: Significa que vamos chamar um módulo
- ping: Módulo para checar se o grupo está respondendo
