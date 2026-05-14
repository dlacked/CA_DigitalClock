include 'emu8086.inc'
ORG 100h

.DATA
 HOUR        DW 0
 MINUTE      DW 0
 SECOND      DW 0

 msg         DB  'Enter the alarm hour (0-23): ', 0
 msg2        DB  'Enter the alarm minute (0-59): ', 0
 msg3        DB  'Enter the alarm seconds (0-59): ', 0
 alarm_msg   DB  'Alarm!', 0
 newline     DB  13,10,0
 equals  DB  '================================================================================', 13,10, 0
 menu_text   DB  '                                    Main Menu', 13,10, 0
 menu_options DB ' 1. Stop Watch', 13,10, ' 2. Exit', 13,10, 0
 choose_msg DB  'Select option [1-2]: ', 0  
 stopwatch_text DB 'Stop Watch', 0             
 stopwatch_s      DB 'Press S key to Stop ', 13, 10, 0
 stopwatch_s_start DB 'Press S key to Start', 13, 10, 0
 stopwatch_r      DB 'Press R key to Reset', 13, 10, 0
 stopwatch_e      DB 'Press E key to Menu ', 13, 10, 0

clear_screen:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0400h
    mov dx, 184Fh
    int 10h
    ret

.CODE

    MOV AX, @DATA
    MOV DS, AX

    ; Show main menu and wait for selection
show_main_menu:
    LEA SI, equals
    CALL PRINT_STRING
    LEA SI, menu_text
    CALL PRINT_STRING    
    LEA SI, equals
    CALL PRINT_STRING
    LEA SI, menu_options
    CALL PRINT_STRING  
    
    LEA SI, choose_msg
    CALL PRINT_STRING

wait_menu:
    MOV AH, 01h
    INT 16h
    JZ wait_menu
    MOV AH, 00h
    INT 16h
    CMP AL, '1'
    JE alarm_main
    CMP AL, '2'
    JE exit_program
    JMP wait_menu

exit_program:
    MOV AH, 4Ch
    INT 21h

    ; Initialize time variables to 00:00:00
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0

alarm_main:
    CALL clear_screen                               
    GOTOXY 35, 2
    LEA SI, stopwatch_text
    CALL PRINT_STRING
    GOTOXY 30, 7
    LEA SI, stopwatch_s
    CALL PRINT_STRING
    GOTOXY 30, 8
    LEA SI, stopwatch_r
    CALL PRINT_STRING
    GOTOXY 30, 9
    LEA SI, stopwatch_e
    CALL PRINT_STRING
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    
usec:
    ; print hour
    GOTOXY 34, 5
    MOV AX, HOUR
    CALL PRINT_TWO_DIGIT

    ; symbol
    GOTOXY 37, 5
    mov dl,':'
    mov ah,2
    int 21h

    ; print minute
    GOTOXY 39, 5
    MOV AX, MINUTE
    CALL PRINT_TWO_DIGIT

    ; symbol
    GOTOXY 42, 5
    mov dl,':'
    mov ah,2
    int 21h

    ; print seconds
    GOTOXY 44, 5
    MOV AX, SECOND
    CALL PRINT_TWO_DIGIT

    ; Check if alarm is set and if current time matches alarm time 
    CALL not_alarm_time
 
mainc:      
 
    ; Check for inputs    
    MOV AH, 01h
    INT 16h
    JZ increment_time  ; Jump if no key pressed 
    mov ah, 00
    int 16h
    CMP AL, 73h        ; 's' - stop
    JE stop_watch
    CMP AL, 72h        ; 'r' - reset
    JE reset_watch
    CMP AL, 65h        ; 'e' - back to menu
    JE go_main
    CMP AL, 61h
    JE increment_hour
    CMP AL, 64h
    JE increment_minute
    CMP AL, 66h
    JE decrement_minute
    JMP increment_time

stop_watch:
    GOTOXY 30, 7
    LEA SI, stopwatch_s_start
    CALL PRINT_STRING
wait_s:
    MOV AH, 01h
    INT 16h
    JZ wait_s
    MOV AH, 00h
    INT 16h
    CMP AL, 73h        ; 's' - resume
    JE resume_watch
    CMP AL, 72h        ; 'r' - reset
    JE reset_watch
    CMP AL, 65h        ; 'e' - back to menu
    JE go_main
    JMP wait_s

go_main:
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
    CALL clear_screen
    JMP show_main_menu

resume_watch:
    GOTOXY 30, 7
    LEA SI, stopwatch_s
    CALL PRINT_STRING
    JMP usec

reset_watch:
    GOTOXY 30, 7
    LEA SI, stopwatch_s
    CALL PRINT_STRING
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
    JMP usec

;increment the hour if input is 'a'
increment_hour:
    INC HOUR
    CMP HOUR, 24
    JNE increment_time
    MOV HOUR, 0 

; increment the minute if input is 'd'
increment_minute:
    INC MINUTE
    CMP MINUTE, 60
    JNE increment_time
    MOV MINUTE, 0 

; decrement the minute if input is 'f'    
decrement_MINUTE:
    DEC MINUTE
    CMP MINUTE, 0
    JNS increment_time
    MOV MINUTE, 59

increment_time:
    
    ;; Increment seconds and handle overflow
    ADD SECOND, 1
    CMP SECOND, 60
    JL  usec   ; Jump back if seconds < 60
    MOV SECOND, 0
    ;; Increment minutes and handle overflow
    ADD MINUTE, 1
    CMP MINUTE, 60
    JL  usec   ; Jump back if minutes < 60
    MOV MINUTE, 0
    ;; Increment hours and handle overflow
    ADD HOUR, 1
    CMP HOUR, 24
    JL  usec   ; Jump back if hours < 24
    MOV HOUR, 0

    JMP usec

not_alarm_time:
    ; Continue by jumping to the increment if the time doesn't match with the alarm
    JMP mainc

DEFINE_SCAN_NUM
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
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
DEFINE_PTHIS

END