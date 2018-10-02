; A boot sector that boots a C kernel in 32-bit protected mode
[org 0x7c00]
KERNEL_OFFSET equ 0x1000    ; Memory offset to load kernel

    mov [BOOT_DRIVE] , dl   ; BIOS stores boot drive in DL

    mov bp, 0x9000      ; Set up stack
    mov sp, bp

    mov bx, MSG_REAL_MODE   ; Announce startup
    call print_string

    call load_kernel        ; Load kernel from disk

    mov bx, KERNEL_OFFSET
    call print_string


    call switch_to_pm       ; Switch to protected mode
                            ; ! Will not return

    jmp $

; Include routines
%include "print.asm"
%include "disk_load.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

[bits 16]

; Load the kernel
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string

    mov bx, KERNEL_OFFSET   ; Set up parameters for the disk_load routine so
    mov dh, 15              ; that we load the first 15 sectors (excluding
                            ; the boot sector) from the boot disk (our
                            ; kernel code) to address KERNEL_OFFSET
    mov dl, [BOOT_DRIVE]
    call disk_load

    ret


; === 32-bit code ===
[bits 32]

BEGIN_PM:

    mov ebx, MSG_PROT_MODE  ; Announce protected mode
    call print_string_pm

    call KERNEL_OFFSET  ; Jump to the address of our loaded kernel code

    jmp $

; Global vars
BOOT_DRIVE      db 0
MSG_REAL_MODE   db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE   db "Successfully switched to 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory.", 0

; Bootsector padding
times 510-($-$$) db 0
dw 0xaa55

; QEMU is dumb, must give it exactly 16 sectors
;times 16*256-($-$$) db 0