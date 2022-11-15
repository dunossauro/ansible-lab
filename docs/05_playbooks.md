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
