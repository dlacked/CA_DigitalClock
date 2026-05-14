include 'emu8086.inc'
ORG 100h

.DATA
 HOUR        DW 0
 MINUTE      DW 0
 SECOND      DW 0
 T_HOUR      DW 0
 T_MINUTE    DW 0
 T_SECOND    DW 0
 LAP_COUNT   DW 0
 LAP_HOUR    DW 0,0,0,0,0,0,0,0,0,0
 LAP_MIN     DW 0,0,0,0,0,0,0,0,0,0
 LAP_SEC     DW 0,0,0,0,0,0,0,0,0,0

 menu_title      DB 'All-rounder Clock Setup', 0
 title_underbar  DB '__________________________', 0
 menu_line1      DB 'Welcome to All-rounder Clock.', 0
 menu_line2      DB 'This Setup prepares All-rounder Clock to run on your computer.', 0
 menu_line3      DB 'To use Stopwatch now, press 1.', 0
 menu_line4      DB 'To use Timer now, press 2.', 0
 menu_line5      DB 'To quit Setup without using All-rounder, press F3.', 0
 menu_key        DB '1=Stopwatch   2=Timer   F3=Quit', 0
 stopwatch_text  DB 'Stopwatch              ', 0
 stopwatch_key   DB 'P=Pause   L=Lap   R=Reset   F3=Quit', 0
 stopwatch_pause DB 'S=Start', 0
 timer_text      DB 'Timer                  ', 0
 timer_key       DB 'P=Pause   F3=Quit', 0
 timer_pause     DB 'S=Start', 0
 timeout_key     DB 'F3=Exit          ', 0
 input_hour_msg  DB 'Enter Hour   (00-23): ', 0
 input_min_msg   DB 'Enter Minute (00-59): ', 0
 input_sec_msg   DB 'Enter Second (00-59): ', 0
 timeout_msg     DB 'Times Out!', 0
 input_buf       DB 3, 0, 3 DUP(0)

clear_screen:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0400h
    mov dx, 174Fh
    int 10h
    mov ah, 06h
    mov al, 0
    mov bh, 70h
    mov cx, 1800h
    mov dx, 184Fh
    int 10h
    ret

clear_screen_blue:
    mov ah, 06h
    mov al, 0
    mov bh, 1Fh
    mov cx, 0000h
    mov dx, 174Fh
    int 10h
    ret

clear_top:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0000h
    mov dx, 034Fh
    int 10h
    ret

input_two_digit proc
    lea dx, input_buf
    mov ah, 0Ah
    int 21h
    mov al, input_buf[2]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bh, al
    mov cl, input_buf[1]
    cmp cl, 2
    jl input_one_digit
    mov al, input_buf[3]
    sub al, '0'
    add al, bh
    xor ah, ah
    ret
input_one_digit:
    xor ah, ah
    mov al, bh
    mov bl, 10
    div bl
    xor ah, ah
    ret
input_two_digit endp

print_laps proc
    push ax
    push bx
    push cx
    push dx

    MOV CX, LAP_COUNT
    JCXZ print_laps_done
    MOV BX, 0

print_laps_loop:
    ; 커서 이동 (row = 8+BX, col = 4)
    MOV AH, 02h
    MOV DH, BL
    ADD DH, 8
    MOV DL, 4
    MOV BH, 0
    INT 10h

    ; "Lap " 출력
    MOV AH, 02h
    MOV DL, 'L'
    INT 21h
    MOV DL, 'a'
    INT 21h
    MOV DL, 'p'
    INT 21h
    MOV DL, ' '
    INT 21h

    ; 랩 번호 두 자리 출력 (01~10)
    PUSH BX
    MOV AX, BX
    INC AX
    CALL PRINT_TWO_DIGIT
    POP BX

    ; " | " 출력
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    MOV DL, '|'
    MOV AH, 02h
    INT 21h
    MOV DL, ' '
    MOV AH, 02h
    INT 21h

    ; 시 출력
    PUSH BX
    MOV AX, BX
    SHL AX, 1
    LEA SI, LAP_HOUR
    ADD SI, AX
    MOV AX, [SI]
    CALL PRINT_TWO_DIGIT

    MOV DL, ':'
    MOV AH, 2
    INT 21h

    POP BX
    PUSH BX
    MOV AX, BX
    SHL AX, 1
    LEA SI, LAP_MIN
    ADD SI, AX
    MOV AX, [SI]
    CALL PRINT_TWO_DIGIT

    MOV DL, ':'
    MOV AH, 2
    INT 21h

    POP BX
    PUSH BX
    MOV AX, BX
    SHL AX, 1
    LEA SI, LAP_SEC
    ADD SI, AX
    MOV AX, [SI]
    CALL PRINT_TWO_DIGIT

    POP BX
    INC BX
    LOOP print_laps_loop

print_laps_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_laps endp

.CODE
    MOV AX, @DATA
    MOV DS, AX

show_main_menu:
    CALL clear_screen
    GOTOXY 1, 1
    LEA SI, menu_title
    CALL PRINT_STRING
    GOTOXY 0, 2
    LEA SI, title_underbar
    CALL PRINT_STRING
    GOTOXY 4, 4
    LEA SI, menu_line1
    CALL PRINT_STRING
    GOTOXY 4, 6
    LEA SI, menu_line2
    CALL PRINT_STRING
    GOTOXY 8, 8
    LEA SI, menu_line3
    CALL PRINT_STRING
    GOTOXY 8, 10
    LEA SI, menu_line4
    CALL PRINT_STRING
    GOTOXY 8, 12
    LEA SI, menu_line5
    CALL PRINT_STRING
    GOTOXY 4, 24
    LEA SI, menu_key
    CALL PRINT_STRING

wait_menu:
    MOV AH, 01h
    INT 16h
    JZ wait_menu
    MOV AH, 00h
    INT 16h
    CMP AL, '1'
    JE stopwatch_main
    CMP AL, '2'
    JE timer_main
    CMP AH, 3Dh
    JE exit_program
    JMP wait_menu

exit_program:
    MOV AH, 4Ch
    INT 21h

go_main:
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
    MOV T_HOUR, 0
    MOV T_MINUTE, 0
    MOV T_SECOND, 0
    MOV LAP_COUNT, 0
    JMP show_main_menu

stopwatch_main:
    CALL clear_screen
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
    MOV LAP_COUNT, 0
    GOTOXY 1, 1
    LEA SI, stopwatch_text
    CALL PRINT_STRING
    GOTOXY 4, 24
    LEA SI, stopwatch_key
    CALL PRINT_STRING

sw_display:
    GOTOXY 4, 5
    MOV AX, HOUR
    CALL PRINT_TWO_DIGIT
    GOTOXY 7, 5
    MOV DL, ':'
    MOV AH, 2
    INT 21h
    GOTOXY 9, 5
    MOV AX, MINUTE
    CALL PRINT_TWO_DIGIT
    GOTOXY 12, 5
    MOV DL, ':'
    MOV AH, 2
    INT 21h
    GOTOXY 14, 5
    MOV AX, SECOND
    CALL PRINT_TWO_DIGIT

sw_check:
    MOV AH, 01h
    INT 16h
    JZ sw_inc
    MOV AH, 00h
    INT 16h
    CMP AL, 70h
    JE sw_pause
    CMP AL, 6Ch
    JE sw_lap
    CMP AL, 72h
    JE sw_reset
    CMP AH, 3Dh
    JE go_main
    JMP sw_inc

sw_pause:
    GOTOXY 4, 24
    LEA SI, stopwatch_pause
    CALL PRINT_STRING
sw_wait:
    MOV AH, 01h
    INT 16h
    JZ sw_wait
    MOV AH, 00h
    INT 16h
    CMP AL, 73h
    JE sw_resume
    CMP AL, 6Ch
    JE sw_lap_paused
    CMP AL, 72h
    JE sw_reset
    CMP AH, 3Dh
    JE go_main
    JMP sw_wait

sw_resume:
    GOTOXY 4, 24
    LEA SI, stopwatch_key
    CALL PRINT_STRING
    JMP sw_display

sw_lap:
    MOV AX, LAP_COUNT
    CMP AX, 10
    JGE sw_check
    MOV BX, LAP_COUNT
    SHL BX, 1
    LEA SI, LAP_HOUR
    ADD SI, BX
    MOV AX, HOUR
    MOV [SI], AX
    LEA SI, LAP_MIN
    ADD SI, BX
    MOV AX, MINUTE
    MOV [SI], AX
    LEA SI, LAP_SEC
    ADD SI, BX
    MOV AX, SECOND
    MOV [SI], AX
    INC LAP_COUNT
    CALL print_laps
    JMP sw_display

sw_lap_paused:
    MOV AX, LAP_COUNT
    CMP AX, 10
    JGE sw_wait
    MOV BX, LAP_COUNT
    SHL BX, 1
    LEA SI, LAP_HOUR
    ADD SI, BX
    MOV AX, HOUR
    MOV [SI], AX
    LEA SI, LAP_MIN
    ADD SI, BX
    MOV AX, MINUTE
    MOV [SI], AX
    LEA SI, LAP_SEC
    ADD SI, BX
    MOV AX, SECOND
    MOV [SI], AX
    INC LAP_COUNT
    CALL print_laps
    JMP sw_wait

sw_reset:
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
    MOV LAP_COUNT, 0
    CALL clear_screen
    GOTOXY 1, 1
    LEA SI, stopwatch_text
    CALL PRINT_STRING
    GOTOXY 4, 24
    LEA SI, stopwatch_key
    CALL PRINT_STRING
    JMP sw_display

sw_inc:
    ADD SECOND, 1
    CMP SECOND, 60
    JL sw_display
    MOV SECOND, 0
    ADD MINUTE, 1
    CMP MINUTE, 60
    JL sw_display
    MOV MINUTE, 0
    ADD HOUR, 1
    CMP HOUR, 24
    JL sw_display
    MOV HOUR, 0
    JMP sw_display

timer_main:
    CALL clear_screen
    GOTOXY 1, 1
    LEA SI, timer_text
    CALL PRINT_STRING
    GOTOXY 4, 5
    LEA SI, input_hour_msg
    CALL PRINT_STRING
    CALL input_two_digit
    MOV T_HOUR, AX
    GOTOXY 4, 7
    LEA SI, input_min_msg
    CALL PRINT_STRING
    CALL input_two_digit
    MOV T_MINUTE, AX
    GOTOXY 4, 9
    LEA SI, input_sec_msg
    CALL PRINT_STRING
    CALL input_two_digit
    MOV T_SECOND, AX
    CALL clear_screen
    GOTOXY 1, 1
    LEA SI, timer_text
    CALL PRINT_STRING
    GOTOXY 4, 24
    LEA SI, timer_key
    CALL PRINT_STRING

timer_display:
    GOTOXY 4, 5
    MOV AX, T_HOUR
    CALL PRINT_TWO_DIGIT
    GOTOXY 7, 5
    MOV DL, ':'
    MOV AH, 2
    INT 21h
    GOTOXY 9, 5
    MOV AX, T_MINUTE
    CALL PRINT_TWO_DIGIT
    GOTOXY 12, 5
    MOV DL, ':'
    MOV AH, 2
    INT 21h
    GOTOXY 14, 5
    MOV AX, T_SECOND
    CALL PRINT_TWO_DIGIT
    MOV AX, T_HOUR
    OR  AX, T_MINUTE
    OR  AX, T_SECOND
    JZ  timer_timeout

timer_check:
    MOV AH, 01h
    INT 16h
    JZ timer_dec
    MOV AH, 00h
    INT 16h
    CMP AL, 70h
    JE timer_pause_fn
    CMP AH, 3Dh
    JE go_main
    JMP timer_dec

timer_pause_fn:
    GOTOXY 4, 24
    LEA SI, timer_pause
    CALL PRINT_STRING
timer_wait_resume:
    MOV AH, 01h
    INT 16h
    JZ timer_wait_resume
    MOV AH, 00h
    INT 16h
    CMP AL, 73h
    JE timer_resume
    CMP AH, 3Dh
    JE go_main
    JMP timer_wait_resume
timer_resume:
    GOTOXY 4, 24
    LEA SI, timer_key
    CALL PRINT_STRING
    JMP timer_display

timer_dec:
    CMP T_SECOND, 0
    JG dec_sec
    CMP T_MINUTE, 0
    JG borrow_min
    CMP T_HOUR, 0
    JE timer_display
    DEC T_HOUR
    MOV T_MINUTE, 59
    MOV T_SECOND, 59
    JMP timer_display
borrow_min:
    DEC T_MINUTE
    MOV T_SECOND, 59
    JMP timer_display
dec_sec:
    DEC T_SECOND
    JMP timer_display

timer_timeout:
    CALL clear_screen_blue
    GOTOXY 35, 12
    LEA SI, timeout_msg
    CALL PRINT_STRING
    GOTOXY 4, 24
    LEA SI, timeout_key
    CALL PRINT_STRING
wait_timeout:
    MOV AH, 01h
    INT 16h
    JZ wait_timeout
    MOV AH, 00h
    INT 16h
    CMP AH, 3Dh
    JE timeout_exit
    JMP wait_timeout
timeout_exit:
    CALL clear_top
    JMP show_main_menu

DEFINE_PRINT_STRING

PRINT_TWO_DIGIT:
    push bx
    xor ah, ah
    mov bl, 10
    div bl
    add al, '0'
    mov dl, al
    mov bh, ah
    mov ah, 2
    int 21h
    mov al, bh
    add al, '0'
    mov dl, al
    mov ah, 2
    int 21h
    pop bx
    ret

END