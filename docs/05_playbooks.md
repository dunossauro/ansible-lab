# Playbooks

Tudo que executamos até agora foram comandos no terminal com ansible. Você deve estar se perguntando se não seria mais fácil criar um script com todos esses comandos, para evitar ter que digitar todas as vezes. Para isso existem os playbooks. Você cria um arquivo no formato [yaml](https://yaml.org/) descrevendo todas as suas tarefas e executa de uma única vez.

!!! tip "O nome Playbook"
    Playbook é uma palavra que se refere a scripts de teatro. Por exemplo, quando alguém entra em cena, as falas de cada personagem e etc...

	No mundo dos esportes playbook é usado muito no baseball e no basket. São listas de jogadas que podem ser feitas durante um jogo.

## Arquivos YAML

Arquivos YAML são arquivos geralmente usados para configurações. Se pensarmos em Python, eles formam estruturas equivalentes a de dicionários. Uma comparação básica para você entender o formato:

=== "YAML"

	```yaml linenums="1"
	---
	chave: valor      # valor é uma string
	chave_int: 1      # valor é uma int
	chave_bool: true  # valor é uma bool

	uma_lista:
	  - item_0
	  - item_1
	  - item_2

	um_dict:
	  nome: eduardo
	  idade: 29

	# Comentários

	lista_inline: ['item_0', 'item_1', 'item_2']

	dict_inline: {'nome': 'eduardo', 'idade': 29}
	```

=== "Python"

	```python linenums="1"
	{
		"chave": "valor",
		"chave_int": 1,
		"chave_bool": true,
		"uma_lista": [
			"item_0",
			"item_1",
			"item_2"
		],
		"um_dict":  {
			"nome": "eduardo",
			"idade": 29
		},
		"lista_inline": [
			"item_0",
			"item_1",
			"item_2"
		],
		"dict_inline": {
			"nome": "eduardo",
			"idade": 29
		}
	}
	```

## Nosso primeiro playbook

Vamos reproduzir a instalação e configuração do Ngix que fizemos via comandos `ad-hoc` no terminal:

```yaml linenums="1" title="web_server.yml"
---
- name: Instalação do nginx
  hosts: linux   # Grupo de hosts do inventário
  become: yes    # Diz que vai escalonar privilégios. Equivalente ao {==-b==}

  tasks:  # Descrição das tarefas que serão executadas

    - name: Instalação do nginx  # Nome da tarefa
      package:                   # Nome do módulo
        # Argumentos do módulo
        state: present
        name: nginx

    - name: Inicialização do nginx
      systemd:
        state: started
        name: nginx
```

Dessa forma, no lugar de executar um único comando por vez, podemos disparar um playbook que executa diversas tarefas por vez:

```bash title="$ Execução no terminal"
ansible-playbook web_server.yml
```

Você deve ver uma grande resposta como essa:

```bash title="resposta do terminal"
ansible-playbook web_server.yml

PLAY [Instalação do nginx] *****************************************************

TASK [Gathering Facts] *********************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]

TASK [Instalação do nginx] *****************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]

TASK [Inicialização do nginx] **************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]

PLAY RECAP *********************************************************************
10.0.2.15   : ok=3  changed=0  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
10.0.2.16   : ok=3  changed=0  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

O que significa que o ansible conseguiu executar o playbook com sucesso.

## Mais um playbook

Sei que você já deve ter captado a ideia do playbook, mas que tal criarmos mais um? Vamos tentar reproduzir a configuração do emacs no localhost agora. Pois temos outros módulos e outros comandos para aprender:

```yaml linenums="1" title="emacs.yml"
---
- name: Instalação e configuração do emacs
  hosts: localhost  # Aqui mudamos para o localhost

  tasks:
    - name: Instalação do emacs

      become: yes  # Diferente da outra config, somente esse passo será como root

      package:
        state: present
        name: emacs

    - name: Instalação do git
      become: yes
      package:
        name: git
        state: present

    - name: Clone do nosso repositório
      git:
        repo: https://github.com/dunossauro/dotfiles.git
        dest: config_files

    - name: Movendo os arquivos de configuração do emacs
      copy:
        dest: /home/vagrant/
        src: /home/vagrant/config_files/.emacs.d
```

Se executarmos esse playbook podemos ver algumas mensagens diferentes na resposta:

```bash title="$ Execução no terminal"
ansible-playbook emacs.yml
```

A resposta:

```bash title="resposta do terminal"
PLAY [Instalação e configuração do emacs] **************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Instalação do emacs] *****************************************************
ok: [localhost]

TASK [Instalação do git] *******************************************************
ok: [localhost]

TASK [Clone do nosso repositório] **********************************************
{==changed==}: [localhost]

TASK [Movendo os arquivos de configuração do emacs] ****************************
{==changed==}: [localhost]

PLAY RECAP *********************************************************************
localhost  : ok=5  {==changed=2==}  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```
O status `changed` apareceu. Significa que o resultado desse comando foi diferente da primeira vez que foi executado. O que quer dizer que alguma coisa mudou desde a ultima execução.

Provavelmente a resposta do ansible foi diferente pois o clone não foi feito, o diretório já existia e o move também já tinha sido feito antes.

## Condicionais

Vamos recapitular mais uma coisa que já instalamos no nosso ambiente. O `pipx` e o `httpie`. Não são pacotes tão relevantes para o andamento do tutorial, mas precisamos aprender coisas legais com ansible antes de fazer coisas realmente úteis.

O pacote do `pipx` existe no repositório do `archlinux` como já vimos. O pacote se chama `python-pipx`. Vamos iniciar um playbook para essa instalação e ver os problemas que vamos encontrar no caminho:

```yaml title="pipx_httpie.yml" linenums="1"
---
- name: Instalação do pipx e httpie
  hosts: linux  # vale lembrar aqui que um dos linux é o arch e o outro o ubuntu

  tasks:
    - name: Instalação do pipx
      become: yes
      package:
        name: python-pipx
        state: present
```

Vamos executar para ver o que conseguimos com isso:

```bash title="$ Execução no terminal"
ansible-playbook pipx_httpie.yml
```

Obteremos a seguinte resposta:

```
PLAY [Instalação do pipx e httpie] *********************************************

TASK [Gathering Facts] *********************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]

TASK [Instalação do pipx] ******************************************************
{==fatal: [10.0.2.15]: FAILED! => {"changed": false, "msg": "No package matching 'python-pipx' is available"}==}
changed: [10.0.2.16]

PLAY RECAP *********************************************************************
10.0.2.15  : ok=1  changed=0  unreachable=0  failed=1  skipped=0  rescued=0  ignored=0
10.0.2.16  : ok=2  changed=1  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

Repare na linha destacada. A máquina associada ao ip `10.2.2.15` não tem um pacote no repositório chamado `python-pipx`. Esse foi o motivo da falha. O pacote existe no repositório do arch, porém não existe no repositório do ubuntu.

Para resolver esse problema precisamos descobrir o nome do pacote no [repositório do ubuntu](https://packages.ubuntu.com/). E para saber isso precisamos saber qual a versão do ubuntu estamos usando. Você deve se lembrar que escrever no Vagrantfile `ubuntu/focal64`. Então, sabemos que a versão é a `focal`. Porém, se não soubéssemos essa informação. Como o ansible poderia nos ajudar a descobrir?

### O módulo setup

O Ansible conta com um módulo chamado [setup](https://docs.ansible.com/ansible/2.7/modules/setup_module.html#setup-module). Esse módulo pode ser chamado via ad-hoc, mas também é a base para algumas variáveis nos playbooks. Primeiro vamos executar via ad-hoc:

```bash title="$ Execução no terminal"
ansible ubuntu -m setup
```

Esse comando nos retornará uma resposta MUITO extensa. Que acabei deixando em um arquivo separado. Você pode acessar [aqui](https://github.com/dunossauro/ansible-lab/blob/main/stuff/resposta_ubuntu_setup.txt). Vamos destacar somente algumas coisas que fazem sentido para nosso passo atual:

```json linenums="344"
"ansible_distribution": "Ubuntu",
"ansible_distribution_file_parsed": true,
"ansible_distribution_file_path": "/etc/os-release",
"ansible_distribution_file_variety": "Debian",
"ansible_distribution_major_version": "20",
"ansible_distribution_release": "focal",
"ansible_distribution_version": "20.04",
```

Podemos ver que o ansible sabe qual a distribuição que está sendo usada `Ubuntu`, qual a versão do sistema `20.04` e a release que está sendo executada `focal`. O `setup` consegue mostrar diversos outros dados. Sobre as interfaces de rede, sobre memória e etc...

Aproveitando que já estamos vendo o módulo `setup`, podemos usar a função de filtro do módulo para exibir somente as informações que precisamos. Qualquer coisa que comece com `ansible_distribution`:


```bash title="$ Execução no terminal"
ansible ubuntu -m setup -a "filter=ansible_distribution*"
```

Que nos retornará os mesmos dados que destaquei:

```
10.0.2.15 | SUCCESS => {
    "ansible_facts": {
        "ansible_distribution": "Ubuntu",
        "ansible_distribution_file_parsed": true,
        "ansible_distribution_file_path": "/etc/os-release",
        "ansible_distribution_file_variety": "Debian",
        "ansible_distribution_major_version": "20",
        "ansible_distribution_release": "focal",
        "ansible_distribution_version": "20.04",
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false
}
```

Agora que sabemos que é o Ubuntu Focal, podemos voltar ao repositório. O pacote existe, porém, com outro nome [pipx](https://packages.ubuntu.com/focal/python/pipx).

### A clausula `when`

Como disse, as variáveis do setup podem ser invocadas dentro do playbook. Dessa forma podemos criar validações condicionais no nosso playbook. Vamos criar uma restrição para que a task seja executada somente no arch linux:

```yaml title="pipx_httpie.yml" linenums="1"
---
- name: Instalação do pipx e httpie
  hosts: linux  # vale lembrar aqui que um dos linux é o arch e o outro o ubuntu

  tasks:
    - name: Instalação do pipx {++no Arch++}
      become: yes
      package:
        name: python-pipx
        state: present
      {++when++}: {++ansible_distribution == Archlinux'++}
```

> As linhas destacadas mostra somente as alterações que fizemos no playbook.

Dessa forma, a task `Instalação do pipx no Arch` só será executada quando a distribuição for `Archlinux`. Vamos testar:

```bash title="$ Execução no terminal"
ansible-playbook pipx_httpie.yml
```

```bash title="Resultado do shell"

PLAY [Instalação do pipx e httpie] ********************************************************

TASK [Gathering Facts] ********************************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]

TASK [Instalação do pipx no Arch] *********************************************************
{==skipping: [10.0.2.15]==}
ok: [10.0.2.16]

PLAY RECAP ********************************************************************************
10.0.2.16  : ok=2  changed=0  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0 
10.0.2.15  : ok=1  changed=0  unreachable=0  failed=0  {==skipped=1==}  rescued=0  ignored=0
```

Com isso, podemos ver o status `skipped`. Isso quer dizer que o passo de instalar no arch, quando passou pela instalação no ubuntu "pulou" esse passo. Sabendo disso, podemos criar uma nova task específica para o ubuntu que pule no arch também:

```yaml title="pipx_httpie.yml" linenums="13"
    - name: Instalação do pipx no Ubuntu
      become: yes
      package:
        name: pipx
        state: present
      when: ansible_distribution == 'Ubuntu'
```

Dessa forma, quando executarmos o playbook teremos certeza que a execução vai acontecer nos dois nós. Mesmo que em tasks diferentes.

```bash title="$ Execução no terminal e a parte importante do resultado"
ansible-playbook pipx_httpie.yml

TASK [Instalação do pipx no Arch] *********************************************************
skipping: [10.0.2.15]
ok: [10.0.2.16]

TASK [Instalação do pipx no Ubuntu] *******************************************************
skipping: [10.0.2.16]
ok: [10.0.2.15]
```

Desta forma não precisamos mais nos preocupar com os pacotes específicos de cada sistema, podemos criar uma task para cada sistema. Em casos extremos isso pode ser necessário. Mas será que não existe uma forma mais simples de resolver esse problema?

## Expressões e variáveis

Quando chamamos o setup, vimos que o ansible consegue carregar diversas variáveis durante a execução. Mas será que nesse caso não conseguiríamos criar uma variável nossa? Aí poderíamos validar antes e evitar de escrever duas tasks.

### Expressões

O Ansible usa um motor de templates chamado [Jinja](https://palletsprojects.com/p/jinja/). O jinja fornece uma forma de chamar expressões de código Python dentro de templates. Assim, quando o ansible executa um playbook ele também avalia e executa as expressões do jinja dentro do código.

As expressões no jinja são feitas usando duas chaves delimitador `{{ minha_expressão }}`. E dentre dessa expressão, qualquer código python pode ser inserido. Por exemplo, podemos fazer um `if` para resolver nosso caso e ter uma única task. Por exemplo:

```yaml title="pipx_httpie.yml" linenums="5"
  tasks:
    - name: Instalação do pipx
      become: yes
      package:
        name: {++"{{ 'pipx' if ansible_distribution == 'Ubuntu' else 'python-pipx'}}"++}
        state: present
```

!!! note "Nota sobre expressões no Asnbile"
	Embora para o jinja somente precise ser usado `{{ expressão }}`. O Ansible exige que esses blocos estejam também entre aspas. Ficando `'{{ expressão }}'`.
	
Desta forma acabamos resolvendo o problema que tínhamos em ter duas tasks para executar a mesma tarefa em sistemas diferentes. Vamos ver o resultado:

```bash title="$ Execução no terminal e a parte importante do resultado"
ansible-playbook pipx_httpie.yml

TASK [Instalação do pipx no Arch] *********************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]
```

Assim podemos ser mais eficientes em criar regras. Já o que template pode estender código python.

### As variáveis no ansible

Da mesma forma que podemos criar expressões complexas no jinja. Também podemos chamar somente variáveis. Por exemplo `"{{ variavel }}"`. Assim podemos declarar as expressões em um lugar específico do playbook para deixar mais limpo ou passar as mesmas via linha de comando.

### Variáveis no playbook

Para isso, podemos trocar o nome do pacote do pipx no playbook para uma variável:

```yaml title="pipx_httpie.yml" linenums="1"
---
- name: Instalação do pipx e httpie
  hosts: linux

  {++vars++}:
    {++pipx++}: {++"{{ 'pipx' if ansible_distribution == 'Ubuntu' else 'python-pipx'}}"++}

  tasks:
    - name: Instalação do pipx
      become: yes
      package:
        name: {++'{{ pipx }}'++}
        state: present
```

Assim temos um playbook mais limpo. Pois todo o código complicado do jinja fica em um lugar específico e no topo do arquivo para ficar fácil a consulta.

> Não vou executar esse playbook agora, pois teremos o mesmo resultado da execução anterior.

### Variáveis via linha de comando

Outra funcionalidade importante do ansible é conseguir sobrescrever as variáveis de um playbook usando a linha de comando como base. Chamar via linha de comando tem uma ordem de precedência maior que as variáveis definidas no playbook. Então, quando o ansible for chamado as variáveis definidas no campo `vars` serão substituídas pelas variáveis que forem passadas na linha de comando:

```bash title="$ Execução no terminal e a parte importante do resultado"
ansible-playbook pipx_httpie.yml --extra-vars "pipx=pipx"

TASK [Instalação do pipx] *****************************************************************
ok: [10.0.2.15]
fatal: [10.0.2.16]: FAILED! => {=={"changed": false, "cmd": ["/usr/bin/pacman", "--upgrade", "--print-format", "%n", "pipx"], "msg": "Failed to list package pipx", "rc": 1, "stderr": "error: 'pipx': could not find or read package\n", "stderr_lines": ["error: 'pipx': could not find or read package"], "stdout": "loading packages...\n", "stdout_lines": ["loading packages..."]}==}
```

Como era de se esperar, o pacote `pipx` não existe no arch, seu nome é `python-pipx` por conta disso, o comando não foi executado com sucesso. Nosso objetivo, porém, era explorar a chamada de variáveis via linha de comando.

### Arquivos de variáveis

Uma forma de evitar expressões do jinja e também chamar variáveis por linha de comando é criar um arquivo só para as variáveis. Dessa forma, caso tenha alguma variável que não possa ser exposta, como endereço de um banco de dados. Esse valores ficam de fora da configuração.


```yaml title="variaveis.yml" linenums="1"
---
pipx: "{{ 'pipx' if ansible_distribution == 'Ubuntu' else 'python-pipx'}}"
```

Dessa forma podemos limpar o nosso arquivo `pipx_httpie.yml`:

```yaml title="pipx_httpie.yml" linenums="1" hl_lines="9"
---
- name: Instalação do pipx e httpie
  hosts: linux

  tasks:
    - name: Instalação do pipx
      become: yes
      package:
        name: '{{ pipx }}'
        state: present
```

E quando formos executar o playbook, só precisamos passar o arquivo de configuração para as variáveis:

```bash title="$ Execução no terminal e a parte importante do resultado"
ansible-playbook pipx_httpie.yml -e @variaveis.yml

TASK [Instalação do pipx] *****************************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]
```

Assim demos uma limpada no nosso arquivo de playbook e claro, podemos definir diversas outras variáveis no arquivo. Mas, você pode tentar depois :heart:


### Arquivos de variáveis por grupo

Uma outra coisa que pode facilitar na hora de usar as variáveis é criar variáveis específicas para grupos. O ansible tem um caminho específico para onde esses arquivos de variáveis devem ser colocados: `/etc/ansible/group_vars/`.

Para resolver isso, vamos criar um grupo de variáveis para o ubuntu:

```yaml title="/etc/ansible/group_vars/ubuntu.yml" linenums="1"
---
pipx: pipx
```

e um arquivo para o arch:
```yaml title="/etc/ansible/group_vars/arch.yml" linenums="1"
---
pipx: python-pipx
```

Dessa forma, quando formos executar o playbook não precisamos mais especificar as variáveis comuns. Cada sistema tem sua versão de `pipx` de acordo com os grupos do inventário:


```bash title="$ Execução no terminal e a parte importante do resultado"
ansible-playbook pipx_httpie.yml

TASK [Instalação do pipx] *****************************************************************
ok: [10.0.2.15]
ok: [10.0.2.16]
```
