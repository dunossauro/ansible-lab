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

```yaml linenums="1"
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
