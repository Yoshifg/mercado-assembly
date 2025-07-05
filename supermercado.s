.section .note.GNU-stack,"",@progbits

.section .data
    head: .int 0
    filename: .asciz "produtos.bin"
    modo_escrita: .asciz "wb"
    modo_leitura: .asciz "rb"
    
    fmt_nome: .asciz "Nome: %s\n"
    fmt_lote: .asciz "Lote: %s\n"
    fmt_tipo: .asciz "Tipo: %d\n"
    fmt_data: .asciz "Validade: %s\n"
    fmt_fornec: .asciz "Fornecedor: %s\n"
    fmt_quant: .asciz "Quantidade: %d\n"
    fmt_compra: .asciz "Compra: %d.%02d\n"
    fmt_venda: .asciz "Venda: %d.%02d\n"
    fmt_div: .asciz "----------------\n"
    menu: .asciz "\n===== MENU =====\n1. Adicionar produto\n2. Buscar produto\n3. Remover produto\n4. Atualizar produto\n5. Sair\nEscolha: "
    str_escolha: .asciz "%d"
    str_nome_prompt: .asciz "Digite o nome do produto: "
    str_lote_prompt: .asciz "Digite o lote: "
    str_tipo_prompt: .asciz "Digite o tipo (1-15): "
    str_data_prompt: .asciz "Digite a data (DD/MM/AAAA): "
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

# Tamanho fixo da estrutura
.set produto_size, 151

.section .bss
    .lcomm buffer, 147
    .lcomm input_buffer, 50
    .lcomm escolha, 4
    .lcomm nome_busca, 50
    .lcomm lote_busca, 20

.section .text
    .globl main
    .extern malloc, free, fopen, fclose, fread, fwrite, printf, strcmp, strcpy, scanf, fgets, memcpy, stdin, getchar, strncmp

insert_sorted:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    movl 8(%ebp), %ebx        # EBX = novo produto
    movl head, %edi           # EDI = atual
    xorl %esi, %esi           # ESI = anterior (NULL)

    testl %edi, %edi
    jz insert_empty
    
insertion_loop:
    # Compara nomes: novo vs atual
    leal 20(%ebx), %eax       # Nome do novo
    leal 20(%edi), %ecx       # Nome do atual
    
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
    pushl $147
    pushl %eax
    pushl $buffer
    call memcpy
    addl $12, %esp
    
    pushl %ebx
    pushl $147
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
    pushl $147
    pushl $1
    pushl $buffer
    call fread
    addl $16, %esp
    
    cmpl $147, %eax
    jne close_load
    
    pushl $151
    call malloc
    addl $4, %esp
    testl %eax, %eax
    jz close_load
    
    movl $0, (%eax)
    leal 4(%eax), %edi
    
    pushl $147
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
    
    leal 74(%ebx), %eax
    pushl %eax
    pushl $fmt_data
    call printf
    addl $8, %esp
    
    leal 85(%ebx), %eax
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

# Função para ler inteiro do usuário
# Saída: EAX = valor lido
read_int:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp
    
    leal -4(%ebp), %eax
    
    # Ler inteiro
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    
    # Limpar buffer de entrada
    call clear_input_buffer
    
    movl -4(%ebp), %eax
    leave
    ret

# Limpar buffer de entrada
clear_input_buffer:
    pushl %ebp
    movl %esp, %ebp
    
clear_loop:
    call getchar
    cmpl $10, %eax  # '\n'
    je clear_done
    cmpl $-1, %eax  # EOF
    jne clear_loop
    
clear_done:
    leave
    ret

# Função auxiliar para ler string com prompt usando fgets
# Parâmetros: [ebp+8] = endereço do prompt, [ebp+12] = endereço do buffer
read_string_with_prompt:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    # Exibir prompt
    movl 8(%ebp), %eax
    pushl %eax
    call printf
    addl $4, %esp
    
    # Ler string com fgets
    movl 12(%ebp), %ebx   # Endereço do buffer
    pushl stdin           # stdin
    pushl $50             # Tamanho máximo
    pushl %ebx
    call fgets
    addl $12, %esp
    
    # Remover nova linha se existir
    pushl %ebx
    call remove_newline
    addl $4, %esp
    
    popl %ebx
    leave
    ret

# Remover caractere de nova linha do final da string
# Entrada: EAX = endereço da string
remove_newline:
    pushl %ebp
    movl %esp, %ebp
    pushl %edi
    
    movl 8(%ebp), %edi
    
rn_loop:
    movb (%edi), %al
    testb %al, %al
    jz rn_end
    cmpb $10, %al         # '\n'
    je rn_found
    incl %edi
    jmp rn_loop

rn_found:
    movb $0, (%edi)       # Substituir por terminador nulo
    
rn_end:
    popl %edi
    leave
    ret

# Adicionar produto interativamente
add_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    # Alocar memória para o produto
    pushl $151
    call malloc
    addl $4, %esp
    testl %eax, %eax
    jz add_product_fail
    movl %eax, %ebx
    
    # Inicializar ponteiro next
    movl $0, (%ebx)
    
    # Ler nome
    leal 20(%ebx), %eax   # Campo nome
    pushl %eax
    pushl $str_nome_prompt
    call read_string_with_prompt
    addl $8, %esp
    
    # Ler lote
    leal 70(%ebx), %eax   # Campo lote
    pushl %eax
    pushl $str_lote_prompt
    call read_string_with_prompt
    addl $8, %esp
    
    # Ler tipo
    pushl $str_tipo_prompt
    call printf
    addl $4, %esp
    leal 4(%ebx), %eax    # Campo tipo
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    
    # Ler data
    leal 74(%ebx), %eax   # Campo data
    pushl %eax
    pushl $str_data_prompt
    call read_string_with_prompt
    addl $8, %esp
    
    # Ler fornecedor
    leal 85(%ebx), %eax   # Campo fornecedor
    pushl %eax
    pushl $str_fornec_prompt
    call read_string_with_prompt
    addl $8, %esp
    
    # Ler quantidade
    pushl $str_quant_prompt
    call printf
    addl $4, %esp
    leal 8(%ebx), %eax    # Campo quantidade
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    
    # Ler valor de compra
    pushl $str_compra_prompt
    call printf
    addl $4, %esp
    leal 12(%ebx), %eax   # Campo compra
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    
    # Ler valor de venda
    pushl $str_venda_prompt
    call printf
    addl $4, %esp
    leal 16(%ebx), %eax   # Campo venda
    pushl %eax
    pushl $str_escolha
    call scanf
    addl $8, %esp
    call clear_input_buffer
    
    # Inserir na lista
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

# Buscar produto interativamente
search_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    subl $52, %esp        # Alocar espaço para o buffer
    
    # Exibir prompt
    pushl $str_busca_prompt
    call printf
    addl $4, %esp
    
    # Ler nome para busca com fgets
    leal -50(%ebp), %eax  # Buffer local
    pushl stdin           # stdin
    pushl $50             # Tamanho máximo
    pushl %eax
    call fgets
    addl $12, %esp
    
    # Remover nova linha
    leal -50(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    
    # Buscar produto
    leal -50(%ebp), %eax
    pushl %eax
    call search_product
    addl $4, %esp
    
    leave
    ret

# Remover produto interativamente
remove_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    subl $72, %esp        # Alocar espaço para buffers
    
    # Ler nome do produto
    pushl $str_remove_prompt
    call printf
    addl $4, %esp
    
    leal -50(%ebp), %eax  # Buffer para nome
    pushl stdin
    pushl $50
    pushl %eax
    call fgets
    addl $12, %esp
    
    # Remover nova linha
    leal -50(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    
    # Ler lote do produto
    pushl $str_remove_lote_prompt
    call printf
    addl $4, %esp
    
    leal -70(%ebp), %eax  # Buffer para lote (70-50=20 bytes)
    pushl stdin
    pushl $20
    pushl %eax
    call fgets
    addl $12, %esp
    
    # Remover nova linha
    leal -70(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    
    # Procurar produto para remover
    movl head, %ebx       # EBX = atual
    xorl %esi, %esi       # ESI = anterior
    
remove_search_loop:
    testl %ebx, %ebx
    jz remove_not_found
    
    # Comparar nome
    leal 20(%ebx), %eax   # Nome do produto atual
    leal -50(%ebp), %ecx  # Nome buscado
    pushl %ecx
    pushl %eax
    call strcmp
    addl $8, %esp
    testl %eax, %eax
    jnz next_remove_search
    
    # Comparar lote
    leal 70(%ebx), %eax   # Lote do produto atual
    leal -70(%ebp), %ecx  # Lote buscado
    pushl $20             # Tamanho máximo para comparação
    pushl %ecx
    pushl %eax
    call strncmp
    addl $12, %esp
    testl %eax, %eax
    jz found_to_remove
    
next_remove_search:
    movl %ebx, %esi       # anterior = atual
    movl (%ebx), %ebx     # atual = atual->prox
    jmp remove_search_loop

found_to_remove:
    # Encontramos o produto para remover
    testl %esi, %esi
    jz remove_first       # Se for o primeiro nó
    
    # Remover do meio ou fim
    movl (%ebx), %eax     # EAX = próximo nó
    movl %eax, (%esi)     # anterior->prox = próximo
    jmp free_node

remove_first:
    movl (%ebx), %eax     # EAX = próximo nó
    movl %eax, head       # head = próximo

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

# Atualizar produto interativamente
update_product_interactive:
    pushl %ebp
    movl %esp, %ebp
    subl $72, %esp        # Alocar espaço para buffers
    
    # Ler nome do produto
    pushl $str_update_prompt
    call printf
    addl $4, %esp
    
    leal -50(%ebp), %eax  # Buffer para nome
    pushl stdin
    pushl $50
    pushl %eax
    call fgets
    addl $12, %esp
    
    # Remover nova linha
    leal -50(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    
    # Ler lote do produto
    pushl $str_update_lote_prompt
    call printf
    addl $4, %esp
    
    leal -70(%ebp), %eax  # Buffer para lote (70-50=20 bytes)
    pushl stdin
    pushl $20
    pushl %eax
    call fgets
    addl $12, %esp
    
    # Remover nova linha
    leal -70(%ebp), %eax
    pushl %eax
    call remove_newline
    addl $4, %esp
    
    # Procurar produto para atualizar
    movl head, %ebx       # EBX = atual
    
update_search_loop:
    testl %ebx, %ebx
    jz update_not_found
    
    # Comparar nome
    leal 20(%ebx), %eax   # Nome do produto atual
    leal -50(%ebp), %ecx  # Nome buscado
    pushl %ecx
    pushl %eax
    call strcmp
    addl $8, %esp
    testl %eax, %eax
    jnz next_update_search
    
    # Comparar lote
    leal 70(%ebx), %eax   # Lote do produto atual
    leal -70(%ebp), %ecx  # Lote buscado
    pushl $20             # Tamanho máximo para comparação
    pushl %ecx
    pushl %eax
    call strncmp
    addl $12, %esp
    testl %eax, %eax
    jz found_to_update
    
next_update_search:
    movl (%ebx), %ebx     # atual = atual->prox
    jmp update_search_loop

found_to_update:
    # Encontramos o produto para atualizar
    # Mostrar opções de campo para atualizar
    pushl $str_update_campo
    call printf
    addl $4, %esp
    
    call read_int          # Ler escolha do campo
    
    cmpl $1, %eax
    je update_quantidade
    cmpl $2, %eax
    je update_venda
    
    # Opção inválida
    pushl $str_update_campo_invalido
    call printf
    addl $4, %esp
    jmp update_done

update_quantidade:
    pushl $str_nova_quant
    call printf
    addl $4, %esp
    
    leal 8(%ebx), %eax    # Campo quantidade
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
    
    leal 16(%ebx), %eax   # Campo venda
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

# Exibir menu e obter escolha
display_menu:
    pushl %ebp
    movl %esp, %ebp
    
    # Exibir menu
    pushl $menu
    call printf
    addl $4, %esp
    
    # Ler escolha
    call read_int
    
    leave
    ret

main:
    call load_list

menu_loop:
    call display_menu
    
    # Verificar opção
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
    
    # Opção inválida
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
    pushl $str_saindo
    call printf
    addl $4, %esp
    
    call save_list
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

# Implementação de memcpy
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
    