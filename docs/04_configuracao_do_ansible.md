# Configuração do ansible

### Instalação do ansible

Agora que temos duas máquinas virtuais criadas. Podemos começar a instalação do ansible. A primeira coisa que devemos fazer é acessar a máquina controladora. Para isso podemos usar o `vagrant` para nos ajudar:

```bash
vagrant up main   # Iniciar a máquina controladora
vagrant ssh main  # Acessar o console da máquina controladora via ssh
```

E isso deve retornar o console dá maquina controladora no usuário `vagrant`:

![](./images/console.png)

O ansible tem seus pacotes nos repositórios de quase todas as distribuições linux. Então você pode instalar no seu sistema como quiser.

> Caso tenha dúvidas, o [link da documentação](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Formas de instalar em diversos sistemas.

```bash
sudo pacman -S ansible     # Arch
sudo apt install ansible   # Ubuntu
sudo dnf ansible           # Familia Redhat
```

O ansible também pode ser instalado via `pip`, porém a instalação é bastante trabalhosa.


Como eu escolhi que a máquina `main` fosse um archlinux, vamos seguir a configuração com ele. O primeiro passo que devemos fazer é atualizar a máquina para garantir que tudo funcione como o esperado:

```bash
sudo pacman -Syu  # Atualiza o sistema
```

Caso a senha senha perguntada. A senha padrão criada pelas máquinas virtuais do vagrant é `vagrant`.

Agora podemos rodar o comando para instalar o ansible:

```bash
sudo pacman -S ansible
```

Se tudo ocorrer como o esperado, podemos perguntar a versão do ansible ao sistema:

```bash
[vagrant@archlinux ~]$ ansible --version
ansible [core 2.14.0]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.10/site-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.8 (main, Nov  1 2022, 14:18:21) [GCC 12.2.0] (/usr/bin/python)
  jinja version = 3.1.2
  libyaml = True
```

Ele nos disse que está na versão `3.10.8`

### Instalação de um editor de textos

Recomendo fortemente que instale um editor de textos. Para facilitar a manutenção do sistema. Você pode usar o que quiser, porém, usarei o `nano` nesse tutorial. E para começarmos com pé direito no ansible, vamos fazer essa instalação usando-o e já partirmos para o nosso primeiro comando:

```bash
ansible localhost -a "sudo pacman -S nano --noconfirm"
```

E iremos receber esse resultado:

```bash
[WARNING]: No inventory was parsed, only implicit localhost is available
localhost | CHANGED | rc=0 >>
resolving dependencies...
looking for conflicting packages...

Packages (1) nano-6.4-1

Total Installed Size:  2.49 MiB

:: Proceed with installation? [Y/n] 
checking keyring...
checking package integrity...
loading package files...
checking for file conflicts...
checking available disk space...
:: Processing package changes...
installing nano...
:: Running post-transaction hooks...
(1/1) Arming ConditionNeedsUpdate...
```

O que significa que conseguimos fazer uma instalação na máquina local usando ansible. Isso é de mais.

#### Entendendo esse comando

Precisamos entender o básico do comando que executamos com ansible agora:

```bash
ansible localhost -a "sudo pacman -S nano --noconfirm"
```

Podemos dividi-lo em quatro partes:

- ansible: chama o ansible
- localhost: diz que a ação será executada no localhost
- -a: Argumentos que passaremos para o comando
- "sudo pacman -S nano --noconfirm": Os argumentos do comando

Quando só dizemos o nome do host `localhost` e colocamos os argumentos `-a` significa que ansible executará os argumentos como um comando de shell. Nesse caso `"sudo pacman -S nano --noconfirm"` é um comando de shell que serve para instalar o `nano`.


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
