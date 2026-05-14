include 'emu8086.inc'
ORG 100h

.DATA
 HOUR        DW 0
 MINUTE      DW 0
 SECOND      DW 0

 menu_title   DB  'All-rounder Clock Setup', 0
 title_underbar DB '__________________________', 0
 menu_line1 DB 'Welcome to All-rounder Clock.', 0
 menu_line2 DB 'This Setup prepares All-rounder Clock to run on your computer.', 0
 menu_line3 DB 'To use Stopwatch now, press 1.', 0
 menu_line4 DB 'To quit Setup without using All-rounder, press F3.', 0
 menu_key DB  '1=Stopwatch   F3=Quit', 0
 stopwatch_text DB 'Stop Watch               ', 0
 stopwatch_key  DB 'S=Stop  R=Reset  E=Exit ', 0
 stopwatch_start    DB 'S=Start  R=Reset  E=Exit', 0

clear_screen:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0300h
    mov dx, 184Fh
    int 10h
    ret

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
    JE alarm_main
    CMP AH, 3Dh
    JE exit_program
    JMP wait_menu

exit_program:
    MOV AH, 4Ch
    INT 21h

alarm_main:
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

    CALL not_alarm_time

mainc:
    MOV AH, 01h
    INT 16h
    JZ increment_time
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
    CMP AL, 65h
    JE go_main
    JMP wait_s

go_main:
    MOV HOUR, 0
    MOV MINUTE, 0
    MOV SECOND, 0
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

not_alarm_time:
    JMP mainc

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
