.model small
.stack 100h
.data
    brick db 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, '$'
    bar   db '[==========]', '$'
    ball  db 'O', '$'
    blank db ' ', '$'
    
    ball_x db 40    ; 공 x위치
    ball_y db 15    ; 공 y위치
    ball_dx db 1    ; x방향 (+1 오른쪽)
    ball_dy db 0FFh ; y방향 (-1 위쪽, 부호없는 바이트라 FFh=-1)

.code
main proc
    mov ax, @data
    mov ds, ax

    ; === 벽돌 그리기 (row 0~7) ===
    ; === row 0 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h     
    ; === row 1 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    ; === row 2 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h      
    ; === row 3 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    ; === row 4 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    ; === row 5 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    ; === row 6 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 6
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 6
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 6
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 6
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 6
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 6
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    ; === row 7 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 2
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h    
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 15
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h         
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 28
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 41
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 54
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h       
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 67
    int 10h
    mov ah, 09h
    lea dx, brick
    int 21h   

    ; === 바 그리기 ===
    mov ah, 02h
    mov bh, 0
    mov dh, 22
    mov dl, 34
    int 10h
    mov ah, 09h
    lea dx, bar
    int 21h

; =====================
; === 게임 루프 ===
; =====================
game_loop:
    ; 1. 이전 위치의 공 지우기 (잔상 제거)
    mov ah, 02h
    mov bh, 0
    mov dh, [ball_y]
    mov dl, [ball_x]
    int 10h
    mov ah, 09h
    lea dx, blank
    int 21h

    ; 2. 좌표 업데이트 (x, y 이동)
    mov al, [ball_x]
    add al, [ball_dx]
    mov [ball_x], al

    mov al, [ball_y]
    add al, [ball_dy]
    mov [ball_y], al

    ; 3. 좌우 벽 충돌 판정
    mov al, [ball_x]
    cmp al, 0
    jle bounce_x
    cmp al, 79      ; 표준 80컬럼 모드 기준
    jge bounce_x
    jmp check_y

bounce_x:
    neg [ball_dx]    ; x방향 반전
    ; 벽 밖으로 나가지 않게 보정 (선택사항)
    jmp check_y

check_y:
    ; 4. 상하 벽 충돌 판정
    mov al, [ball_y]
    cmp al, 0
    jle bounce_y
    cmp al, 23     ; 표준 25라인 모드 기준
    jge bounce_y
    jmp draw_ball

bounce_y:
    neg [ball_dy]    ; y방향 반전
    jmp draw_ball

draw_ball:
    ; 5. 새 위치에 공 그리기
    mov ah, 02h
    mov bh, 0
    mov dh, [ball_y]
    mov dl, [ball_x]
    int 10h
    mov ah, 09h
    lea dx, ball
    int 21h

    ; 6. 딜레이 루프 (CX만 사용하여 충돌 방지)
    ; DOSBox 사이클이 빠르면 0Ah~14h 정도로 높이시고, 느리면 01h로 낮추세요.
    mov cx, 05h       
delay_outer:
    push cx             ; 바깥쪽 CX 보존
    mov cx, 0001h      ; 안쪽 루프 카운트
                   delay_inner:
    loop delay_inner
    pop cx              ; 바깥쪽 CX 복구
    loop delay_outer

    ; 7. 키보드 입력 체크 (게임 종료용)
    mov ah, 01h         ; 버퍼에 키가 있는지 확인 (Non-blocking)
    int 16h
    jz game_loop        ; 입력 없으면 루프 계속

    mov ah, 00h         ; 버퍼에서 키 읽기
    int 16h
    cmp al, 1Bh         ; ESC 키(1Bh)인가?
    je exit_game
    jmp game_loop       ; 다른 키면 계속 진행

exit_game:
    mov ax, 4C00h       ; 프로그램 안전 종료
    int 21h

main endp
end main