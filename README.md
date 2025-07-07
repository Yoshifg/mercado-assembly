# Sistema de Gerenciamento de Produtos em Assembly x86

Este projeto implementa um sistema de cadastro, busca, remoção e atualização de produtos em Assembly x86 (32 bits), utilizando listas encadeadas e persistência em arquivo binário.

## Funcionalidades

- **Adicionar produto:** Insere produtos com nome, lote, tipo, validade (dia, mês, ano), fornecedor, quantidade, valor de compra e venda.  
- **Buscar produto:** Busca produtos pelo nome e exibe seus dados.  
- **Remover produto:** Remove produtos pelo nome e lote.  
- **Atualizar produto:** Atualiza a quantidade ou o valor de venda de um produto já cadastrado.  
- **Consultas Financeiras:**  
  - Total gasto em compras  
  - Total estimado de vendas  
  - Lucro estimado (vendas − compras)  
  - Capital perdido (produtos vencidos)  
- **Relatório Ordenado:** Gera um arquivo de texto (`relatorio.txt`) com opção de ordenação por:  
  1. Nome (padrão)  
  2. Quantidade em estoque  
  3. Data de validade (mais antiga primeiro)  
- **Persistência:** Os produtos são salvos em `produtos.bin` e carregados automaticamente ao iniciar o programa.  
- **Lista pré-carregada:** O repositório inclui um `produtos.bin` com alguns itens já cadastrados para testes rápidos.  
- **Menu interativo:** Interface de texto para navegação entre as opções acima.

## Estrutura do Produto

Cada produto possui os seguintes campos:
- Ponteiro para o próximo nó (lista encadeada)
- Tipo (int)
- Quantidade (int)
- Valor de compra (int, em centavos)
- Valor de venda (int, em centavos)
- Nome (50 bytes)
- Lote (20 bytes)
- Data de validade:  
  - Dia (int)
  - Mês (int)
  - Ano (int)
- Fornecedor (50 bytes)

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
- **update_product_interactive:** Atualiza a quantidade ou valor de venda de um produto.
- **save_list / load_list:** Salva e carrega a lista de produtos do arquivo binário.
- **print_product:** Exibe os dados de um produto.
- **display_menu:** Mostra o menu principal e lê a escolha do usuário.
- **add_product_interactive**: Adiciona um produto via entrada do usuário.
- **search_product_interactive**: Busca produtos pelo nome.
- **remove_product_interactive**: Remove produtos pelo nome e lote.
- **update_product_interactive**: Atualiza a quantidade ou valor de venda de um produto.
- **finance_menu + total_compra, total_venda, lucro_total, capital_perdido, print_currency**: Exibem o menu financeiro e calculam valores em reais e centavos.
- **save_list / load_list**: Salvam e carregam a lista de produtos do arquivo binário.
- **generate_report + sort_by_quantity, sort_by_date, fill_node_array, count_nodes, print_product_to_file**: Geração de relatório em texto com ordenação personalizada.
- **print_product**: Exibe os dados de um produto no terminal.
- **display_menu / read_int / read_string_with_prompt / remove_newline**: Funções utilitárias para interface e leitura de dados.

## Autor

Trabalho acadêmico para disciplina de PROGR. INTERFAC. HARDWARE E SOFTWARE.