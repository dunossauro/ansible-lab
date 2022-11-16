# Configuração do ambiente

A minha ideia principal com esse tutorial é não depender de nenhum serviço de nuvem. Nem todas as pessoas podem pagar ou tem cartão de crédito para poder inserir mesmo nos planos gratuitos.

Para não depender de serviços externos, vamos usar máquinas virtuais com [virtualbox](https://www.virtualbox.org/) e vamos configurá-las usando [Vagrant](https://www.vagrantup.com/).


Logo, a primeira coisa que precisamos fazer é configurar o nosso host para instalação das máquinas virtuais. Para isso, precisamos instalar o `virtualbox` e o `vagrant`.


## Instalação do virtualbox

[Virtualbox](https://www.virtualbox.org/) é um software para criação de máquinas virtuais. E ele pode ser instalado em qualquer plataforma comum do mercado. Como Windows, Linux e MacOS.

> Caso você use o windows, as instalações podem ser feitas via [chocolatey](https://chocolatey.org/install#individual)

Você pode fazer o [download](https://www.virtualbox.org/wiki/Downloads) e instalar ou instalar usando o seu gerenciador de pacotes usando seu terminal preferido:

```bash
paru -S virtualbox                # Arch
choco install virtualbox          # Windows
sudo apt-get install virtualbox   # Ubuntu
```

## Instalação do vagrant

[Vagrant](https://www.vagrantup.com/) é um software de código aberto, escrito em [Ruby](https://www.ruby-lang.org/pt/) para construir ambientes de desenvolvimento usando um arquivo de configuração. Que pode ser reproduzido por qualquer pessoa que tenha acesso ao arquivo.

Abra seu terminal preferido e faça a instalação:

```bash
paru -S vagrant           # Arch
choco install vagrant     # Windows
sudo apt install vagrant  # Ubuntu
```
