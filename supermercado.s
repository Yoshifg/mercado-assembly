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

    nome_buscado: .asciz "Crroz"   # Nome para busca
    exemplo_nome: .asciz "Prrroz"
    exemplo_lote: .asciz "xyz"
    exemplo_data: .asciz "31/12/2025"
    exemplo_fornec: .asciz "Fornecedor Exemplo"

# Tamanho fixo da estrutura (sem variável global)
.set produto_size, 151

.section .bss
    .lcomm buffer, 147

.section .text
    .globl main
    .extern malloc, free, fopen, fclose, fread, fwrite, printf, strcmp, strcpy

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
    
    pushl $151                # Tamanho fixo (sem variável)
    call malloc
    addl $4, %esp
    
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

add_product:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    pushl $151                # Tamanho fixo
    call malloc
    addl $4, %esp
    movl %eax, %ebx
    
    movl $0, (%ebx)           # prox = NULL
    movl $1, 4(%ebx)          # tipo
    movl $100, 8(%ebx)        # quantidade
    movl $5000, 12(%ebx)      # compra (50.00)
    movl $7500, 16(%ebx)      # venda (75.00)
    
    # Copiar nome
    leal 20(%ebx), %eax
    pushl $exemplo_nome
    pushl %eax
    call strcpy
    addl $8, %esp
    
    # Copiar lote
    leal 70(%ebx), %eax
    pushl $exemplo_lote
    pushl %eax
    call strcpy
    addl $8, %esp
    
    # Copiar data
    leal 74(%ebx), %eax
    pushl $exemplo_data
    pushl %eax
    call strcpy
    addl $8, %esp
    
    # Copiar fornecedor
    leal 85(%ebx), %eax
    pushl $exemplo_fornec
    pushl %eax
    call strcpy
    addl $8, %esp
    
    pushl %ebx
    call insert_sorted
    addl $4, %esp
    
    popl %ebx
    leave
    ret

main:
    call load_list
    call add_product
    
    pushl $nome_buscado
    call search_product
    addl $4, %esp
    
    call save_list
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

# Implementação simplificada de memcpy
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
