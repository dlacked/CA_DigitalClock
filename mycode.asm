include 'emu8086.inc'
ORG 100h

.DATA
 HOUR        DW 0
 MINUTE      DW 0
 SECOND      DW 0
 T_HOUR      DW 0
 T_MINUTE    DW 0
 T_SECOND    DW 0

 menu_title   DB  'All-rounder Clock Setup', 0
 title_underbar DB '__________________________', 0
 menu_line1 DB 'Welcome to All-rounder Clock.', 0
 menu_line2 DB 'This Setup prepares All-rounder Clock to run on your computer.', 0
 menu_line3 DB 'To use Stopwatch now, press 1.', 0    
 menu_line4 DB 'To use Timer now, press 2.', 0            
 menu_line5 DB 'To quit Setup without using All-rounder, press F3.', 0
 menu_key DB  '1=Stopwatch   2=Timer   F3=Quit', 0
 stopwatch_text DB 'Stopwatch               ', 0
 stopwatch_key  DB 'P=Pause   R=Reset   F3=Quit', 0
 stopwatch_start   DB 'S=Start', 0      
 timer_text DB 'Timer                   ', 0  
 timer_key  DB 'P=Pause   F3=Quit        ', 0
 timer_pause DB 'S=Start', 0
 input_hour_msg  DB 'Enter Hour   (00-23): ', 0
 input_min_msg   DB 'Enter Minute (00-59): ', 0
 input_sec_msg   DB 'Enter Second (00-59): ', 0
 timeout_msg     DB 'Times Out!', 0
 input_buf    DB 3, 0, 3 DUP(0)

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

stopwatch_main:
    CALL clear_screen
    GOTOXY 1, 1
    LEA SI, stopwatch_text
    CALL PRINT_STRING
    GOTOXY 4, 24
    LEA SI, stopwatch_key
    CALL PRINT_STRING
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

usec:
    GOTOXY 4, 5
    MOV AX, HOUR
    CALL PRINT_TWO_DIGIT
    GOTOXY 7, 5
    mov dl, ':'
    mov ah, 2
    int 21h
    GOTOXY 9, 5
    MOV AX, MINUTE
    CALL PRINT_TWO_DIGIT
    GOTOXY 12, 5
    mov dl, ':'
    mov ah, 2
    int 21h
    GOTOXY 14, 5
    MOV AX, SECOND
    CALL PRINT_TWO_DIGIT

mainc:
    MOV AH, 01h
    INT 16h
    JZ increment_time
    mov ah, 00
    int 16h
    CMP AL, 70h
    JE stop_watch
    CMP AL, 72h
    JE reset_watch
    CMP AH, 3Dh
    JE go_main
    CMP AL, 61h
    JE increment_hour
    CMP AL, 64h
    JE increment_minute
    CMP AL, 66h
    JE decrement_minute
    JMP increment_time

stop_watch:
    GOTOXY 4, 24
    LEA SI, stopwatch_start
    CALL PRINT_STRING

wait_s:
    MOV AH, 01h
    INT 16h
    JZ wait_s
    MOV AH, 00h
    INT 16h
    CMP AL, 73h
    JE resume_watch
    CMP AL, 72h
    JE reset_watch
    CMP AH, 3Dh
    JE go_main
    JMP wait_s

go_main:
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
    MOV T_HOUR, 0
    MOV T_MINUTE, 0
    MOV T_SECOND, 0
    CALL clear_screen
    GOTOXY 1, 1
    LEA SI, menu_title
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
    JMP wait_menu

resume_watch:
    GOTOXY 4, 24
    LEA SI, stopwatch_key
    CALL PRINT_STRING
    JMP usec

reset_watch:
    GOTOXY 4, 24
    LEA SI, stopwatch_key
    CALL PRINT_STRING
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
    JMP usec

increment_hour:
    INC HOUR
    CMP HOUR, 24
    JNE increment_time
    MOV HOUR, 0

increment_minute:
    INC MINUTE
    CMP MINUTE, 60
    JNE increment_time
    MOV MINUTE, 0

decrement_MINUTE:
    DEC MINUTE
    CMP MINUTE, 0
    JNS increment_time
    MOV MINUTE, 59

increment_time:
    ADD SECOND, 1
    CMP SECOND, 60
    JL  usec
    MOV SECOND, 0
    ADD MINUTE, 1
    CMP MINUTE, 60
    JL  usec
    MOV MINUTE, 0
    ADD HOUR, 1
    CMP HOUR, 24
    JL  usec
    MOV HOUR, 0
    JMP usec     
    
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

timer_usec:
    GOTOXY 4, 5
    MOV AX, T_HOUR
    CALL PRINT_TWO_DIGIT
    GOTOXY 7, 5
    mov dl, ':'
    mov ah, 2
    int 21h
    GOTOXY 9, 5
    MOV AX, T_MINUTE
    CALL PRINT_TWO_DIGIT
    GOTOXY 12, 5
    mov dl, ':'
    mov ah, 2
    int 21h
    GOTOXY 14, 5
    MOV AX, T_SECOND
    CALL PRINT_TWO_DIGIT
    MOV AX, T_HOUR
    OR  AX, T_MINUTE
    OR  AX, T_SECOND
    JZ  timer_timeout

timer_mainc:
    MOV AH, 01h
    INT 16h
    JZ  decrement_time
    MOV AH, 00h
    INT 16h
    CMP AL, 70h     ; p - pause
    JE  timer_pause_watch
    CMP AH, 3Dh
    JE  go_main
    JMP decrement_time

timer_pause_watch:
    GOTOXY 4, 24
    LEA SI, timer_pause
    CALL PRINT_STRING
timer_wait_resume:
    MOV AH, 01h
    INT 16h
    JZ  timer_wait_resume
    MOV AH, 00h
    INT 16h
    CMP AL, 73h     ; s - resume
    JE  timer_resume
    CMP AH, 3Dh
    JE  go_main
    JMP timer_wait_resume
timer_resume:
    GOTOXY 4, 24
    LEA SI, timer_key
    CALL PRINT_STRING
    JMP timer_usec

decrement_time:
    CMP T_SECOND, 0
    JG  dec_sec
    CMP T_MINUTE, 0
    JG  borrow_min
    CMP T_HOUR, 0
    JE  timer_usec
    DEC T_HOUR
    MOV T_MINUTE, 59
borrow_min:
    DEC T_MINUTE
    MOV T_SECOND, 59
    JMP timer_usec
dec_sec:
    DEC T_SECOND
    JMP timer_usec

timer_timeout:
    CALL clear_screen_blue
    GOTOXY 35, 12
    LEA SI, timeout_msg
    CALL PRINT_STRING

wait_timeout:
    MOV AH, 01h
    INT 16h
    JZ  wait_timeout
    MOV AH, 00h
    INT 16h
    CMP AH, 3Dh
    JE  timeout_go_main
    JMP wait_timeout

timeout_go_main:
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