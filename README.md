# Laboratório para Live de Python sobre Ansible

O objetivo desse repositório é ajudar você a construir um laboratório para aprender Ansible. Aqui você vai encontrar dicas e passos para configurar suas máquinas virtuais para construir seu ambiente.

A minha ideia principal com essa live é não depender de nenhum serviço de nuvem. Nem todas as pessoas podem pagar ou tem cartão de crédito para poder inserir mesmo nos planos gratuitos.

Para não depender de serviços externos, vamos usar máquinas virtuais com [virtualbox](https://www.virtualbox.org/) e vamos configurá-las usando [Vagrant](https://www.vagrantup.com/).

## Sumário

- [Configuração do ambiente](#configuração-do-ambiente)
- [Criação da máquina virtual](#criação-da-máquina-virtual)
- [Destruindo a máquina criada](#destruindo-a-máquina-criada)
- [Configurando mais de uma máquina virtual](#configurando-mais-de-uma-máquina-virtual)
- [Ansible](#ansible)
  - [Instalação do Ansible](#instalação-do-ansible)

## Configuração do ambiente

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
paru -S vagrant           # Arch
choco install vagrant     # Windows
sudo apt install vagrant  # Ubuntu
```

## Criação da máquina virtual

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

Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'archlinux/archlinux'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'archlinux/archlinux' version '20221101.99038' is up to date...
==> default: Setting the name of the VM: ansible_lab_default_1668393945684_70462
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
    default: 
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default: 
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
==> default: Mounting shared folders...
    default: /vagrant => /home/z4r4tu5tr4/ansible_lab
```
E ele criará uma máquina virtual com archlinux no nosso virtualbox.

OBS: Esse comando pode demorar um pouco pois ele vai baixar um hd virtual do archlinux e instalar no seu virtualbox.

![](./images/virtualbox_01.png)

Agora que temos uma máquina virtual podemos partir para o segundo passo. Que é criar dois notes para trabalhar com ansible.

### Destruindo a máquina criada

O vagrant pode destruir de forma simples a vm e é isso que faremos agora.

```bash
vagrant destroy
```

Com isso podemos ter nosso ambiente limpo outra vez.
![](./images/virtualbox_02.png)

## Configurando mais de uma máquina virtual

Agora que entendemos a dinâmica de criação de vms do vagrant, podemos configurar duas máquinas para o ansible. Uma que vamos chamar de `main` que será de onde chamaremos o ansible e uma que será controlada por ele. Que se chamará somente `arch`.

Para isso, só precisamos alterar nosso `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "main" do |main|
    main.vm.box = "archlinux/archlinux"
  end

  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
  end

end
```

Agora temos duas máquinas virtuais. Ambas configuradas com archlinux. Porém cada uma tem uma função diferente na nossa rede.

O vagrant pode subir uma única vm ou as duas de uma vez:

```bash
vagrant up        # Inicia as duas vms
vagrant up arch   # Somente a máquina arch
vagrant up main   # Somente a máquina main (vamos escolher essa opção)
```

## Ansible

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

Agora podemos rodar o comando para instalar o ansible:

```bash
sudo pacman -S ansible
```
