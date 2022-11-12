# Laboratório para Live de Python sobre Ansible

Repositório com os passos e arquivos que você deve seguir para configurar o seu ambiente.

Como não usaremos nemhuma plataforma de cloud, todo nosso ambiente será configurado localmente. Para isso usaremos o virtualbox e o vagrant.

## Configurando o lab
> Esse guia **até o momento** usa archlinux como base para os comandos, caso você use outra distribuição ou mesmo outro sistema operacional. Faça o comando de acordo com as especificações do seu sistema.

### Passos para instalação

> Onde houver `paru -S` troque pelo seu gerenciador de pacotes `apt`, `choco`, `dnf` e etc...

- Abra seu terminal de preferência

- Instale o virtualbox:

```bash 
paru -S virtualbox                # Arch
choco install virtualbox          # Windows
sudo apt-get install virtualbox   # Ubuntu
```

- Instale o Vagrant:
```
paru -S vagrant        # Arch
choco install vagrant  # Windows

# Ubuntu
curl -O https://releases.hashicorp.com/vagrant/2.3.2/vagrant_2.3.2-1_amd64.deb
sudo apt install ./vagrant_3.2.1_x86_64.deb
```

### Passos para configuração

- Clone o repositório do lab: `git clone git@github.com:dunossauro/ansible-lab.git`

- Navegue até o diretório do lab: `cd ansible-lab`

- Inicie as máquinas com vagrant: `vagrant up`

Com isso as vms serão baixadas e configuradas. (Esse passo pode demorar bastante).

> Caso você use um notebook ou tenha mais de uma placa de rede, durante as criações das máquinas virtuais o vagrant pode perguntar a você sobre qual placa de rede gostaria de usar para a ponte da máquina virtual e a internet. Lembre-se de selecionar o seu hardware conectado

Vamos checar se as máquinas foram devidamente configuradas pelo vagrant. Execute o comando no seu terminal:

```bash
vboxmanage list vms
```

A resposta deve ser parecida com essa. Não exatamente igual. Pois o hashs serão diferentes:

```bash
"ansible_lab_arch_1668237414490_48573" {d3aba27b-dfcc-4783-9e5b-bd6fff7ee75b}
"ansible_lab_ubuntu_1668237678951_58003" {9eceddae-2575-4897-8c27-3051dba177df}
"ansible_lab_centos_1668237995402_51658" {3dfc5f48-07b0-4c14-9f20-2907d6d4c8a1}
```

O importante é que tenhamos as 3 máquinas virtuais:

1. ansible_lab_`arch`

2. ansible_lab_`ubuntu`

3. ansible_lab_`centos`

> Caso você tenha outras máquinas virtuais presentes no seu virtualbox, não tem problema. O importante é que as 3 estejam criadas.

O passo que precisamos para seguir agora são os ips das máquinas para que possamos acessar com ansible.

Podemos rodar o seguinte comando no vagrant:

```bash
vagrant ssh <nome_do_so> -c "ip -4 -brief address show"
```

Por exemplo:

```bash
vagrant ssh centos -c "ip -4 -brief address show"
```

Nos dará a resposta: 

```
lo               UNKNOWN        127.0.0.1/8 
eth0             UP             10.0.2.15/24 
eth1             UP             192.168.15.78/24 
```

Queremos o ip externo da máquina `192.168.15.78`. Repita esse passo para as outras vms.

Os meus ips foram os seguintes:

- Arch: 192.168.15.79
- Centos: 192.168.15.78
- Ubuntu: 192.168.15.77

Guarde esses ips pois vamos usar eles no ansible

### Informações importantes

Tanto o usuário das vms quanto a senha delas é `vagrant`.
