.section .note.GNU-stack,"",@progbits

.section .data
    head: .int 0
    filename: .asciz "produtos.bin"
    report_filename: .asciz "relatorio.txt"
    modo_escrita: .asciz "wb"
    modo_leitura: .asciz "rb"
    modo_escrita_txt: .asciz "w"
    
    fmt_nome: .asciz "Nome: %s\n"
    fmt_lote: .asciz "Lote: %s\n"
    fmt_tipo: .asciz "Tipo: %d\n"
    fmt_data: .asciz "Validade: %02d/%02d/%04d\n"
    fmt_fornec: .asciz "Fornecedor: %s\n"
    fmt_quant: .asciz "Quantidade: %d\n"
    fmt_compra: .asciz "Compra: %d.%02d\n"
    fmt_venda: .asciz "Venda: %d.%02d\n"
    fmt_div: .asciz "----------------\n"
    menu: .asciz "\n===== MENU =====\n1. Adicionar produto\n2. Buscar produto\n3. Remover produto\n4. Atualizar produto\n5. Consultas Financeiras\n6. Gerar relatório\n7. Sair\nEscolha: "
    str_escolha: .asciz "%d"
    str_nome_prompt: .asciz "Digite o nome do produto: "
    str_lote_prompt: .asciz "Digite o lote: "
    str_tipo_prompt: .asciz "Tipos:\n 01. Alimento\n 02. Limpeza\n 03. Utensílios\n 04. Bebidas\n 05. Frios\n 06. Padaria\n 07. Carnes\n 08. Higiene\n 09. Bebês\n 10. Pet\n 11. Congelados\n 12. Hortifruti\n 13. Eletronicos\n 14. Vestuário\n 15. Outros\nDigite o tipo (1-15): "
    str_dia_prompt: .asciz "Digite o dia da validade: "
    str_mes_prompt: .asciz "Digite o mês da validade: "
    str_ano_prompt: .asciz "Digite o ano da validade: "
    str_fornec_prompt: .asciz "Digite o fornecedor: "
    str_quant_prompt: .asciz "Digite a quantidade: "
    str_compra_prompt: .asciz "Digite o valor de compra (centavos): "
    str_venda_prompt: .asciz "Digite o valor de venda (centavos): "
    str_busca_prompt: .asciz "Digite o nome para buscar: "
    str_remove_prompt: .asciz "Digite o nome do produto a remover: "
    str_remove_lote_prompt: .asciz "Digite o lote do produto a remover: "
    str_update_prompt: .asciz "Digite o nome do produto a atualizar: "
    str_update_lote_prompt: .asciz "Digite o lote do produto a atualizar: "
    str_update_campo: .asciz "Qual campo deseja atualizar?\n1. Quantidade\n2. Valor de venda\nEscolha: "
    str_nova_quant: .asciz "Digite a nova quantidade: "
    str_nova_venda: .asciz "Digite o novo valor de venda (centavos): "
    str_invalido: .asciz "Opção inválida!\n"
    str_saindo: .asciz "Saindo...\n"
    str_malloc_fail: .asciz "Falha ao alocar memoria!\n"
    str_remove_success: .asciz "Produto removido com sucesso!\n"
    str_remove_fail: .asciz "Produto não encontrado para remoção!\n"
    str_update_success: .asciz "Produto atualizado com sucesso!\n"
    str_update_fail: .asciz "Produto não encontrado para atualização!\n"
    str_update_campo_invalido: .asciz "Campo inválido!\n"
    str_report_success: .asciz "Relatório gerado com sucesso em relatorio.txt\n"
    str_report_fail: .asciz "Erro ao gerar relatório!\n"
    str_report_order_prompt: .asciz "Ordenar por:\n1. Nome (padrão)\n2. Quantidade em estoque\nEscolha: "
    str_report_order_invalido: .asciz "Opção inválida! Usando ordenação padrão.\n"
    
    # Tipos de produtos
    tipos:
        .asciz "Alimento"
        .asciz "Limpeza"
        .asciz "Utensilios"
        .asciz "Bebidas"
        .asciz "Frios"
        .asciz "Padaria"
        .asciz "Carnes"
        .asciz "Higiene"
        .asciz "Bebes"
        .asciz "Pet"
        .asciz "Congelados"
        .asciz "Hortifruti"
        .asciz "Eletronicos"
        .asciz "Vestuario"
        .asciz "Outros"

    # Novas strings para consultas financeiras
    menu_financeiro: .asciz "\n===== CONSULTAS FINANCEIRAS =====\n1. Total de compra\n2. Total de venda\n3. Lucro total\n4. Capital perdido\n5. Voltar\nEscolha: "
    fmt_total_compra: .asciz "Total gasto em compras: %d.%02d\n"
    fmt_total_venda: .asciz "Total estimado de vendas: %d.%02d\n"
    fmt_lucro: .asciz "Lucro estimado: %d.%02d\n"
    fmt_capital_perdido: .asciz "Capital perdido: %d.%02d\n"
    str_dia_atual: .asciz "Digite o dia atual: "
    str_mes_atual: .asciz "Digite o mês atual: "
    str_ano_atual: .asciz "Digite o ano atual: "
    str_aguarde: .asciz "Calculando...\n"

# Tamanho fixo da estrutura
.set produto_size, 152
.set dados_size, 148

.section .bss
    .lcomm buffer, 148
    .lcomm input_buffer, 50
    .lcomm escolha, 4
    .lcomm nome_busca, 50
    .lcomm lote_busca, 20
    .lcomm dia_atual, 4
    .lcomm mes_atual, 4
    .lcomm ano_atual, 4
    .lcomm node_array, 4  # Ponteiro para array de nós
    .lcomm node_count, 4  # Contador de nós

.section .text
    .globl main
    .extern malloc, free, fopen, fclose, fread, fwrite, printf, strcmp, strcpy, scanf, fgets, memcpy, stdin, getchar, strncmp, fprintf

insert_sorted:
    pushl %ebp
    movl %esp, %ebp
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
    
    movl 4(%ebx), %eax
    pushl %eax
    pushl $fmt_tipo
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
    call printf
    addl $4, %esp
    leal 4(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    pushl $str_dia_prompt
    call printf
    addl $4, %esp
    leal 90(%ebx), %eax
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
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

# =============================================
# FUNÇÕES AUXILIARES PARA RELATÓRIO ORDENADO (CORRIGIDAS)
# =============================================

# Função: Contar nós na lista
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

# Função: Ordenar array por quantidade (bubble sort corrigido)
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
# FUNÇÃO: IMPRIMIR PRODUTO EM ARQUIVO (CORRIGIDA)
# Argumentos: endereço do nó, file handle
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
    pushl %eax
    pushl $fmt_tipo
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
# FUNÇÃO GERAR RELATÓRIO (COM CORREÇÕES)
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
    
    # Ordenação padrão (por nome)
    movl head, %esi        # ESI = current node
    jmp report_loop
    
quantity_order:
    # Contar nós
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
    
    # Imprimir usando array ordenado
    movl node_array, %ebx
    movl node_count, %ecx
    
array_report_loop:
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
    jmp array_report_loop
    
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

# =============================================
# FUNÇÕES DE CONSULTA FINANCEIRA
# =============================================

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
    
    # Correção dos offsets (valores corretos):
    movl 16(%ebp), %eax     # ano_prod (correto)
    cmpl 28(%ebp), %eax     # Compara com ano_atual (correto)
    jl date_less
    jg date_greater
    
    movl 12(%ebp), %eax     # mes_prod (correto)
    cmpl 24(%ebp), %eax     # Compara com mes_atual (correto)
    jl date_less
    jg date_greater
    
    movl 8(%ebp), %eax      # dia_prod (correto)
    cmpl 20(%ebp), %eax     # Compara com dia_atual (correto)
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
    
# Função capital_perdido corrigida
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
    
    # Empilhar parâmetros para compare_dates na ordem correta:
    # dia_prod, mes_prod, ano_prod, dia_atual, mes_atual, ano_atual
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

# Função print_currency corrigida
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
    pushl %ebx             # formato
    call printf
    addl $12, %esp
    
    leave
    ret

# Menu de consultas financeiras corrigido
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
    movl $fmt_total_compra, %ebx
    call print_currency
    jmp finance_loop

fm_total_venda:
    call total_venda
    movl $fmt_total_venda, %ebx
    call print_currency
    jmp finance_loop

fm_lucro:
    call lucro_total
    movl $fmt_lucro, %ebx
    call print_currency
    jmp finance_loop

fm_capital_perdido:
    call capital_perdido
    movl $fmt_capital_perdido, %ebx
    call print_currency
    jmp finance_loop

fm_done:
    leave
    ret

# =============================================
# MAIN
# =============================================

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
    