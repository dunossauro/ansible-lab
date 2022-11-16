# Tasks

Embora tenhamos usados tasks em praticamente tudo até aqui. Acredito que valha um momento específico para falar sobre elas. Pois nem sempre as coisas dão certo e as vezes precisamos debugar as tarefas no Ansible. Então nessa parte vamos falar um pouco sobre tasks, um pouco sobre debug e um pouco sobre agrupamento de tasks.


## Uma task qualquer

Para exemplificar uma task, quero fazer com vocês a instalação do pyenv. Costuma dar bastante problema pois o SSH usado pelo Ansible não consegue reconhecer o `.bashrc`

Para começar, vamos instalar o git e fazer o clone do pyenv:

```yaml title="config_python.yml" linenums="1"
---
- name: Configuração do ambiente python
  hosts: linux

  tasks:
    - name: Install git
      become: yes
      package:
        name: git
        state: present

    - name: Clone Pyenv
      git:
        repo: https://github.com/pyenv/pyenv.git
        dest: ~/.pyenv
```

Porém, a configuração do pyenv depende de que o arquivo `./bashrc` seja modificado para que o pyenv funcione de fato. Então agora vamos aprender mais um módulo. O módulo [blockinfile](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html). Ele permite que adicionemos um cloco de texto em um arquivo qualquer:

```yaml title="config_python.yml" linenums="17"
    - name: config pyenv
      blockinfile:
        dest: ~/.bashrc
        block: |
          echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
          echo 'eval "$(pyenv init -)"' >>~/.bashrc
          echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
          echo 'PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

## Register

Vamos supor que queremos checar o que está escrito dentro do arquivo `.bashrc` para saber se ele está escrito da maneira correta. Para isso vamos criar mais uma task. Para isso vamos usar o módulo `shell` e também a funcionalidade de registro em variáveis do ansible:

```yaml title="config_python.yml" linenums="27"
    - name: Show bashrc
      shell: cat ~/.bashrc
      register: bashrc
```

Dessa forma, por termos chamado `register` o ansible vai armazenar o resultado da tarefa `Show bashrc` na variável `bashrc`. E podemos acessar ela usando o módulo de `debug`:

```yaml title="config_python.yml" linenums="30"
    - name: Checking bashrc
      debug:
        msg: "{{ bashrc.stdout.split('\n') }}"
```

Quando o playbook for executado, nos mostrará de maneira formatada o `stdout` da tarefa `Show bashrc`:

```bash title="$ Execução no terminal e a parte importante do resultado"
ansible-playbook config_python.yml

TASK [Show bashrc] *******************************************************************************
changed: [IP]

TASK [Checking bashrc] ********************************************************************
ok: [IP] => {
    "msg": [
        "#",
        "# ~/.bashrc",
        "#",
        "",
        "# If not running interactively, don't do anything",
        "[[ $- != *i* ]] && return",
        "",
        "alias ls='ls --color=auto'",
        "PS1='[\\u@\\h \\W]\\$ '",
        "# BEGIN ANSIBLE MANAGED BLOCK",
        "echo 'export PATH=\"$HOME/.pyenv/bin:$PATH\"' >> ~/.bashrc",
        "echo 'eval \"$(pyenv init -)\"' >>~/.bashrc",
        "echo 'eval \"$(pyenv virtualenv-init -)\"' >> ~/.bashrc",
        "echo 'PATH=\"$HOME/.local/bin:$PATH\"' >> ~/.bashrc",
        "# END ANSIBLE MANAGED BLOCK"
    ]
}
```

O que significa que conseguimos chamar o debug. Porém em alguns momentos as tasks podem e vão dar errado. Então precisamos entender como prosseguir, caso isso aconteça.

## Debug de tasks

Vamos executar uma ação que tenho certeza que vai dar erro por conta das configurações que fizemos até agora para entender como podemos checar as mensagens de erro.

Em teoria, se temos o pyenv instalado, podemos pedir para que ele instale a versão `3.11` do python:

```yaml title="config_python.yml" linenums="34"
    {==- block==}:
        - name: install python3.11
          shell: pyenv install -s 3.11:latest
          register: pyenv_result
```

Note que inseri um bloco no playbook chamado `block`. Ele nos ajuda a executar uma tarefa na sequência caso uma delas dê erro. E para isso vamos adicionar um parâmetro para esse bloco chamado `rescue`. Ficando com esse bloco:

```yaml title="config_python.yml" linenums="34"
    - block:
        - name: install python3.11
          shell: pyenv install -s 3.11:latest
          register: pyenv_result
      rescue:
        - name: Debug pyenv fail
          debug:
            msg: "{{pyenv_result.stderr.split('\n') }}"
          when: pyenv_result.failed
```

> `rescue` pode ser traduzido como resgatar ou salvar.

Dessa forma, caso alguma de nossas instalações do python 3.11 dê erro. Ele vai nos mostrar de forma formatada e simples o que aconteceu nessa execução:

```bash title="$ Execução no terminal e a parte importante do resultado"
ansible-playbook config_python.yml

TASK [install python3.11] *****************************************************************
fatal: [IP ARCH]: FAILED! => {"changed": true, "cmd": "~/.pyenv/bin/pyenv install -s 3.11:latest", "delta": "0:00:03.326569", "end": "2022-11-16 16:03:38.101843", "msg": "non-zero return code", "rc": 1, "start": "2022-11-16 16:03:34.775274", "stderr": "Downloading Python-3.11.0.tar.xz...\n-> https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz\nInstalling Python-3.11.0...\n\nBUILD FAILED (Ubuntu 20.04 using python-build 2.3.6-13-g4c261e6e)\n\nInspect or clean up the working tree at /tmp/python-build.20221116160334.6412\nResults logged to /tmp/python-build.20221116160334.6412.log\n\nLast 10 log lines:\nchecking for pkg-config... no\nchecking for --enable-universalsdk... no\nchecking for --with-universal-archs... no\nchecking MACHDEP... \"linux\"\nchecking for gcc... no\nchecking for cc... no\nchecking for cl.exe... no\nconfigure: error: in `/tmp/python-build.20221116160334.6412/Python-3.11.0':\nconfigure: error: no acceptable C compiler found in $PATH\nSee `config.log' for more details", "stderr_lines": ["Downloading Python-3.11.0.tar.xz...", "-> https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz", "Installing Python-3.11.0...", "", "BUILD FAILED (Ubuntu 20.04 using python-build 2.3.6-13-g4c261e6e)", "", "Inspect or clean up the working tree at /tmp/python-build.20221116160334.6412", "Results logged to /tmp/python-build.20221116160334.6412.log", "", "Last 10 log lines:", "checking for pkg-config... no", "checking for --enable-universalsdk... no", "checking for --with-universal-archs... no", "checking MACHDEP... \"linux\"", "checking for gcc... no", "checking for cc... no", "checking for cl.exe... no", "configure: error: in `/tmp/python-build.20221116160334.6412/Python-3.11.0':", "configure: error: no acceptable C compiler found in $PATH", "See `config.log' for more details"], "stdout": "", "stdout_lines": []}
fatal: [IP UBUNTU]: FAILED! => {"changed": true, "cmd": "~/.pyenv/bin/pyenv install -s 3.11:latest", "delta": "0:00:04.143002", "end": "2022-11-16 16:03:38.885921", "msg": "non-zero return code", "rc": 1, "start": "2022-11-16 16:03:34.742919", "stderr": "Downloading Python-3.11.0.tar.xz...\n-> https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz\nInstalling Python-3.11.0...\n\nBUILD FAILED (Arch Linux using python-build 2.3.6-13-g4c261e6e)\n\nInspect or clean up the working tree at /tmp/python-build.20221116160335.2683\nResults logged to /tmp/python-build.20221116160335.2683.log\n\nLast 10 log lines:\nchecking for pkg-config... no\nchecking for --enable-universalsdk... no\nchecking for --with-universal-archs... no\nchecking MACHDEP... \"linux\"\nchecking for gcc... no\nchecking for cc... no\nchecking for cl.exe... no\nconfigure: error: in `/tmp/python-build.20221116160335.2683/Python-3.11.0':\nconfigure: error: no acceptable C compiler found in $PATH\nSee `config.log' for more details", "stderr_lines": ["Downloading Python-3.11.0.tar.xz...", "-> https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz", "Installing Python-3.11.0...", "", "BUILD FAILED (Arch Linux using python-build 2.3.6-13-g4c261e6e)", "", "Inspect or clean up the working tree at /tmp/python-build.20221116160335.2683", "Results logged to /tmp/python-build.20221116160335.2683.log", "", "Last 10 log lines:", "checking for pkg-config... no", "checking for --enable-universalsdk... no", "checking for --with-universal-archs... no", "checking MACHDEP... \"linux\"", "checking for gcc... no", "checking for cc... no", "checking for cl.exe... no", "configure: error: in `/tmp/python-build.20221116160335.2683/Python-3.11.0':", "configure: error: no acceptable C compiler found in $PATH", "See `config.log' for more details"], "stdout": "", "stdout_lines": []}

TASK [Debug pyenv fail] *******************************************************************
ok: [IP ARCH] => {
    "msg": [
        "Downloading Python-3.11.0.tar.xz...",
        "-> https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz",
        "Installing Python-3.11.0...",
        "",
        "BUILD FAILED (Arch Linux using python-build 2.3.6-13-g4c261e6e)",
        "",
        "Inspect or clean up the working tree at /tmp/python-build.20221116160335.2683",
        "Results logged to /tmp/python-build.20221116160335.2683.log",
        "",
        "Last 10 log lines:",
        "checking for pkg-config... no",
        "checking for --enable-universalsdk... no",
        "checking for --with-universal-archs... no",
        "checking MACHDEP... \"linux\"",
        "checking for gcc... no",
        "checking for cc... no",
        "checking for cl.exe... no",
        "configure: error: in `/tmp/python-build.20221116160335.2683/Python-3.11.0':",
        "configure: error: no acceptable C compiler found in $PATH",
        "See `config.log' for more details"
    ]
}
ok: [IP UBUNTU] => {
    "msg": [
        "Downloading Python-3.11.0.tar.xz...",
        "-> https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz",
        "Installing Python-3.11.0...",
        "",
        "BUILD FAILED (Ubuntu 20.04 using python-build 2.3.6-13-g4c261e6e)",
        "",
        "Inspect or clean up the working tree at /tmp/python-build.20221116160334.6412",
        "Results logged to /tmp/python-build.20221116160334.6412.log",
        "",
        "Last 10 log lines:",
        "checking for pkg-config... no",
        "checking for --enable-universalsdk... no",
        "checking for --with-universal-archs... no",
        "checking MACHDEP... \"linux\"",
        "checking for gcc... no",
        "checking for cc... no",
        "checking for cl.exe... no",
        "configure: error: in `/tmp/python-build.20221116160334.6412/Python-3.11.0':",
        "configure: error: no acceptable C compiler found in $PATH",
        "See `config.log' for more details"
    ]
}
```

Com isso, conseguimos escapar do erro grande da task `install python3.11` e ficamos com um erro fácil de ser lido na task `Debug pyenv fail`.


Nas duas respostas temos o mesmo erro. Não existe um compilador instalado. Então precisamos instalar os pacotes necessários para que o pyenv consiga fazer a compilação. Elas estão listadas [aqui](https://github.com/pyenv/pyenv/wiki#suggested-build-environment) e separadas por sistema operacional. Bora criar mais duas tasks para garantir que tudo funcione.

Aproveitando que vamos fazer tasks condicionais. Vou aproveitar para usar os gerenciadores específicos das distribuições para simplificar o processo. Para os pacotes do ubuntu, vamos usar o módulo do [apt](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html) e para o arch vamos usar o módulo do [pacman](https://docs.ansible.com/ansible/latest/collections/community/general/pacman_module.html):

```yaml title="config_python.yml" linenums="17"
    - name: Install build dependencies (ubuntu)
      when: ansible_distribution == 'Ubuntu'
      become: yes
      apt:
        update_cache: yes
        pkg:
          - make
          - build-essential
          - libssl-dev
          - zlib1g-dev
          - libbz2-dev
          - libreadline-dev
          - libsqlite3-dev
          - wget
          - curl
          - llvm
          - libncursesw5-dev
          - xz-utils
          - tk-dev
          - libxml2-dev
          - libxmlsec1-dev
          - libffi-dev
          - liblzma-dev

    - name: Install build dependencies (arch)
      when: ansible_distribution == 'Archlinux'
      become: yes
      pacman:
        update_cache: yes
        name:
          - base-devel
          - openssl
          - zlib
          - xz
          - tk
```

> Por contar com a instalação de muitos pacotes, pode demorar um pouco


## Agrupamento de tasks

TODO
