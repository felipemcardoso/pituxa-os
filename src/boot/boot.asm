[ORG 0x7c00]
[BITS 16]

jmp start

start:    
    cli ;Clear Interrupt Flag
    mov ax, 0x0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ;Set Interrupt Flag
    
    mov si, welcome_message
    call print
    jmp $ ;Hang on current address

%include "./src/boot/print.asm"

welcome_message: db 'Pituxa OS'

times 510-($-$$) db 0
dw 0xAA55 ;Boot signature