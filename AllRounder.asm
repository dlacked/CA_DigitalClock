[BITS 16]
ORG 0x7C00

; BOOT SECTOR
boot_start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ah, 02h
    mov al, 15
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov bx, 0x7E00
    int 13h
    jc boot_start

    jmp 0x0000:0x7E00

times 510-($-$$) db 0
dw 0xAA55


clock_program_start:
    jmp main_menu

; DATA        

S_HOUR         dw 0
S_MINUTE       dw 0
S_SECOND       dw 0
T_HOUR       dw 0
T_MINUTE     dw 0
T_SECOND     dw 0
LAP_COUNT    dw 0
LAP_HOUR     times 10 dw 0
LAP_MIN      times 10 dw 0
LAP_SEC      times 10 dw 0

menu_title      db 'All-rounder Clock Setup', 0
title_underbar  db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 0
menu_line1      db 'Welcome to All-rounder Clock.', 0
menu_line2      db 'This Setup prepares All-rounder Clock to run on your computer.', 0
menu_line3      db 249, ' To use Stopwatch now, press 1.', 0
menu_line4      db 249, ' To use Timer now, press 2.', 0
menu_key        db '1=Stopwatch   2=Timer', 0
stopwatch_text  db 'Stopwatch              ', 0
stopwatch_key   db 'P=Pause   L=Lap   R=Reset   F3=Quit', 0
stopwatch_pause db 'S=Start', 0
timer_text      db 'Timer                  ', 0
timer_key       db 'P=Pause   F3=Quit', 0
timer_pause     db 'S=Start', 0
timeout_key     db 'F3=Exit          ', 0
input_hour_msg  db 'Enter Hour   (00-23): ', 0
input_min_msg   db 'Enter Minute (00-59): ', 0
input_sec_msg   db 'Enter Second (00-59): ', 0
timeout_msg     db 'Times Out!', 0

; MAIN MENU
main_menu:
    call clear_screen
    mov si, menu_title
    call draw_header
    mov dh, 4
    mov dl, 4
    call gotoxy
    mov si, menu_line1
    call print_string
    mov bl, 17h
    mov dh, 6
    mov dl, 4
    call gotoxy
    mov si, menu_line2
    call print_string
    mov dh, 8
    mov dl, 8
    call gotoxy
    mov si, menu_line3
    call print_string
    mov dh, 10
    mov dl, 8
    call gotoxy
    mov si, menu_line4
    call print_string
    mov si, menu_key
    call draw_statusbar

wait_menu:
    mov ax, 0100h
    int 16h
    jz wait_menu
    mov ah, 00h
    int 16h
    cmp al, '1'
    je sw_main
    cmp al, '2'
    je timer_main
    jmp wait_menu

go_main:
    jmp main_menu

; STOPWATCH        

sw_main:
    call clear_screen
    mov word [S_HOUR], 0
    mov word [S_MINUTE], 0
    mov word [S_SECOND], 0
    mov word [LAP_COUNT], 0
    mov si, stopwatch_text
    call draw_header
    mov si, stopwatch_key
    call draw_statusbar

sw_display:
    mov bl, 17h
    mov dh, 5
    mov dl, 4
    call gotoxy
    mov ax, [S_HOUR]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [S_MINUTE]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [S_SECOND]
    call print_two_digit

    call delay
    mov ah, 01h
    int 16h
    jz sw_inc
    mov ah, 00h
    int 16h
    or al, 20h
    cmp al, 'p'
    je sw_pause
    cmp al, 'l'
    je sw_lap
    cmp al, 'r'
    je sw_main
    cmp ah, 3Dh
    je go_main
    jmp sw_inc

sw_pause:
    mov si, stopwatch_pause
    call draw_statusbar  
    
sw_wait:
    mov ah, 01h
    int 16h
    jz sw_wait
    mov ah, 00h
    int 16h
    or al, 20h
    cmp al, 's'
    je sw_resume
    cmp al, 'l'
    je sw_lap_paused
    cmp al, 'r'
    je sw_main
    cmp ah, 3Dh
    je go_main
    jmp sw_wait

sw_resume:
    mov si, stopwatch_key
    call draw_statusbar
    jmp sw_display

sw_lap:
    call do_lap
    jmp sw_inc

sw_lap_paused:
    call do_lap
    jmp sw_wait

sw_inc:
    add word [S_SECOND], 1
    cmp word [S_SECOND], 60
    jl sw_display
    mov word [S_SECOND], 0
    add word [S_MINUTE], 1
    cmp word [S_MINUTE], 60
    jl sw_display
    mov word [S_MINUTE], 0
    add word [S_HOUR], 1
    cmp word [S_HOUR], 24
    jl sw_display
    mov word [S_HOUR], 0
    jmp sw_display

; TIMER       

timer_main:
    call clear_screen
    mov si, timer_text
    call draw_header
    mov dh, 5
    mov dl, 4
    call gotoxy
    mov si, input_hour_msg
    call print_string
    call bios_input_two_digit
    mov [T_HOUR], ax
    mov dh, 7
    mov dl, 4
    call gotoxy
    mov si, input_min_msg
    call print_string
    call bios_input_two_digit
    mov [T_MINUTE], ax
    mov dh, 9
    mov dl, 4
    call gotoxy
    mov si, input_sec_msg
    call print_string
    call bios_input_two_digit
    mov [T_SECOND], ax
    call clear_screen
    mov si, timer_text
    call draw_header
    mov si, timer_key
    call draw_statusbar

timer_display:
    mov bl, 17h
    mov dh, 5
    mov dl, 4
    call gotoxy
    mov ax, [T_HOUR]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [T_MINUTE]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [T_SECOND]
    call print_two_digit

    mov ax, [T_HOUR]
    or  ax, [T_MINUTE]
    or  ax, [T_SECOND]
    jz  timer_timeout

    call delay
    mov ah, 01h
    int 16h
    jz timer_dec
    mov ah, 00h
    int 16h
    or al, 20h
    cmp al, 'p'
    je timer_pause_fn
    cmp ah, 3Dh
    je go_main
    jmp timer_dec

timer_pause_fn:
    mov si, timer_pause
    call draw_statusbar
timer_wait_resume:
    mov ah, 01h
    int 16h
    jz timer_wait_resume
    mov ah, 00h
    int 16h
    or al, 20h
    cmp al, 's'
    je timer_resume
    cmp ah, 3Dh
    je go_main
    jmp timer_wait_resume
timer_resume:
    mov si, timer_key
    call draw_statusbar
    jmp timer_display

timer_dec:
    cmp word [T_SECOND], 0
    jg dec_sec
    cmp word [T_MINUTE], 0
    jg borrow_min
    cmp word [T_HOUR], 0
    je timer_display
    dec word [T_HOUR]
    mov word [T_MINUTE], 59
    mov word [T_SECOND], 59
    jmp timer_display
borrow_min:
    dec word [T_MINUTE]
    mov word [T_SECOND], 59
    jmp timer_display
dec_sec:
    dec word [T_SECOND]
    jmp timer_display

timer_timeout:
    call clear_screen
    mov bl, 17h
    mov dh, 12
    mov dl, 35
    call gotoxy
    mov si, timeout_msg
    call print_string
    mov si, timeout_key
    call draw_statusbar
wait_timeout:
    mov ah, 01h
    int 16h
    jz wait_timeout
    mov ah, 00h
    int 16h
    cmp ah, 3Dh
    je go_main
    jmp wait_timeout

; PROCEDURES
gotoxy:
    push ax
    push bx
    mov ah, 02h
    mov bh, 0
    int 10h
    pop bx
    pop ax
    ret

draw_header:
    mov bl, 17h
    mov dh, 1
    mov dl, 1
    call gotoxy
    call print_string
    mov dh, 2
    mov dl, 0
    call gotoxy
    mov si, title_underbar
    call print_string
    ret

draw_statusbar:
    mov bl, 70h
    mov dh, 24
    mov dl, 4
    call gotoxy
    call print_string
    ret

print_string:
    push ax
    push si
.print_loop:
    lodsb
    or al, al
    jz .print_done
    call print_char
    jmp .print_loop
.print_done:
    pop si
    pop ax
    ret

print_char:
    push ax
    push bx
    mov ah, 0Eh
    mov bh, 0
    int 10h
    pop bx
    pop ax
    ret

print_two_digit:
    push ax
    push bx
    push cx
    mov cl, bl
    xor ah, ah
    mov bl, 10
    div bl
    mov bl, cl
    add al, '0'
    call print_char
    mov al, ah
    add al, '0'
    call print_char
    pop cx
    pop bx
    pop ax
    ret

bios_input_two_digit:
    push bx
    push cx
    mov bl, 17h
.w1:
    mov ah, 00h
    int 16h
    cmp al, 13
    je .sd
    cmp al, '0'
    jl .w1
    cmp al, '9'
    jg .w1
    call print_char
    sub al, '0'
    mov cl, al
.w2:
    mov ah, 00h
    int 16h
    cmp al, 13
    je .j1
    cmp al, '0'
    jl .w2
    cmp al, '9'
    jg .w2
    call print_char
    sub al, '0'
    mov ch, al
    mov al, cl
    mov bl, 10
    mul bl
    add al, ch
    xor ah, ah
    jmp .ex
.sd: xor ax, ax
    jmp .ex
.j1: mov al, cl
    xor ah, ah
.ex:
    pop cx
    pop bx
    ret

do_lap:
    mov ax, [LAP_COUNT]
    cmp ax, 10
    jge .done
    mov bx, ax
    shl bx, 1
    mov ax, [S_HOUR]
    mov [LAP_HOUR + bx], ax
    mov ax, [S_MINUTE]
    mov [LAP_MIN + bx], ax
    mov ax, [S_SECOND]
    mov [LAP_SEC + bx], ax
    inc word [LAP_COUNT]
    call print_laps
.done:
    ret

print_laps:
    push ax
    push bx
    push cx
    push dx
    push si
    mov cx, [LAP_COUNT]
    jcxz .ldone
    mov bx, 0
.l_loop:
    push bx
    mov bl, 17h
    mov dh, [esp]
    add dh, 8
    mov dl, 4
    call gotoxy
    mov si, .lap_str
    call print_string
    mov ax, [esp]
    inc ax
    call print_two_digit
    mov al, ' '
    call print_char
    mov al, '|'
    call print_char
    mov al, ' '
    call print_char
    mov ax, [esp]
    shl ax, 1
    mov si, ax
    mov ax, [LAP_HOUR + si]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [LAP_MIN + si]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [LAP_SEC + si]
    call print_two_digit
    pop bx
    inc bx
    loop .l_loop
.ldone:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
.lap_str db 'Lap ', 0

delay:
    push ax
    push bx
    push cx
    push dx                   
    
.read_current:
    mov ah, 02h
    int 1Ah
    jc .read_current    ; CF=1이면 RTC 업데이트 중 → 재시도
    mov bl, dh          ; BL = 현재 초 (BCD)


.wait_change:
    mov ah, 02h
    int 1Ah
    jc .wait_change     ; RTC 업데이트 중이면 재시도
    cmp dh, bl          ; 초값 바뀌었나?
    je .wait_change     ; 그대로면 계속 대기

.done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

clear_screen:
    mov ax, 0600h
    mov bh, 17h
    mov cx, 0000h
    mov dx, 174Fh
    int 10h
    mov ax, 0600h
    mov bh, 70h
    mov cx, 1800h
    mov dx, 184Fh
    int 10h
    ret

%assign total_image_size 16384
times total_image_size - ($ - $$) db 0
