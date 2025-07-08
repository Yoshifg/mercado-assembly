.section .note.GNU-stack,"",@progbits

/*===============================================================================================
|                                                                                                |
|                  SUPERMERCADO.S  –  Gerenciamento de produtos em lista ligada                  |
|                                                                                                |
|  Seções:                                                                                       |
|    .data – Strings, formatos, menus e tabelas estáticas                                        |
|    .bss  – Buffers e variáveis não inicializadas (estado)                                      |
|    .text – Código executável (funções e main)                                                  |
|                                                                                                |
|  Principais Funções:                                                                           |
|    load_list               – carrega lista do arquivo binário (produtos.bin)                   |
|    save_list               – persiste lista em arquivo binário                                 |
|    add_product_interactive – adiciona produto lendo do terminal                                |
|    search/remove/update    – operações CRUD via interface interativa                           |
|    finance_menu            – submenu financeiro (total compra, venda, lucro, capital perdido)  |
|    generate_report         – gera relatório texto (ordenado ou padrão)                         |
|    utilitários             – read_int, read_string_with_prompt, remove_newline, memcpy         |
|                                                                                                |
===============================================================================================*/




/*===============================================================================================
|                                                                                                |
|                Seção .data – Strings, formatos, menus e tabela de tipos                        |
|                                                                                                |
===============================================================================================*/

.section .data
    //=== Lista e arquivos ===
    head: .int 0
    filename:         .asciz "produtos.bin"
    report_filename:  .asciz "relatorio.txt"
    modo_escrita:     .asciz "wb"
    modo_leitura:     .asciz "rb"
    modo_escrita_txt: .asciz "w"
    
    //=== Templates de formatação genéricos ===
    fmt_nome:   .asciz "Nome: %s\n"
    fmt_lote:   .asciz "Lote: %s\n"
    fmt_tipo:   .asciz "Tipo: %d\n"
    fmt_data:   .asciz "Validade: %02d/%02d/%04d\n"
    fmt_fornec: .asciz "Fornecedor: %s\n"
    fmt_quant:  .asciz "Quantidade: %d\n"
    fmt_compra: .asciz "Compra: %d.%02d\n"
    fmt_venda:  .asciz "Venda: %d.%02d\n"
    fmt_div:    .asciz "----------------\n"

    //=== Menu principal ===
    menu:        .asciz "\n===== MENU =====\n1. Adicionar produto\n2. Buscar produto\n3. Remover produto\n4. Atualizar produto\n5. Consultas Financeiras\n6. Gerar relatório\n7. Sair\nEscolha: "
    str_escolha: .asciz "%d"

    //=== Prompts de entrada interativa ===
    str_nome_prompt:           .asciz "Digite o nome do produto: "
    str_lote_prompt:           .asciz "Digite o lote: "
    str_tipo_prompt:           .asciz "Tipos:\n 01. Alimento\n 02. Limpeza\n 03. Utensílios\n 04. Bebidas\n 05. Frios\n 06. Padaria\n 07. Carnes\n 08. Higiene\n 09. Bebês\n 10. Pet\n 11. Congelados\n 12. Hortifruti\n 13. Eletronicos\n 14. Vestuário\n 15. Outros\nDigite o tipo (1-15): "
    str_dia_prompt:            .asciz "Digite o dia da validade: "
    str_mes_prompt:            .asciz "Digite o mês da validade: "
    str_ano_prompt:            .asciz "Digite o ano da validade: "
    str_fornec_prompt:         .asciz "Digite o fornecedor: "
    str_quant_prompt:          .asciz "Digite a quantidade: "
    str_compra_prompt:         .asciz "Digite o valor de compra (centavos): "
    str_venda_prompt:          .asciz "Digite o valor de venda (centavos): "
    str_busca_prompt:          .asciz "Digite o nome para buscar: "
    str_remove_prompt:         .asciz "Digite o nome do produto a remover: "
    str_remove_lote_prompt:    .asciz "Digite o lote do produto a remover: "
    str_update_prompt:         .asciz "Digite o nome do produto a atualizar: "
    str_update_lote_prompt:    .asciz "Digite o lote do produto a atualizar: "
    str_update_campo:          .asciz "Qual campo deseja atualizar?\n1. Quantidade\n2. Valor de venda\nEscolha: "
    str_nova_quant:            .asciz "Digite a nova quantidade: "
    str_nova_venda:            .asciz "Digite o novo valor de venda (centavos): "
    str_invalido:              .asciz "Opção inválida!\n"
    str_saindo:                .asciz "Saindo...\n"
    str_malloc_fail:           .asciz "Falha ao alocar memoria!\n"
    str_remove_success:        .asciz "Produto removido com sucesso!\n"
    str_remove_fail:           .asciz "Produto não encontrado para remoção!\n"
    str_update_success:        .asciz "Produto atualizado com sucesso!\n"
    str_update_fail:           .asciz "Produto não encontrado para atualização!\n"
    str_update_campo_invalido: .asciz "Campo inválido!\n"

    //=== Consultas financeiras ===
    menu_financeiro:     .asciz "\n===== CONSULTAS FINANCEIRAS =====\n1. Total de compra\n2. Total de venda\n3. Lucro total\n4. Capital perdido\n5. Voltar\nEscolha: "
    fmt_total_compra:    .asciz "Total gasto em compras: %d.%02d\n"
    fmt_total_venda:     .asciz "Total estimado de vendas: %d.%02d\n"
    fmt_lucro:           .asciz "Lucro estimado: %d.%02d\n"
    fmt_capital_perdido: .asciz "Capital perdido: %d.%02d\n"
    str_dia_atual:       .asciz "Digite o dia atual: "
    str_mes_atual:       .asciz "Digite o mês atual: "
    str_ano_atual:       .asciz "Digite o ano atual: "
    str_aguarde:         .asciz "Calculando...\n"
    
    //=== Mensagens de relatório ===
    str_report_success:        .asciz "Relatório gerado com sucesso em relatorio.txt\n"
    str_report_fail:           .asciz "Erro ao gerar relatório!\n"
    str_report_order_prompt:   .asciz "Ordenar por:\n1. Nome (padrão)\n2. Quantidade em estoque\n3. Data de validade (mais antiga primeiro)\nEscolha: "
    str_report_order_invalido: .asciz "Opção inválida! Usando ordenação padrão.\n"
    fmt_tipo_str:              .asciz "Tipo: %s\n"

    //=== Tipos de produto ===
    .align 4
    tipos_ptr:
        .long tipos_str0
        .long tipos_str1
        .long tipos_str2
        .long tipos_str3
        .long tipos_str4
        .long tipos_str5
        .long tipos_str6
        .long tipos_str7
        .long tipos_str8
        .long tipos_str9
        .long tipos_str10
        .long tipos_str11
        .long tipos_str12
        .long tipos_str13
        .long tipos_str14

    tipos_str0:  .asciz "Alimento"
    tipos_str1:  .asciz "Limpeza"
    tipos_str2:  .asciz "Utensilios"
    tipos_str3:  .asciz "Bebidas"
    tipos_str4:  .asciz "Frios"
    tipos_str5:  .asciz "Padaria"
    tipos_str6:  .asciz "Carnes"
    tipos_str7:  .asciz "Higiene"
    tipos_str8:  .asciz "Bebes"
    tipos_str9:  .asciz "Pet"
    tipos_str10: .asciz "Congelados"
    tipos_str11: .asciz "Hortifruti"
    tipos_str12: .asciz "Eletronicos"
    tipos_str13: .asciz "Vestuario"
    tipos_str14: .asciz "Outros"

//=== Tamanho do nó ===
.set dados_size, 148     #  | Nome (50) | Lote (20) | Tipo (4) | Dia (4) | Mês (4) | Ano (4) | Fornecedor (50) | Quantidade (4) | Compra (4) | Venda (4) | => 148 bytes
.set produto_size, 152   #  dados_size + 4 bytes do próximo nó => 152 bytes




/*===============================================================================================
|                                                                                                |
|                Seção .bss – Buffers e variáveis de estado (não inicializadas)                  |
|                                                                                                |
===============================================================================================*/

.section .bss
    .lcomm buffer,    148    # buffer temporário para leitura/gravação de dados binários
    .lcomm nome_busca, 50    # buffer para armazenar o nome em busca/remoção/atualização
    .lcomm lote_busca, 20    # buffer para armazenar o lote em busca/remoção/atualização
    .lcomm dia_atual,   4    # inteiro para dia atual (usado em capital perdido)
    .lcomm mes_atual,   4    # inteiro para mês atual (usado em capital perdido)
    .lcomm ano_atual,   4    # inteiro para ano atual (usado em capital perdido)
    .lcomm node_array,  4    # ponteiro para array de nós na geração de relatório ordenado
    .lcomm node_count,  4    # número de nós (tamanho de node_array)





/*===============================================================================================
|                                                                                                |
|                            Seção .text – Funções executáveis                                   |
|                                                                                                |
===============================================================================================*/

.section .text
    .extern malloc, free, fopen, fclose, fread, fwrite, printf, strcmp, strcpy, scanf, fgets, stdin, getchar, strncmp, fprintf

/* --------------------------------------------------------|
| SEÇÃO: GERENCIAMENTO DA LISTA                            |
| Funções de inserção, carregamento e gravação da lista    |
|---------------------------------------------------------*/
.section .text
    .globl insert_sorted, save_list, load_list
insert_sorted:
    pushl %ebp
    movl  %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    movl 8(%ebp), %ebx
    movl head, %edi
    xorl %esi, %esi

    testl %edi, %edi
    jz insert_empty
    
insertion_loop:
    leal 20(%ebx), %eax
    leal 20(%edi), %ecx
    
    pushl %ecx
    pushl %eax
    call strcmp
    addl $8, %esp
    
    cmpl $0, %eax
    jle insert_here
    
    movl %edi, %esi
    movl (%edi), %edi
    
    testl %edi, %edi
    jnz insertion_loop
    
    movl %ebx, (%esi)
    movl $0, (%ebx)
    jmp insert_done

insert_here:
    testl %esi, %esi
    jz insert_front
    
    movl %ebx, (%esi)
    movl %edi, (%ebx)
    jmp insert_done

insert_front:
    movl head, %ecx
    movl %ecx, (%ebx)
    movl %ebx, head
    jmp insert_done

insert_empty:
    movl %ebx, head
    movl $0, (%ebx)

insert_done:
    popl %edi
    popl %esi
    popl %ebx
    leave
    ret

save_list:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    
    pushl $modo_escrita
    pushl $filename
    call fopen
    addl $8, %esp
    movl %eax, %ebx
    
    testl %ebx, %ebx
    jz save_done
    
    movl head, %esi
save_loop:
    testl %esi, %esi
    jz close_save
    
    leal 4(%esi), %eax
    pushl $dados_size
    pushl %eax
    pushl $buffer
    call memcpy
    addl $12, %esp
    
    pushl %ebx
    pushl $dados_size
    pushl $1
    pushl $buffer
    call fwrite
    addl $16, %esp
    
    movl (%esi), %esi
    jmp save_loop
    
close_save:
    pushl %ebx
    call fclose
    addl $4, %esp
    
save_done:
    popl %esi
    popl %ebx
    leave
    ret

load_list:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    
    pushl $modo_leitura
    pushl $filename
    call fopen
    addl $8, %esp
    movl %eax, %ebx
    
    testl %ebx, %ebx
    jz load_done
    
load_loop:
    pushl %ebx
    pushl $dados_size
    pushl $1
    pushl $buffer
    call fread
    addl $16, %esp
    
    cmpl $dados_size, %eax
    jne close_load
    
    pushl $produto_size
    call malloc
    addl $4, %esp
    testl %eax, %eax
    jz close_load
    
    movl $0, (%eax)
    leal 4(%eax), %edi
    
    pushl $dados_size
    pushl $buffer
    pushl %edi
    call memcpy
    addl $12, %esp
    
    pushl %eax
    call insert_sorted
    addl $4, %esp
    
    jmp load_loop
    
close_load:
    pushl %ebx
    call fclose
    addl $4, %esp
    
load_done:
    popl %esi
    popl %ebx
    leave
    ret

/* --------------------------------------------------------|
| Section: Product I/O                                     |
| print_product, search_product, leitura interativa        |
|---------------------------------------------------------*/
    .globl print_product, search_product
print_product:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl 8(%ebp), %ebx
    
    leal 20(%ebx), %eax
    pushl %eax
    pushl $fmt_nome
    call printf
    addl $8, %esp
    
    leal 70(%ebx), %eax
    pushl %eax
    pushl $fmt_lote
    call printf
    addl $8, %esp
    
    movl 4(%ebx), %eax             # pega o campo 'tipo' (1–15)
    decl %eax                      # ajusta para índice 0–14
    movl tipos_ptr(,%eax,4), %ecx  # carrega ponteiro para a string
    pushl %ecx
    pushl $fmt_tipo_str
    call printf
    addl $8, %esp
    
    movl 98(%ebx), %eax
    movl 94(%ebx), %ecx
    movl 90(%ebx), %edx
    pushl %eax
    pushl %ecx
    pushl %edx
    pushl $fmt_data
    call printf
    addl $16, %esp
    
    leal 102(%ebx), %eax
    pushl %eax
    pushl $fmt_fornec
    call printf
    addl $8, %esp
    
    movl 8(%ebx), %eax
    pushl %eax
    pushl $fmt_quant
    call printf
    addl $8, %esp
    
    movl 12(%ebx), %eax
    xorl %edx, %edx
    movl $100, %ecx
    divl %ecx
    pushl %edx
    pushl %eax
    pushl $fmt_compra
    call printf
    addl $12, %esp
    
    movl 16(%ebx), %eax
    xorl %edx, %edx
    movl $100, %ecx
    divl %ecx
    pushl %edx
    pushl %eax
    pushl $fmt_venda
    call printf
    addl $12, %esp
    
    pushl $fmt_div
    call printf
    addl $4, %esp
    
    popl %ebx
    leave
    ret

search_product:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    
    movl 8(%ebp), %esi
    movl head, %ebx
    
search_loop:
    testl %ebx, %ebx
    jz search_done
    
    leal 20(%ebx), %eax
    pushl %esi
    pushl %eax
    call strcmp
    addl $8, %esp
    
    testl %eax, %eax
    jnz next_product
    
    pushl %ebx
    call print_product
    addl $4, %esp
    
next_product:
    movl (%ebx), %ebx
    jmp search_loop
    
search_done:
    popl %esi
    popl %ebx
    leave
    ret

read_int:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp
    
    leal -4(%ebp), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    movl -4(%ebp), %eax
    leave
    ret

clear_input_buffer:
    pushl %ebp
    movl %esp, %ebp
clear_loop:
    call getchar
    cmpl $10, %eax
    je clear_done
    cmpl $-1, %eax
    jne clear_loop
clear_done:
    leave
    ret

read_string_with_prompt:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    movl 8(%ebp), %eax
    pushl %eax
    call printf
    addl $4, %esp
    movl 12(%ebp), %ebx
    pushl stdin
    pushl $50
    pushl %ebx
    call fgets
    addl $12, %esp
    pushl %ebx
    call remove_newline
    addl $4, %esp
    popl %ebx
    leave
    ret

remove_newline:
    pushl %ebp
    movl %esp, %ebp
    pushl %edi
    movl 8(%ebp), %edi
rn_loop:
    movb (%edi), %al
    testb %al, %al
    jz rn_end
    cmpb $10, %al
    je rn_found
    incl %edi
    jmp rn_loop
rn_found:
    movb $0, (%edi)
rn_end:
    popl %edi
    leave
    ret

/* --------------------------------------------------------|
| Section: Interactive CRUD Handlers                       |
| add/search/remove/update product                         |
|---------------------------------------------------------*/
    .globl add_product_interactive, search_product_interactive
    .globl remove_product_interactive, update_product_interactive
add_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl $produto_size
    call malloc
    addl $4, %esp
    testl %eax, %eax
    jz add_product_fail
    movl %eax, %ebx
    movl $0, (%ebx)
    leal 20(%ebx), %eax
    pushl %eax
    pushl $str_nome_prompt
    call read_string_with_prompt
    addl $8, %esp
    leal 70(%ebx), %eax
    pushl %eax
    pushl $str_lote_prompt
    call read_string_with_prompt
    addl $8, %esp
    pushl $str_tipo_prompt
    call  printf
    addl  $4, %esp
    leal  4(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call  scanf
    addl  $8, %esp
    call  clear_input_buffer
    pushl $str_dia_prompt
    call  printf
    addl  $4, %esp
    leal  90(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call  scanf
    addl  $8, %esp
    call  clear_input_buffer
    pushl $str_mes_prompt
    call printf
    addl $4, %esp
    leal 94(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    pushl $str_ano_prompt
    call printf
    addl $4, %esp
    leal 98(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    leal 102(%ebx), %eax
    pushl %eax
    pushl $str_fornec_prompt
    call read_string_with_prompt
    addl $8, %esp
    pushl $str_quant_prompt
    call printf
    addl $4, %esp
    leal 8(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    pushl $str_compra_prompt
    call printf
    addl $4, %esp
    leal 12(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    pushl $str_venda_prompt
    call printf
    addl $4, %esp
    leal 16(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    pushl %ebx
    call insert_sorted
    addl $4, %esp
    jmp add_product_done
add_product_fail:
    pushl $str_malloc_fail
    call printf
    addl $4, %esp
add_product_done:
    popl %ebx
    leave
    ret

search_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    subl $52, %esp
    pushl $str_busca_prompt
    call printf
    addl $4, %esp
    leal -50(%ebp), %eax
    pushl stdin
    pushl $50
    pushl %eax
    call fgets
    addl $12, %esp
    leal -50(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    leal -50(%ebp), %eax
    pushl %eax
    call search_product
    addl $4, %esp
    leave
    ret

remove_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    subl $72, %esp
    pushl $str_remove_prompt
    call printf
    addl $4, %esp
    leal -50(%ebp), %eax
    pushl stdin
    pushl $50
    pushl %eax
    call fgets
    addl $12, %esp
    leal -50(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    pushl $str_remove_lote_prompt
    call printf
    addl $4, %esp
    leal -70(%ebp), %eax
    pushl stdin
    pushl $20
    pushl %eax
    call fgets
    addl $12, %esp
    leal -70(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    movl head, %ebx
    xorl %esi, %esi
remove_search_loop:
    testl %ebx, %ebx
    jz remove_not_found
    leal 20(%ebx), %eax
    leal -50(%ebp), %ecx
    pushl %ecx
    pushl %eax
    call strcmp
    addl $8, %esp
    testl %eax, %eax
    jnz next_remove_search
    leal 70(%ebx), %eax
    leal -70(%ebp), %ecx
    pushl $20
    pushl %ecx
    pushl %eax
    call strncmp
    addl $12, %esp
    testl %eax, %eax
    jz found_to_remove
next_remove_search:
    movl %ebx, %esi
    movl (%ebx), %ebx
    jmp remove_search_loop
found_to_remove:
    testl %esi, %esi
    jz remove_first
    movl (%ebx), %eax
    movl %eax, (%esi)
    jmp free_node
remove_first:
    movl (%ebx), %eax
    movl %eax, head
free_node:
    pushl %ebx
    call free
    addl $4, %esp
    pushl $str_remove_success
    call printf
    addl $4, %esp
    jmp remove_done
remove_not_found:
    pushl $str_remove_fail
    call printf
    addl $4, %esp
remove_done:
    leave
    ret

update_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    subl $72, %esp
    pushl $str_update_prompt
    call printf
    addl $4, %esp
    leal -50(%ebp), %eax
    pushl stdin
    pushl $50
    pushl %eax
    call fgets
    addl $12, %esp
    leal -50(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    pushl $str_update_lote_prompt
    call printf
    addl $4, %esp
    leal -70(%ebp), %eax
    pushl stdin
    pushl $20
    pushl %eax
    call fgets
    addl $12, %esp
    leal -70(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    movl head, %ebx
update_search_loop:
    testl %ebx, %ebx
    jz update_not_found
    leal 20(%ebx), %eax
    leal -50(%ebp), %ecx
    pushl %ecx
    pushl %eax
    call strcmp
    addl $8, %esp
    testl %eax, %eax
    jnz next_update_search
    leal 70(%ebx), %eax
    leal -70(%ebp), %ecx
    pushl $20
    pushl %ecx
    pushl %eax
    call strncmp
    addl $12, %esp
    testl %eax, %eax
    jz found_to_update
next_update_search:
    movl (%ebx), %ebx
    jmp update_search_loop
found_to_update:
    pushl $str_update_campo
    call printf
    addl $4, %esp
    call read_int
    cmpl $1, %eax
    je update_quantidade
    cmpl $2, %eax
    je update_venda
    pushl $str_update_campo_invalido
    call printf
    addl $4, %esp
    jmp update_done
update_quantidade:
    pushl $str_nova_quant
    call printf
    addl $4, %esp
    leal 8(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    jmp update_success
update_venda:
    pushl $str_nova_venda
    call printf
    addl $4, %esp
    leal 16(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
update_success:
    pushl $str_update_success
    call printf
    addl $4, %esp
    jmp update_done
update_not_found:
    pushl $str_update_fail
    call printf
    addl $4, %esp
update_done:
    leave
    ret

display_menu:
    pushl %ebp
    movl %esp, %ebp
    pushl $menu
    call printf
    addl $4, %esp
    call read_int
    leave
    ret

// ============================================
// Section: Report Generation
// count_nodes, fill_node_array, sorts, print_product_to_file, generate_report
// ============================================
    .globl count_nodes, fill_node_array
    .globl sort_by_quantity, sort_by_date, print_product_to_file, generate_report
count_nodes:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl head, %ebx
    xorl %eax, %eax  # Contador
    
count_loop:
    testl %ebx, %ebx
    jz count_done
    incl %eax
    movl (%ebx), %ebx
    jmp count_loop
    
count_done:
    popl %ebx
    leave
    ret

# Função: Preencher array com ponteiros para nós
# Argumentos: endereço do array, número de nós
fill_node_array:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    movl head, %ebx
    movl 8(%ebp), %esi  # Array
    movl 12(%ebp), %ecx # Contador
    
fill_loop:
    testl %ecx, %ecx
    jz fill_done
    movl %ebx, (%esi)
    addl $4, %esi
    movl (%ebx), %ebx
    decl %ecx
    jmp fill_loop
    
fill_done:
    popl %edi
    popl %esi
    popl %ebx
    leave
    ret

# Função: Ordenar array por quantidade (bubble sort)
sort_by_quantity:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    pushl %edx
    
    movl 8(%ebp), %esi      # Array
    movl 12(%ebp), %ecx     # n
    decl %ecx               # n-1
    jle sort_done           # Se n <= 1, não precisa ordenar
    
    xorl %edi, %edi         # i = 0
    
outer_loop:
    cmpl %ecx, %edi
    jge sort_done
    
    movl %ecx, %edx         # j_limite = n-1-i
    subl %edi, %edx
    
    xorl %ebx, %ebx         # j = 0
    
inner_loop:
    cmpl %edx, %ebx
    jge inner_done
    
    # Carregar ponteiros
    movl (%esi, %ebx, 4), %eax  # node[j]
    movl 4(%esi, %ebx, 4), %ecx # node[j+1]
    
    # Comparar quantidades
    movl 8(%eax), %eax      # quantidade[j]
    movl 8(%ecx), %ecx      # quantidade[j+1]
    
    cmpl %ecx, %eax
    jge no_swap
    
    # Trocar ponteiros
    movl (%esi, %ebx, 4), %eax
    movl 4(%esi, %ebx, 4), %ecx
    movl %ecx, (%esi, %ebx, 4)
    movl %eax, 4(%esi, %ebx, 4)
    
no_swap:
    incl %ebx
    movl 12(%ebp), %ecx     # Restaurar ecx (n original)
    decl %ecx               # n-1
    jmp inner_loop
    
inner_done:
    incl %edi
    jmp outer_loop
    
sort_done:
    popl %edx
    popl %edi
    popl %esi
    popl %ebx
    leave
    ret

# =============================================
# FUNÇÃO: ORDENAR POR DATA
# =============================================

# Função auxiliar: Comparar datas de dois nós
# Entrada: dois ponteiros para nós
# Saída: eax = -1 se nó1 < nó2, 0 se igual, 1 se nó1 > nó2
compare_nodes_by_date:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    movl 8(%ebp), %eax   # nó1
    movl 12(%ebp), %ecx  # nó2

    # Extrair data do nó1
    movl 90(%eax), %edx   # dia1
    movl 94(%eax), %ebx   # mes1
    movl 98(%eax), %esi   # ano1

    # Extrair data do nó2
    movl 90(%ecx), %edi   # dia2
    movl 94(%ecx), %eax   # mes2
    movl 98(%ecx), %ecx   # ano2

    # Comparar anos
    cmpl %ecx, %esi
    jl node_date_less
    jg node_date_greater
    # Anos iguais, comparar meses
    cmpl %eax, %ebx
    jl node_date_less
    jg node_date_greater
    # Meses iguais, comparar dias
    cmpl %edi, %edx
    jl node_date_less
    jg node_date_greater
    # Datas iguais
    xorl %eax, %eax
    jmp compare_done

node_date_less:
    movl $-1, %eax
    jmp compare_done

node_date_greater:
    movl $1, %eax

compare_done:
    popl %edi
    popl %esi
    popl %ebx
    leave
    ret

# Função de ordenação por data (bubble sort)
sort_by_date:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    pushl %edx

    movl 8(%ebp), %esi      # Array
    movl 12(%ebp), %ecx     # n
    decl %ecx               # n-1
    jle sort_date_done      # Se n <= 1, não precisa ordenar

    xorl %edi, %edi         # i = 0

outer_loop_date:
    cmpl %ecx, %edi
    jge sort_date_done

    movl %ecx, %edx         # j_limite = n-1-i
    subl %edi, %edx

    xorl %ebx, %ebx         # j = 0

inner_loop_date:
    cmpl %edx, %ebx
    jge inner_done_date

    # Carregar ponteiros
    movl (%esi, %ebx, 4), %eax  # node[j]
    movl 4(%esi, %ebx, 4), %ecx # node[j+1]

    # Comparar datas
    pushl %ecx
    pushl %eax
    call compare_nodes_by_date
    addl $8, %esp

    # Se data[j] > data[j+1] (mais recente), trocar
    cmpl $1, %eax
    je swap_date

    jmp no_swap_date

swap_date:
    # Trocar ponteiros
    movl (%esi, %ebx, 4), %eax
    movl 4(%esi, %ebx, 4), %ecx
    movl %ecx, (%esi, %ebx, 4)
    movl %eax, 4(%esi, %ebx, 4)

no_swap_date:
    incl %ebx
    movl 12(%ebp), %edx     # Restaurar ecx (n original)
    subl %edi, %edx
    decl %edx               # n-1
    jmp inner_loop_date

inner_done_date:
    incl %edi
    jmp outer_loop_date

sort_date_done:
    popl %edx
    popl %edi
    popl %esi
    popl %ebx
    leave
    ret

# =============================================
# FUNÇÃO: IMPRIMIR PRODUTO EM ARQUIVO
# =============================================
print_product_to_file:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    movl 8(%ebp), %ebx   # nó
    movl 12(%ebp), %edi  # file handle

    # Escrever nome
    leal 20(%ebx), %eax
    pushl %eax
    pushl $fmt_nome
    pushl %edi
    call fprintf
    addl $12, %esp
    
    # Escrever lote
    leal 70(%ebx), %eax
    pushl %eax
    pushl $fmt_lote
    pushl %edi
    call fprintf
    addl $12, %esp
    
    # Escrever tipo
    movl 4(%ebx), %eax
    decl %eax
    movl tipos_ptr(,%eax,4), %ecx  # Carrega ponteiro para a string
    pushl %ecx
    pushl $fmt_tipo_str
    pushl %edi
    call fprintf
    addl $12, %esp
    
    # Escrever data
    movl 98(%ebx), %eax
    movl 94(%ebx), %ecx
    movl 90(%ebx), %edx
    pushl %eax
    pushl %ecx
    pushl %edx
    pushl $fmt_data
    pushl %edi
    call fprintf
    addl $20, %esp
    
    # Escrever fornecedor
    leal 102(%ebx), %eax
    pushl %eax
    pushl $fmt_fornec
    pushl %edi
    call fprintf
    addl $12, %esp
    
    # Escrever quantidade
    movl 8(%ebx), %eax
    pushl %eax
    pushl $fmt_quant
    pushl %edi
    call fprintf
    addl $12, %esp
    
    # Escrever valor de compra
    movl 12(%ebx), %eax
    xorl %edx, %edx
    movl $100, %ecx
    divl %ecx
    pushl %edx
    pushl %eax
    pushl $fmt_compra
    pushl %edi
    call fprintf
    addl $16, %esp
    
    # Escrever valor de venda
    movl 16(%ebx), %eax
    xorl %edx, %edx
    movl $100, %ecx
    divl %ecx
    pushl %edx
    pushl %eax
    pushl $fmt_venda
    pushl %edi
    call fprintf
    addl $16, %esp
    
    # Escrever divisor
    pushl $fmt_div
    pushl %edi
    call fprintf
    addl $8, %esp

    popl %edi
    popl %esi
    popl %ebx
    leave
    ret

# =============================================
# FUNÇÃO GERAR RELATÓRIO
# =============================================
generate_report:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    pushl %edx

    # Abrir arquivo de relatório
    pushl $modo_escrita_txt
    pushl $report_filename
    call fopen
    addl $8, %esp
    movl %eax, %edi        # EDI = file handle
    
    testl %edi, %edi
    jz generate_report_fail

    # Perguntar tipo de ordenação
    pushl $str_report_order_prompt
    call printf
    addl $4, %esp
    call read_int
    
    cmpl $2, %eax
    je quantity_order
    cmpl $3, %eax
    je date_order
    
    # Ordenação padrão (por nome)
    movl head, %esi        # ESI = current node
    jmp report_loop
    
quantity_order:
    # Ordenar por quantidade
    call count_nodes
    movl %eax, node_count
    testl %eax, %eax
    jz close_report
    
    # Alocar memória para array de ponteiros
    movl %eax, %ecx
    shll $2, %ecx          # n * 4 bytes
    pushl %ecx
    call malloc
    addl $4, %esp
    movl %eax, node_array
    testl %eax, %eax
    jz close_report
    
    # Preencher array
    pushl node_count
    pushl %eax
    call fill_node_array
    addl $8, %esp
    
    # Ordenar array por quantidade
    pushl node_count
    pushl node_array
    call sort_by_quantity
    addl $8, %esp
    
    jmp array_report_loop
    
date_order:
    # Ordenar por data de validade
    call count_nodes
    movl %eax, node_count
    testl %eax, %eax
    jz close_report
    
    # Alocar memória para array de ponteiros
    movl %eax, %ecx
    shll $2, %ecx
    pushl %ecx
    call malloc
    addl $4, %esp
    movl %eax, node_array
    testl %eax, %eax
    jz close_report
    
    # Preencher array
    pushl node_count
    pushl %eax
    call fill_node_array
    addl $8, %esp
    
    # Ordenar array por data
    pushl node_count
    pushl node_array
    call sort_by_date
    addl $8, %esp
    
array_report_loop:
    # Imprimir usando array ordenado
    movl node_array, %ebx
    movl node_count, %ecx
    
array_report_loop_inner:
    testl %ecx, %ecx
    jz array_report_done
    
    movl (%ebx), %eax      # Carregar nó
    
    # Escrever nó no arquivo
    pushl %ecx
    pushl %edi             # file handle
    pushl %eax             # nó
    call print_product_to_file
    addl $8, %esp
    popl %ecx
    
    addl $4, %ebx
    decl %ecx
    jmp array_report_loop_inner
    
array_report_done:
    # Liberar array
    pushl node_array
    call free
    addl $4, %esp
    jmp close_report
    
report_loop:
    testl %esi, %esi
    jz close_report
    
    # Escrever nó no arquivo
    pushl %edi             # file handle
    pushl %esi             # nó
    call print_product_to_file
    addl $8, %esp

    movl (%esi), %esi      # Avançar para próximo nó
    jmp report_loop
    
close_report:
    # Fechar arquivo
    pushl %edi
    call fclose
    addl $4, %esp
    
    pushl $str_report_success
    call printf
    addl $4, %esp
    
    jmp generate_report_done

generate_report_fail:
    pushl $str_report_fail
    call printf
    addl $4, %esp

generate_report_done:
    popl %edx
    popl %edi
    popl %esi
    popl %ebx
    leave
    ret

/*----------------------------------------------------------------------------------------|
| SEÇÃO: OPERAÇÕES FINANCEIRAS                                                            |
| total_compra, total_venda, lucro_total, capital_perdido, print_currency, finance_menu   |
|-----------------------------------------------------------------------------------------*/
    .globl total_compra, total_venda, lucro_total, capital_perdido
    .globl print_currency, finance_menu
total_compra:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    movl head, %ebx
    xorl %esi, %esi
compra_loop:
    testl %ebx, %ebx
    jz compra_done
    movl 8(%ebx), %eax      # Quantidade
    movl 12(%ebx), %edx     # Valor compra (centavos)
    imull %edx, %eax        # quantidade * valor_compra
    addl %eax, %esi         # Acumula
    movl (%ebx), %ebx       # Próximo nó
    jmp compra_loop
compra_done:
    movl %esi, %eax         # Retorna total em EAX
    popl %esi
    popl %ebx
    leave
    ret

total_venda:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    movl head, %ebx
    xorl %esi, %esi
venda_loop:
    testl %ebx, %ebx
    jz venda_done
    movl 8(%ebx), %eax      # Quantidade
    movl 16(%ebx), %edx     # Valor venda (centavos)
    imull %edx, %eax        # quantidade * valor_venda
    addl %eax, %esi         # Acumula
    movl (%ebx), %ebx       # Próximo nó
    jmp venda_loop
venda_done:
    movl %esi, %eax         # Retorna total em EAX
    popl %esi
    popl %ebx
    leave
    ret

lucro_total:
    pushl %ebp
    movl %esp, %ebp
    call total_venda
    pushl %eax
    call total_compra
    popl %edx
    subl %eax, %edx         # Lucro = venda - compra
    movl %edx, %eax         # Retorna lucro em EAX
    leave
    ret

compare_dates:
    pushl %ebp
    movl %esp, %ebp
    
    movl 16(%ebp), %eax     # ano_prod
    cmpl 28(%ebp), %eax     # Compara com ano_atual
    jl date_less
    jg date_greater
    
    movl 12(%ebp), %eax     # mes_prod
    cmpl 24(%ebp), %eax     # Compara com mes_atual
    jl date_less
    jg date_greater
    
    movl 8(%ebp), %eax      # dia_prod
    cmpl 20(%ebp), %eax     # Compara com dia_atual
    jl date_less
    jg date_greater
    
    xorl %eax, %eax        # Datas iguais
    jmp date_done

date_less:
    movl $-1, %eax
    jmp date_done

date_greater:
    movl $1, %eax

date_done:
    leave
    ret
    
capital_perdido:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    
    # Pedir data atual ao usuário
    pushl $str_dia_atual
    call printf
    addl $4, %esp
    leal dia_atual, %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    
    pushl $str_mes_atual
    call printf
    addl $4, %esp
    leal mes_atual, %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    
    pushl $str_ano_atual
    call printf
    addl $4, %esp
    leal ano_atual, %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    
    movl head, %ebx
    xorl %esi, %esi        # Acumulador = 0

capital_loop:
    testl %ebx, %ebx
    jz capital_done
    
    # Carregar data do produto
    movl 90(%ebx), %eax    # dia_prod
    movl 94(%ebx), %ecx    # mes_prod
    movl 98(%ebx), %edx    # ano_prod
    
    # Empilhar parâmetros para compare_dates
    pushl ano_atual
    pushl mes_atual
    pushl dia_atual
    pushl %edx             # ano_prod
    pushl %ecx             # mes_prod
    pushl %eax             # dia_prod
    call compare_dates
    addl $24, %esp         # Limpar parâmetros
    
    # Se data produto < data atual (vencido)
    cmpl $-1, %eax
    jne next_capital
    
    # Calcular perda: quantidade * valor_compra
    movl 8(%ebx), %eax     # quantidade
    movl 12(%ebx), %edx    # valor_compra
    imull %edx, %eax
    addl %eax, %esi        # Acumula perda

next_capital:
    movl (%ebx), %ebx      # Próximo nó
    jmp capital_loop

capital_done:
    movl %esi, %eax        # Retorna perda total em EAX
    popl %esi
    popl %ebx
    leave
    ret

# Função print_currency
# Entrada: valor em centavos (EAX), endereço do formato (EBX)
print_currency:
    pushl %ebp
    movl %esp, %ebp
    
    # Dividir valor por 100 para obter reais e centavos
    xorl %edx, %edx
    movl $100, %ecx
    divl %ecx              # EAX = reais, EDX = centavos
    
    # Empilhar para printf: formato, reais, centavos
    pushl %edx             # centavos
    pushl %eax             # reais
    pushl 8(%ebp)          # formato
    call printf
    addl $12, %esp
    
    leave
    ret

finance_menu:
    pushl %ebp
    movl %esp, %ebp

finance_loop:
    # Exibir menu financeiro
    pushl $menu_financeiro
    call printf
    addl $4, %esp
    
    # Ler escolha
    call read_int
    
    cmpl $1, %eax
    je fm_total_compra
    cmpl $2, %eax
    je fm_total_venda
    cmpl $3, %eax
    je fm_lucro
    cmpl $4, %eax
    je fm_capital_perdido
    cmpl $5, %eax
    je fm_done
    
    # Opção inválida
    pushl $str_invalido
    call printf
    addl $4, %esp
    jmp finance_loop

fm_total_compra:
    call total_compra
    pushl $fmt_total_compra
    call print_currency
    addl $4, %esp
    jmp finance_loop

fm_total_venda:
    call total_venda
    pushl $fmt_total_venda
    call print_currency
    addl $4, %esp
    jmp finance_loop

fm_lucro:
    call lucro_total
    pushl $fmt_lucro
    call print_currency
    addl $4, %esp
    jmp finance_loop

fm_capital_perdido:
    call capital_perdido
    pushl $fmt_capital_perdido
    call print_currency
    addl $4, %esp
    jmp finance_loop

fm_done:
    leave
    ret

/*===============================================================================================
|                                                                                                |
|                                            MAIN                                                |
|                                                                                                |
|  -> main, opções do menu principal e syscall de saída                                          |
===============================================================================================*/
    .globl main
main:
    call load_list

menu_loop:
    call display_menu
    
    cmpl $1, %eax
    je opcao1
    cmpl $2, %eax
    je opcao2
    cmpl $3, %eax
    je opcao3
    cmpl $4, %eax
    je opcao4
    cmpl $5, %eax
    je opcao5
    cmpl $6, %eax
    je opcao6
    cmpl $7, %eax
    je opcao7
    
    pushl $str_invalido
    call printf
    addl $4, %esp
    jmp menu_loop

opcao1:
    call add_product_interactive
    jmp menu_loop

opcao2:
    call search_product_interactive
    jmp menu_loop

opcao3:
    call remove_product_interactive
    jmp menu_loop

opcao4:
    call update_product_interactive
    jmp menu_loop

opcao5:
    call finance_menu
    jmp menu_loop

opcao6:
    call generate_report
    jmp menu_loop

opcao7:
    pushl $str_saindo
    call printf
    addl $4, %esp
    call save_list
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

memcpy:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %edi
    pushl %ecx
    movl 8(%ebp), %edi
    movl 12(%ebp), %esi
    movl 16(%ebp), %ecx
    cld
    rep movsb
    popl %ecx
    popl %edi
    popl %esi
    leave
    ret
