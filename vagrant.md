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
paru -S vagrant           # Arch
choco install vagrant     # Windows
sudo apt install vagrant  # Ubuntu
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

#### IP Local
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

#### Dando start nos sistemas atualizados

Um passo importante, para criarmos nosso ambiente é que ele já comece atualizado. Para não perdemos tempo atualizando o sistema logo de início. Para isso só temos que alterar no `Vagrantfile` para executar uma ação de provisionamento no shell:

```ruby
    <SO>.vm.provision "shell", inline: <<-SHELL
	  <NOSSOS COMANDOS>
    SHELL
```

Os comandos variam de sistema para sistema. O Archlinux usa o `pacman` como gerenciador de pacote, os sistemas baseados em Debian o `apt`, os sistemas da família red hat usam `dnf`. Então, lembre-se de usar o comando certo para atualizar. Um exemplo do nosso `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
    arch.disksize.size = "30GB"
    arch.vm.network "public_network",
                    use_dhcp_assigned_default_route: true

    arch.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    arch.vm.provision "shell", inline: <<-SHELL
      pacman -Syu --noconfirm
    SHELL
  end

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/focal64"
    ubuntu.vm.network "public_network",
                      use_dhcp_assigned_default_route: true

    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    ubuntu.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get upgrade -y
    SHELL
  end

end
```

Para que essas ações sejam performadas. Executamos `vagrant provision`

#### Configurações de SSH

Para que o ansible possa acessar de forma plena as máquinas virtuais, é sempre bom garantir que as máquinas virtuais estejam com o serviço de ssh configurado. Então, podemos adicionar essa configuração na fase de provisionamento do `Vagrantfile`:

```ruby
    <SO>.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      systemctl restart sshd
    SHELL
```

Assim, garantirmos que o ssh está devidamente configurado. Para executar o provisionamento novamente:

```bash
vagrant provision
```
