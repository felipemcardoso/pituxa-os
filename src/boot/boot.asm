[ORG 0x7c00]
[BITS 16]

load_16:
    cli ; Disable Interrupt
    mov ax, 0x0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enable Interrupt
    
    mov si, MSG_REAL_MODE
    call print_msg
    call switch_to_protected

%include "./src/boot/print.asm"
%include "./src/boot/gdt.asm"

switch_to_protected:
    cli
    lgdt[gdt_descriptor]    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load_32

[BITS 32]
load_32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp    
    jmp $ ; Hang

MSG_REAL_MODE: db 'Starting Pituxa OS in 16-bit real mode.', 0
MSG_PROT_MODE: db 'Switched to 32-bit protected mode.', 0

times 510-($-$$) db 0
dw 0xAA55 ; Boot signature