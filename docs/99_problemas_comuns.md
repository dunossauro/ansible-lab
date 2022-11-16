# Alguns problemas que podem acontecer

## Sem espaço no disco

Caso seu disco fique sem espaço, você pode mudar a configuração do Vagrantile para aumentar o tamanho do disco

```ruby hl_lines="4"
  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"

	arch.disksize.size = "30GB"

    arch.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
```

O Vagrant, porém, não consegue executar essa tarefa. Para que isso seja feito, você precisa instalar uma extensão no Vagrant:

```bash title="$ Execução no terminal"
vagrant plugin install vagrant-disksize
```

Em seguida, você pode reiniciar a vm:

```bash title="$ Execução no terminal"
vagrant reload <máquina>
```
