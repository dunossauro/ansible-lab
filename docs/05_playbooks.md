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
ansible-playbook playbooks/web_server.yml

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


## Variáveis

### Uso de variáveis

Para isso, podemos trocar o nome do pacote do pipx no playbook para uma variável:

```yaml title="pipx_httpie.yml" linenums="6"
    - name: Instalação do pipx
      become: yes
      package:
        name: "{{ pipx }}"
        state: present
```

E dessa forma podemos invocar o playbook passando uma variável para a chave `"{{ pipx }}"`:


```bash title="$ Execução no terminal"
ansible-playbook playbooks/pipx_httpie.yml --extra-vars "pipx=pipx"
```
