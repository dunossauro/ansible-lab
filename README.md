# Laboratório para Live de Python sobre Ansible

O objetivo desse repositório é ajudar você a construir um laboratório para aprender Ansible. Aqui você vai encontrar dicas e passos para configurar suas máquinas virtuais para construir seu ambiente.

A minha ideia principal com essa live é não depender de nenhum serviço de nuvem. Nem todas as pessoas podem pagar ou tem cartão de crédito para poder inserir mesmo nos planos gratuitos.

Para não depender de serviços externos, vamos usar máquinas virtuais com [virtualbox](https://www.virtualbox.org/) e vamos configurá-las usando [Vagrant](https://www.vagrantup.com/).

## Sumário

- [Configurando seu laboratório](#configurando-seu-laborat%C3%B3rio)
- [Básico necessário sobre Vagrant](#b%C3%A1sico-necess%C3%A1rio-sobre-vagrant)
  - [Configurando duas máquinas virtuais](#configurando-duas-máquinas-virtuais)
  - [Configurações adicionais do vagrant](#configurações-adicionais-no-vagrant)

---

## Configurando seu laboratório

Ansiedade já bateu, né? Vamos construindo uma passinho de cada vez.

### Passos para instalação

> Caso você use o windows, as instalações podem ser feitas via [chocolatey](https://chocolatey.org/install#individual)

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

## Básico necessário sobre Vagrant

Vagrant é uma ferramenta para provisionamento de máquinas virtuais. Dizendo de forma simples, ele cria e configura máquinas virtuais usando um arquivo de configuração chamado `Vagrantfile`. Nesse arquivo podemos descrever como nossas vms serão configuras.

Exemplo de um arquivo do Vagrant:

```ruby
# nome do arquivo: Vagrantifle
Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
end
```

Se tivermos esse arquivo no nosso diretório, podemos executar o vagrant:

```bash
vagrant up
```

E ele criará uma máquina virtual com archlinux no nosso virtualbox.

OBS: Esse comando pode demorar um pouco pois ele vai baixar um hd virtual do archlinux e instalar no seu virtualbox.

### Configurando duas máquinas virtuais

O ansible só oferece suporte para ser executado no linux. Ele pode até configurar máquinas windows, porém só pode ser disparado por uma máquina linux. Para evitar sujar seu ambiente ou mesmo caso você use windows como seu sistema operacional principal. Vamos configurar duas máquinas virtuais com linux.

Para isso, só precisamos alterar nosso `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
  end

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/focal64"
  end

end
```

Com isso, agora temos uma vm com ubuntu e outra com archlinux.

Para dar start nas vms agora podemos fazer de duas formas. Subir uma só ou as duas

Para subir as duas, podemos usar `vagrant up` como fizemos antes.

Caso queira subir só o ubuntu `vagrant up ubuntu` ou para subir somente o arch `vagrant up arch`.

### Configurações adicionais no Vagrant

Algumas configurações adicionais para simplificar a criação das nossas máquinas virtuais.

### IP Local
Se quisermos conseguir acessar as vms de fora do ambiente precisamos dar um endereço para elas usando nossa rede local, pelo protocolo DHCP. Podemos fazer isso alterando o `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
	arch.vm.network "public_network",
                	use_dhcp_assigned_default_route: true
  end

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/focal64"
	ubuntu.vm.network "public_network",
                      use_dhcp_assigned_default_route: true
  end

end
```

Isso criará uma nova placa de rede na vm e permitirá o acesso via ssh dá nossa máquina local.

Para que essas ações passem a valer nas máquinas, precisamos pedir ao vagrant que refaça a configuração delas.

```bash
vagrant reload
```

> Quando executar esse passo, caso você tenha mais de uma placa de rede, por exemplo um notebook, ele vai perguntar em qual placa você quer que o dhcp seja usado. Escolha a sua placa conectada a internet.


#### Configurações de memória e HD das vms

Caso tenha alguns problemas relativos a uso de memória ou disco, essas configurações podem te ajudar.

#### Memória RAM
Caso você tenha um hardware mais modesto e deseja que as vms usem menos memória. ou que sabe tenha mais hardware e deseja que sua vm tenha mais memória. Você pode alterar a quantidade da vm no `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
	arch.vm.network "public_network",
                	use_dhcp_assigned_default_route: true

    arch.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

  end

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/focal64"
	ubuntu.vm.network "public_network",
                      use_dhcp_assigned_default_route: true

    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

  end

end
```

Nesse caso, todas as máquinas agora tem 1GB de memória. Você pode alterar para suas necessidades.

Para aplicar, usamos novamente o comando `vagrant reload`

#### Alterando o tamanho dos HDs

Caso o disco esteja menor do que você precisa e não consiga performar algumas ações por falta de espaço no disco, você pode instalar o plugin `vagrant-disksize`. Para que ele faça a modificação no tamanho do disco:

```bash
vagrant plugin install vagrant-disksize
```

Agora você pode alterar o tamanho do disco da vm no `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
	arch.disksize.size = "30GB"  # Linha que muda o tamanho do disco, só precisa dela

# O resto do arquivo foi omitido
```

Para aplicar, usamos novamente o comando `vagrant reload`

## Configuração do nosso laboratório

#### Faça o clone desse repositório

- Clone o repositório do lab: `git clone git@github.com:dunossauro/ansible-lab.git`

- Navegue até o diretório do lab: `cd ansible-lab`


##### Linux
- Inicie as máquinas com vagrant: `vagrant up`

##### Windows

No diretório existem dois arquivos de configuração do vagrant. O padrão `Vagrantfile` para ser executado no linux e um específico para windows `Vagrantfile.windows`.

Para subir no windows você deve configurar a variável de ambiente para subir o ambiente windows.

Caso esteja usando o cmd:

```
set VAGRANT_VAGRANTFILE=Vagrantfile.windows
```

Caso esteja usando o powershell:

```
Set-Variable -Name VAGRANT_VAGRANTFILE -Value "Vagrantfile.windows"
```

Agora você pode iniciar o vagrant:

```
vagrant up
```


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
$ vagrant ssh centos -c "ip -4 -brief address show"
lo               UNKNOWN        127.0.0.1/8 
eth0             UP             10.0.2.15/24 
eth1             UP             192.168.15.86/24 

$ vagrant ssh ubuntu -c "ip -4 -brief address show"
lo               UNKNOWN        127.0.0.1/8 
enp0s3           UP             10.0.2.15/24 
enp0s8           UP             192.168.15.85/24 

$ vagrant ssh arch -c "ip -4 -brief address show"
lo               UNKNOWN        127.0.0.1/8 
eth0             UP             10.0.2.15/24 metric 1024 
eth1             UP             192.168.15.83/24 metric 1024 
```

Queremos o ip externo da rede local `192.168.15.???`. Repita esse passo para as outras vms.

Os meus ips foram os seguintes:

- Arch: 192.168.15.83
- Centos: 192.168.15.86
- Ubuntu: 192.168.15.85

Guarde esses ips pois vamos usar eles no ansible


### Informações importantes

Tanto o usuário das vms quanto a senha delas é `vagrant`.
