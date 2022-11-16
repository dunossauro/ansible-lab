# Ansible Galaxy

Como vimos o nome Ansible vem da história do `mundo de Rocannon` na história de Ursula K. Le Guin. Rocannon é um antropólogo que precisa se comunicar com outros planetas usando o Ansible.

O Ansible Galaxy é uma forma de compartilhar receitas com outras pessoas usando Ansible. Você pode acessar o Galaxy nesse [link](https://galaxy.ansible.com/)

![](./images/galaxy.png)

Existem diversas receitas e módulos prontos e feitos pela comunidade que podemos explorar e instalar em nosso nó controlador para automatizar tarefas de forma mais eficiente.

## Instalando um módulo

Uma coisa que gosto bastante no meu ambiente pessoal é de instalar diversas versões do python. Isso me ajuda a trabalhar melhor e testar código em diversas versões do python. O Ansible, porém, não conta com um módulo nativo para lidar como o [pyenv](https://github.com/pyenv/pyenv) que é um instalador de versões do python.

Para isso, podemos contar com o Galaxy. Uma pessoa da comunidade criou um pacote para gerenciar o [pyenv](https://galaxy.ansible.com/staticdev/pyenv).

Para instalar esse módulo temos que o usar o comando `ansible-galaxy`:

```bash title="$ Execução no terminal"
ansible-galaxy install staticdev.pyenv
```

> `staticdev` é o nome do perfil da pessoa que criou o pacote para o galaxy

```bash title="Resposta do terminal"
Starting galaxy role install process
- downloading role 'pyenv', owned by staticdev
- downloading role from https://github.com/staticdev/ansible-role-pyenv/archive/2.6.2.tar.gz
- extracting staticdev.pyenv to /home/vagrant/.ansible/roles/staticdev.pyenv
- staticdev.pyenv (2.6.2) was installed successfully
```


## Usando o módulo

TODO

## requirements de módulos

TODO
