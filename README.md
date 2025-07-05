# Sistema de Gerenciamento de Produtos em Assembly x86

Este projeto implementa um sistema de cadastro, busca e remoção de produtos em Assembly x86 (32 bits), utilizando listas encadeadas e persistência em arquivo binário.

## Funcionalidades

- **Adicionar produto:** Permite inserir produtos com nome, lote, tipo, validade, fornecedor, quantidade, valor de compra e venda.
- **Buscar produto:** Permite buscar produtos pelo nome e exibir seus dados.
- **Remover produto:** Permite remover produtos pelo nome e lote.
- **Persistência:** Os produtos são salvos em `produtos.bin` e carregados automaticamente ao iniciar o programa.
- **Menu interativo:** Interface de texto para navegação entre as opções.

## Estrutura do Produto

Cada produto possui os seguintes campos:
- Ponteiro para o próximo nó (lista encadeada)
- Tipo (int)
- Quantidade (int)
- Valor de compra (int, em centavos)
- Valor de venda (int, em centavos)
- Nome (50 bytes)
- Lote (4 bytes)
- Data de validade (11 bytes)
- Fornecedor (11 bytes)

## Dependências

Para compilar com `-m32`, é necessário ter o GCC com suporte a 32 bits instalado.  
No Ubuntu/Debian, instale com:

```sh
sudo apt-get install gcc-multilib libc6-dev-i386
```

## Como compilar e executar

Você pode compilar e executar o programa de duas formas:

### Usando o GCC diretamente

```sh
gcc -m32 -no-pie -o supermercado supermercado.s
./supermercado
```

### Usando o Makefile

O projeto inclui um Makefile para facilitar a compilação e execução:

- Para compilar:  
  ```sh
  make
  ```
- Para rodar o programa:  
  ```sh
  make run
  ```
- Para limpar arquivos gerados (`supermercado` e `produtos.bin`):  
  ```sh
  make clean
  ```

## Observações

- O programa utiliza chamadas da libc (`printf`, `scanf`, `fgets`, etc).
- O arquivo de dados é salvo como `produtos.bin` no mesmo diretório.
- O código está todo em Assembly x86 (32 bits), compatível com Linux.

## Organização do Código

- **add_product_interactive:** Adiciona um produto via entrada do usuário.
- **search_product_interactive:** Busca produtos pelo nome.
- **remove_product_interactive:** Remove produtos pelo nome e lote.
- **save_list / load_list:** Salva e carrega a lista de produtos do arquivo binário.
- **print_product:** Exibe os dados de um produto.
- **display_menu:** Mostra o menu principal e lê a escolha do usuário.

## Autor

Trabalho acadêmico para disciplina de PROGR. INTERFAC. HARDWARE E SOFTWARE.