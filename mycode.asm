[BITS 16]
ORG 0x7C00

; =========================================================================
; 1. BOOT SECTOR (첫 512바이트)
; =========================================================================
boot_start:
    ; 세그먼트 및 스택 초기화
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; BIOS 인터럽트(INT 13h)를 이용해 뒤쪽 섹터(시계 본체)를 메모리로 로드
    mov ah, 02h             ; Read Sectors From Drive
    mov al, 15              ; 읽어올 섹터 수 (넉넉히 약 7.5KB 분량)
    mov ch, 0               ; Cylinder 0
    mov cl, 2               ; Sector 2부터 읽기 시작 (Sector 1은 현재 부트섹터)
    mov dh, 0               ; Head 0
    ; dl은 BIOS가 부팅 드라이브 번호를 자동으로 넘겨주므로 그대로 사용
    
    mov bx, 0x7E00          ; 읽어온 코드를 저장할 메모리 주소 (0x7C00 바로 뒤)
    int 13h
    jc boot_start           ; 에러 발생 시 재시도

    jmp 0x0000:0x7E00       ; 로드된 실제 시계 프로그램 시작점으로 점프

; 첫 번째 섹터의 남은 공간을 0으로 채우고 부트 마크 배치
times 510-($-$$) db 0
dw 0xAA55                   ; 512바이트 마감 (BIOS가 드디어 인식함!)

; =========================================================================
; 2. ACTUAL CLOCK PROGRAM (Sector 2 - 주소 0x7E00 시작)
; =========================================================================
clock_program_start:
    ; 데이터 세그먼트 재정렬은 필요 없음 (0x0000 기반)
    jmp show_main_menu

; --- DATA ---
HOUR         dw 0
MINUTE       dw 0
SECOND       dw 0
T_HOUR       dw 0
T_MINUTE     dw 0
T_SECOND     dw 0
LAP_COUNT    dw 0
LAP_HOUR     times 10 dw 0
LAP_MIN      times 10 dw 0
LAP_SEC      times 10 dw 0

menu_title      db 'All-rounder Clock Setup', 0
title_underbar  db '__________________________', 0
menu_line1      db 'Welcome to All-rounder Clock.', 0
menu_line2      db 'This Setup prepares All-rounder Clock to run on your computer.', 0
menu_line3      db 'To use Stopwatch now, press 1.', 0
menu_line4      db 'To use Timer now, press 2.', 0
menu_line5      db 'To quit Setup without using All-rounder, press F3.', 0
menu_key        db '1=Stopwatch   2=Timer   F3=Quit', 0
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

; --- MAIN MENU ---
show_main_menu:
    call clear_screen
    mov dh, 1
    mov dl, 1
    call gotoxy
    mov si, menu_title
    call print_string
    mov dh, 2
    mov dl, 0
    call gotoxy
    mov si, title_underbar
    call print_string
    mov dh, 4
    mov dl, 4
    call gotoxy
    mov si, menu_line1
    call print_string
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
    mov dh, 12
    mov dl, 8
    call gotoxy
    mov si, menu_line5
    call print_string
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, menu_key
    call print_string

wait_menu:
    mov ah, 01h
    int 16h
    jz wait_menu
    mov ah, 00h
    int 16h
    cmp al, '1'
    je stopwatch_main
    cmp al, '2'
    je timer_main
    cmp ah, 3Dh
    je reboot_system
    jmp wait_menu

reboot_system:
    int 19h

go_main:
    mov word [HOUR], 0
    mov word [MINUTE], 0
    mov word [SECOND], 0
    mov word [T_HOUR], 0
    mov word [T_MINUTE], 0
    mov word [T_SECOND], 0
    mov word [LAP_COUNT], 0
    jmp show_main_menu

; --- STOPWATCH ---
stopwatch_main:
    call clear_screen
    mov word [HOUR], 0
    mov word [MINUTE], 0
    mov word [SECOND], 0
    mov word [LAP_COUNT], 0
    mov dh, 1
    mov dl, 1
    call gotoxy
    mov si, stopwatch_text
    call print_string
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, stopwatch_key
    call print_string

sw_display:
    mov dh, 5
    mov dl, 4
    call gotoxy
    mov ax, [HOUR]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [MINUTE]
    call print_two_digit
    mov al, ':'
    call print_char
    mov ax, [SECOND]
    call print_two_digit

sw_check:
    call delay_one_sec
    mov ah, 01h
    int 16h
    jz sw_inc
    mov ah, 00h
    int 16h
    cmp al, 'p'
    je sw_pause
    cmp al, 'P'
    je sw_pause
    cmp al, 'l'
    je sw_lap
    cmp al, 'L'
    je sw_lap
    cmp al, 'r'
    je sw_reset
    cmp al, 'R'
    je sw_reset
    cmp ah, 3Dh
    je go_main
    jmp sw_inc

sw_pause:
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, stopwatch_pause
    call print_string
sw_wait:
    mov ah, 01h
    int 16h
    jz sw_wait
    mov ah, 00h
    int 16h
    cmp al, 's'
    je sw_resume
    cmp al, 'S'
    je sw_resume
    cmp al, 'l'
    je sw_lap_paused
    cmp al, 'L'
    je sw_lap_paused
    cmp al, 'r'
    je sw_reset
    cmp al, 'R'
    je sw_reset
    cmp ah, 3Dh
    je go_main
    jmp sw_wait

sw_resume:
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, stopwatch_key
    call print_string
    jmp sw_display

sw_lap:
    mov ax, [LAP_COUNT]
    cmp ax, 10
    jge sw_inc
    mov bx, ax
    shl bx, 1
    mov ax, [HOUR]
    mov [LAP_HOUR + bx], ax
    mov ax, [MINUTE]
    mov [LAP_MIN + bx], ax
    mov ax, [SECOND]
    mov [LAP_SEC + bx], ax
    inc word [LAP_COUNT]
    call print_laps
    jmp sw_inc

sw_lap_paused:
    mov ax, [LAP_COUNT]
    cmp ax, 10
    jge sw_wait
    mov bx, ax
    shl bx, 1
    mov ax, [HOUR]
    mov [LAP_HOUR + bx], ax
    mov ax, [MINUTE]
    mov [LAP_MIN + bx], ax
    mov ax, [SECOND]
    mov [LAP_SEC + bx], ax
    inc word [LAP_COUNT]
    call print_laps
    jmp sw_wait

sw_reset:
    jmp stopwatch_main

sw_inc:
    add word [SECOND], 1
    cmp word [SECOND], 60
    jl sw_display
    mov word [SECOND], 0
    add word [MINUTE], 1
    cmp word [MINUTE], 60
    jl sw_display
    mov word [MINUTE], 0
    add word [HOUR], 1
    cmp word [HOUR], 24
    jl sw_display
    mov word [HOUR], 0
    jmp sw_display

; --- TIMER ---
timer_main:
    call clear_screen
    mov dh, 1
    mov dl, 1
    call gotoxy
    mov si, timer_text
    call print_string
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
    mov dh, 1
    mov dl, 1
    call gotoxy
    mov si, timer_text
    call print_string
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, timer_key
    call print_string

timer_display:
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

timer_check:
    call delay_one_sec
    mov ah, 01h
    int 16h
    jz timer_dec
    mov ah, 00h
    int 16h
    cmp al, 'p'
    je timer_pause_fn
    cmp al, 'P'
    je timer_pause_fn
    cmp ah, 3Dh
    je go_main
    jmp timer_dec

timer_pause_fn:
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, timer_pause
    call print_string
timer_wait_resume:
    mov ah, 01h
    int 16h
    jz timer_wait_resume
    mov ah, 00h
    int 16h
    cmp al, 's'
    je timer_resume
    cmp al, 'S'
    je timer_resume
    cmp ah, 3Dh
    je go_main
    jmp timer_wait_resume
timer_resume:
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, timer_key
    call print_string
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
    call clear_screen_blue
    mov dh, 12
    mov dl, 35
    call gotoxy
    mov si, timeout_msg
    call print_string
    mov dh, 24
    mov dl, 4
    call gotoxy
    mov si, timeout_key
    call print_string
wait_timeout:
    mov ah, 01h
    int 16h
    jz wait_timeout
    mov ah, 00h
    int 16h
    cmp ah, 3Dh
    je timeout_exit
    jmp wait_timeout
timeout_exit:
    call clear_top
    jmp show_main_menu

; --- PROCEDURES ---
gotoxy:
    push ax
    push bx
    mov ah, 02h
    mov bh, 0
    int 10h
    pop bx
    pop ax
    ret

print_string:
    push ax
    push si
.print_loop:
    lodsb
    or al, al
    jz .print_done
    mov ah, 0Eh
    mov bh, 0
    int 10h
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
    xor ah, ah
    mov bl, 10
    div bl
    add al, '0'
    call print_char
    mov al, ah
    add al, '0'
    call print_char
    pop bx
    pop ax
    ret

bios_input_two_digit:
    push bx
    push cx
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
.ex: pop cx
    pop bx
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
    mov dh, bl
    add dh, 8
    mov dl, 4
    call gotoxy
    mov si, .lap_str
    call print_string
    mov ax, bx
    inc ax
    call print_two_digit
    mov al, ' '
    call print_char
    mov al, '|'
    call print_char
    mov al, ' '
    call print_char
    mov ax, bx
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

delay_one_sec:
    push ax
    push cx
    push dx
    mov cx, 0x000A ;0.5s
    mov dx, 0xAE60 ; 
    mov ah, 86h
    int 15h
    pop dx
    pop cx
    pop ax
    ret

clear_screen:
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0400h
    mov dx, 174Fh
    int 10h
    mov ax, 0600h
    mov bh, 70h
    mov cx, 1800h
    mov dx, 184Fh
    int 10h
    ret

clear_screen_blue:
    mov ax, 0600h
    mov bh, 1Fh
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret

clear_top:
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 034Fh
    int 10h
    ret

; 전체 플로피 디스크 파일 크기를 채우기 위한 최종 패딩 (총 16KB로 고정)
%assign total_image_size 16384
times total_image_size - ($ - $$) db 0