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
    menu: .asciz "\n===== MENU =====\n1. Adicionar produto\n2. Buscar produto\n3. Sair\nEscolha: "
    str_escolha: .asciz "%d"
    str_nome_prompt: .asciz "Digite o nome do produto: "
    str_lote_prompt: .asciz "Digite o lote: "
    str_tipo_prompt: .asciz "Tipos:\n 01. Alimento\n 02. Lmipeza\n 03. Utensílios\n 04. Bebidas\n 05. Frios\n 06. Padaria\n 07. Carnes\n 08. Higiene\n 09. Bebês\n 10. Pet\n 11. Congelados\n 12. Hostifuti\n 13. Eletronicos\n 14. Vestuário\n 15. Outros\nDigite o tipo"
    str_data_prompt: .asciz "Digite a data (DD/MM/AAAA): "
    str_fornec_prompt: .asciz "Digite o fornecedor: "
    str_quant_prompt: .asciz "Digite a quantidade: "
    str_compra_prompt: .asciz "Digite o valor de compra (centavos): "
    str_venda_prompt: .asciz "Digite o valor de venda (centavos): "
    str_busca_prompt: .asciz "Digite o nome para buscar: "
    str_invalido: .asciz "Opção inválida!\n"
    str_saindo: .asciz "Saindo...\n"
    str_malloc_fail: .asciz "Falha ao alocar memoria!\n"
    
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
        .asciz "Bebês"
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

.section .text
    .globl main
    .extern malloc, free, fopen, fclose, fread, fwrite, printf, strcmp, strcpy, scanf, fgets, memcpy, stdin, getchar

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
    jz close_load  # Se malloc falhar, sair
    
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
    # Imprimir mensagem de falha
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
