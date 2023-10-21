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
    jmp $
    jmp CODE_SEG:load_32

[BITS 32]
load_32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x100000

ata_lba_read:
    mov ebx, eax, ; Backup the LBA
    ; Send the highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or eax, 0xE0 ; Select the  master drive
    mov dx, 0x1F6
    out dx, al

    ; Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    ; Send more bits of the LBA
    mov eax, ebx ; Restore the backup LBA
    mov dx, 0x1F3
    out dx, al

    ; Send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx ; Restore the backup LBA
    shr eax, 8
    out dx, al

    ; Send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx ; Restore the backup LBA
    shr eax, 16
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
 .next_sector:
    push ecx

 ; Checking if we need to read
 .try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

 ; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors into memory
    ret     

MSG_REAL_MODE: db 'Starting Pituxa OS in 16-bit real mode.', 0

times 510-($-$$) db 0
dw 0xAA55 ; Boot signature