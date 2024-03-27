; Kristine Jewel B. Malimban

.model small
.stack 100h
.data
    promptStart db "Greetings! You are about to play Isagani Game!","$"
    promptAiMove01 db "  AI moves from ", "$"
    promptMoveCount db "  Number of moves: ", "$"
    promptSequence db "  Sequence ", "$"
    promptAiMove02 db " to ", "$"
    promptPlayerWins db "  Congratulations! You win!", "$"
    promptEnter db "  Press enter...", "$"
    promptAiWins db "  Too bad! Computer wins!", "$"
    promptName db "Enter your name: ","$"
    prompt db "  Your move.","$"
    promptMoveFrom db "  From: ","$"
    promptMoveTo db "  To: ","$"
    promptToken db "Your token: ","$"
    promptInvalid db "  Invalid move!", "$"
    gameTitle db "  Isagani Game Board","$"
    arrayBoard1 db "[X]-\-[X]-/-[X]", "$"
    arrayBoard2 db "[ ]---[ ]---[ ]", "$"
    arrayBoard3 db "[O]-/-[O]-\-[O]", "$"
    divider db "      |     |     |", "$"
    letters db "      a.    b.    c.", "$"
    empty db " ", "$"
    buffer db 0
    seqNumber dw ?
    one db "1.", "$"
    two db "2.", "$"
    three db "3.", "$"
    newline db 13, 10, "$"
    nameInput db 26, ?, 26 dup("$")
    inputT1 db ?
    inputT2 db ?
    inputF1 db ?
    inputF2 db ?
    playerInputT1 db ?
    playerInputT2 db ?
    playerInputF1 db ?
    playerInputF2 db ?
    win db 0
    win_ai db 0
    place01 db ?
    place02 db ?
    place03 db ?
    place04 db ?
    place05 db ?
    place06 db ?
    place07 db ?
    place08 db ?
    place09 db ?
    is_empty_bool db ?
    inp1 db ?
    inp2 db ?
    invalid_bool db ?
    invalid_bool_ai db ?
    valid_move_bool db ?
    valid_move_bool_ai db ?
    player_token_bool db 0
    ai_token db 0
    ai_avail db 0
    ai_token01 db 0
    ai_token02 db 0
    ai_token03 db 0
    ai_token_from1 db ?
    ai_token_to1 db ?
    ai_token_from2 db ?
    ai_token_to2 db ?
    randomNum db 0
    empty_spot1 db 0
    empty_spot2 db 0
    empty_spot3 db 0
    movesCounter dw 1
    aimovesCounter dw 1
    token1_maxmove db ?
    token2_maxmove db ?
    token3_maxmove db ?
    preferred_move db ?


.code
    print_space proc near
    mov dl, 32
    mov ah, 02h
    int 21h
    ret
    print_space endp

    new_line proc near
    lea dx, newline
    mov ah, 09h
    int 21h
    ret
    new_line endp

    number_printer proc near
    mov bx, 10          ;CONST
    xor cx, cx          ;Reset counter
    
    @first: 
    xor dx, dx          ;Setup for division DX:AX / BX
    div bx              ; -> AX is Quotient, Remainder DX=[0,9]
    push dx             ;(1) Save remainder for now
    inc cx              ;One more digit
    test ax, ax         ;Is quotient zero?
    jne @first          ;No, use as next dividend
    @second: 
    pop dx              ;(1)
    
    mov ah, 02h         ;DOS.DisplayCharacter
    add dl, "0"
    int 21h             ; -> AL
    loop @second

    ret
    number_printer endp

    sequence_printer proc near
    lea dx, promptSequence
    mov ah, 09h
    int 21h

    mov ax, seqNumber
    call number_printer

    mov dl, '.'
    mov ah, 02h
    int 21h

    ret
    sequence_printer endp

    press_enter proc near
    mov ah, 09h
    lea dx, promptEnter
    int 21h
    wait_for_enter:
        mov ah, 01h
        int 21h
        cmp al, 0Dh ; Check if Enter key is pressed
        jne wait_for_enter
    ret
    press_enter endp
   
    board_printer proc near
    call new_line
    call new_line

    lea dx, letters
    mov ah, 09h
    int 21h
    call new_line

    call print_space
    call print_space
    lea dx, one
    mov ah, 09h
    int 21h
    call print_space
    lea dx, arrayBoard1
    mov ah, 09h
    int 21h
    call new_line
    
    lea dx, divider
    mov ah, 09h
    int 21h
    call new_line


    call print_space
    call print_space
    lea dx, two
    mov ah, 09h
    int 21h
    call print_space
    lea dx, arrayBoard2
    mov ah, 09h
    int 21h
    call new_line
    

    lea dx, divider
    mov ah, 09h
    int 21h
    call new_line

    call print_space
    call print_space
    lea dx, three
    mov ah, 09h
    int 21h
    call print_space
    lea dx, arrayBoard3
    mov ah, 09h
    int 21h
    call new_line
    call new_line
    call new_line


    ret
    board_printer endp
    
    player_token_check proc near
    .if bl == 'O'
        mov player_token_bool, 01
    .endif
    ret
    player_token_check endp

    valid_move proc near
    ; 2 8 14
    .if playerInputF1 == 'a' && playerInputF2 == '1'
        .if playerInputT1 == 'a' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'b' && playerInputF2 == '1'
        .if playerInputT1 == 'a' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'c' && playerInputF2 == '1'
        .if playerInputT1 == 'b' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'a' && playerInputF2 == '2'
        .if playerInputT1 == 'a' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'a' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'b' && playerInputF2 == '2'
        .if playerInputT1 == 'a' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'a' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'a' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'c' && playerInputF2 == '2'
        .if playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '1'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'a' && playerInputF2 == '3'
        .if playerInputT1 == 'a' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'b' && playerInputF2 == '3'
        .if playerInputT1 == 'a' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .else
            mov valid_move_bool, 00
        .endif
    .elseif playerInputF1 == 'c' && playerInputF2 == '3'
        .if playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '3'
            mov valid_move_bool, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '2'
            mov valid_move_bool, 01
        .else
           mov valid_move_bool, 00
        .endif
    .endif

    ret
    valid_move endp

    invalid_movement proc near
    .if invalid_bool == 01
        call new_line
        call new_line
        lea dx, promptInvalid
        mov ah, 09h
        int 21h
        call new_line
        call new_line
        call player_move
    .endif
    ret
    invalid_movement endp

    is_empty proc near
    .if bl == ' '
        mov is_empty_bool, 01
    .else
        mov is_empty_bool, 00
    .endif
    ret
    is_empty endp

    move_cond proc near
    .if bl == 'a' && bh == '1'
        lea si, arrayBoard1
        add si, 1
    .elseif bl == 'b' && bh == '1'
        lea si, arrayBoard1
        add si, 7
    .elseif bl == 'c' && bh == '1'
        lea si, arrayBoard1
        add si, 13
    .elseif bl == 'a' && bh == '2'
        lea si, arrayBoard2
        add si, 1
    .elseif bl == 'b' && bh == '2'
        lea si, arrayBoard2
        add si, 7
    .elseif bl == 'c' && bh == '2'
        lea si, arrayBoard2
        add si, 13
    .elseif bl == 'a' && bh == '3'
        lea si, arrayBoard3
        add si, 1
    .elseif bl == 'b' && bh == '3'
        lea si, arrayBoard3
        add si, 7
    .elseif bl == 'c' && bh == '3'
        lea si, arrayBoard3
        add si, 13
    .else   
        mov invalid_bool, 01
    .endif

    ret

    move_cond endp 
    
    winner proc near
    lea si, arrayBoard1
    add si, 1
    mov bl, [si]
    mov place01, bl
    add si, 6
    mov bl, [si]
    mov place02, bl
    add si, 6
    mov bl, [si]
    mov place03, bl

    lea si, arrayBoard2
    add si, 1
    mov bl, [si]
    mov place04, bl
    add si, 6
    mov bl, [si]
    mov place05, bl
    add si, 6
    mov bl, [si]
    mov place06, bl

    lea si, arrayBoard3
    add si, 1
    mov bl, [si]
    mov place07, bl
    add si, 6
    mov bl, [si]
    mov place08, bl
    add si, 6
    mov bl, [si]
    mov place09, bl

    .if place01 == 'O' && place02 == 'O' && place03 == 'O'
        mov win, 1
    .elseif place04 == 'O' && place05 == 'O' && place06 == 'O'
        mov win, 1
    .elseif place01 == 'O' && place04 == 'O' && place07 == 'O'
        mov win, 1
    .elseif place02 == 'O' && place05 == 'O' && place08 == 'O'
        mov win, 1
    .elseif place03 == 'O' && place06 == 'O' && place09 == 'O'
        mov win, 1
    .elseif place01 == 'O' && place05 == 'O' && place09 == 'O'
        mov win, 1
    .elseif place07 == 'O' && place05 == 'O' && place03 == 'O'
        mov win, 1
    .else
        mov win, 0
    .endif
    ret
    winner endp

    player_move proc near
    xor bl, bl
    xor bh, bh
    mov invalid_bool, 00
    mov player_token_bool, 00

    lea dx, prompt
    mov ah, 09h
    int 21h

    call new_line

    lea dx, promptMoveFrom
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    mov inputF1, al

    mov ah, 01h
    int 21h
    mov inputF2, al

    call new_line
 
    lea dx, promptMoveTo
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    mov inputT1, al

    mov ah, 01h
    int 21h
    mov inputT2, al

    call new_line

    mov bl, inputF1
    mov bh, inputF2
    
    call move_cond

    mov bl, [si]
    call is_empty
    call player_token_check

    mov bl, inputF1
    mov bh, inputF2
    mov playerInputF1, bl
    mov playerInputF2, bh 


    mov bl, inputT1
    mov bh, inputT2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call valid_move
    .if is_empty_bool == 1 || valid_move_bool == 00 || player_token_bool == 00
        mov invalid_bool, 01
        mov dl, empty
        xchg [si], dl
    .elseif is_empty_bool == 0 && valid_move_bool == 01 && player_token_bool == 01
        mov dl, empty
        xchg [si], dl
    .endif

    mov bl, inputT1
    mov bh, inputT2

    call move_cond
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01 && valid_move_bool == 01 && player_token_bool == 01;if empty
        xchg dl, [si]
    .elseif is_empty_bool == 00 || valid_move_bool == 00 || player_token_bool == 00
        mov bl, inputF1
        mov bh, inputF2
        call move_cond
        xchg dl, [si]
        mov invalid_bool, 01
    .endif
    
    call invalid_movement

    ret 
    player_move endp

    ai_valid_move proc near
    ; 2 8 14
    .if playerInputF1 == 'a' && playerInputF2 == '1'
        .if playerInputT1 == 'a' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'b' && playerInputF2 == '1'
        .if playerInputT1 == 'a' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'c' && playerInputF2 == '1'
        .if playerInputT1 == 'b' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'a' && playerInputF2 == '2'
        .if playerInputT1 == 'a' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'a' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'b' && playerInputF2 == '2'
        .if playerInputT1 == 'a' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'a' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'a' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'c' && playerInputF2 == '2'
        .if playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '1'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'a' && playerInputF2 == '3'
        .if playerInputT1 == 'a' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'b' && playerInputF2 == '3'
        .if playerInputT1 == 'a' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .elseif playerInputF1 == 'c' && playerInputF2 == '3'
        .if playerInputT1 == 'b' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'b' && playerInputT2 == '3'
            mov valid_move_bool_ai, 01
        .elseif playerInputT1 == 'c' && playerInputT2 == '2'
            mov valid_move_bool_ai, 01
        .else
            mov valid_move_bool_ai, 00
        .endif
    .else   
        mov invalid_bool_ai, 01
    .endif

    ret
    ai_valid_move endp

    ai_move_cond proc near
    .if bl == 'a' && bh == '1'
        lea si, arrayBoard1
        add si, 1
    .elseif bl == 'b' && bh == '1'
        lea si, arrayBoard1
        add si, 7
    .elseif bl == 'c' && bh == '1'
        lea si, arrayBoard1
        add si, 13
    .elseif bl == 'a' && bh == '2'
        lea si, arrayBoard2
        add si, 1
    .elseif bl == 'b' && bh == '2'
        lea si, arrayBoard2
        add si, 7
    .elseif bl == 'c' && bh == '2'
        lea si, arrayBoard2
        add si, 13
    .elseif bl == 'a' && bh == '3'
        lea si, arrayBoard3
        add si, 1
    .elseif bl == 'b' && bh == '3'
        lea si, arrayBoard3
        add si, 7
    .elseif bl == 'c' && bh == '3'
        lea si, arrayBoard3
        add si, 13
    .else   
        mov invalid_bool_ai, 01
    .endif

    ret

    ai_move_cond endp 
    
    invalid_movement_ai proc near
    .if invalid_bool_ai == 01
        call ai_move
    .endif
    ret
    invalid_movement_ai endp

    ai_from proc near
    .if bl == 'X'
        mov ai_token, 01
    .else
        mov ai_token, 00
    .endif
    ret
    ai_from endp
    
    ai_movement proc near
    mov ai_token01, 0
    mov ai_token02, 0
    mov ai_token03, 0
    lea si, arrayBoard1
    add si, 1
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        mov ai_token01, 01
    .endif
    add si, 6
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 02
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 02
            .elseif ai_token02 > 0
                mov ai_token03, 02
            .endif
        .endif 
    .endif

    add si, 6
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 03
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 03
            .elseif ai_token02 > 0
                mov ai_token03, 03
            .endif
        .endif 
    .endif
    lea si, arrayBoard2
    add si, 1
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 04
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 04
            .elseif ai_token02 > 0
                mov ai_token03, 04
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 05
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 05
            .elseif ai_token02 > 0
                mov ai_token03, 05
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 06
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 06
            .elseif ai_token02 > 0
                mov ai_token03, 06
            .endif
        .endif 
    .endif

    lea si, arrayBoard3
    add si, 1
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 07
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 07
            .elseif ai_token02 > 0
                mov ai_token03, 07
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 08
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 08
            .elseif ai_token02 > 0
                mov ai_token03, 08
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call ai_from
    .if ai_token == 01
        .if ai_token01 == 0
            mov ai_token01, 09
        .elseif ai_token01 > 0
            .if ai_token02 == 0
                mov ai_token02, 09
            .elseif ai_token02 > 0
                mov ai_token03, 09
            .endif
        .endif 
    .endif


    ret
    ai_movement endp

    empty_spots proc near
    mov empty_spot1, 0
    mov empty_spot2, 0
    mov empty_spot3, 0
    lea si, arrayBoard1
    add si, 1
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 01
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 01
            .elseif empty_spot2 > 0
                mov empty_spot3, 01
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 02
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 02
            .elseif empty_spot2 > 0
                mov empty_spot3, 02
            .endif
        .endif 
    .endif

    add si, 6
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 03
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 03
            .elseif empty_spot2 > 0
                mov empty_spot3, 03
            .endif
        .endif 
    .endif
    lea si, arrayBoard2
    add si, 1
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 04
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 04
            .elseif empty_spot2 > 0
                mov empty_spot3, 04
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 05
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 05
            .elseif empty_spot2 > 0
                mov empty_spot3, 05
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 06
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 06
            .elseif empty_spot2 > 0
                mov empty_spot3, 06
            .endif
        .endif 
    .endif

    lea si, arrayBoard3
    add si, 1
    mov bl, [si]
    call ai_from
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 07
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 07
            .elseif empty_spot2 > 0
                mov empty_spot3, 07
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 08
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 08
            .elseif empty_spot2 > 0
                mov empty_spot3, 08
            .endif
        .endif 
    .endif
    add si, 6
    mov bl, [si]
    call is_empty
    .if is_empty_bool == 01
        .if empty_spot1 == 0
            mov empty_spot1, 09
        .elseif empty_spot1 > 0
            .if empty_spot2 == 0
                mov empty_spot2, 09
            .elseif empty_spot2 > 0
                mov empty_spot3, 09
            .endif
        .endif 
    .endif


    ret
    empty_spots endp

    genRandomNum proc near
    call delay
    call delay
    mov ah, 0
    int 1ah

    mov ax, dx
    mov dx, 0
    mov bx, 3
    div bx
    mov randomNum, dl
    ret
    genRandomNum endp

    delay proc near
        xor cx, cx
        mov cx, 1
    startDelay:
        cmp cx, 30000
        JE endDelay
        inc cx
        JMP startDelay
    endDelay:
        ret
    delay endp

    ai_move_condfrom proc near
    .if bl == 01
        mov ai_token_from1, 'a'
        mov ai_token_from2, '1'
    .elseif bl == 02
        mov ai_token_from1, 'b'
        mov ai_token_from2, '1'
    .elseif bl == 03
        mov ai_token_from1, 'c'
        mov ai_token_from2, '1'
    .elseif bl == 04
        mov ai_token_from1, 'a'
        mov ai_token_from2, '2'
    .elseif bl == 05
        mov ai_token_from1, 'b'
        mov ai_token_from2, '2'
    .elseif bl == 06
        mov ai_token_from1, 'c'
        mov ai_token_from2, '2'
    .elseif bl == 07
        mov ai_token_from1, 'a'
        mov ai_token_from2, '3'
    .elseif bl == 08
        mov ai_token_from1, 'b'
        mov ai_token_from2, '3'
    .elseif bl == 09
        mov ai_token_from1, 'c'
        mov ai_token_from2, '3'
    .else   
        mov invalid_bool, 01
    .endif
    ret
    ai_move_condfrom endp

    ai_move_condto proc near
    .if bh == 01
        mov ai_token_to1, 'a'
        mov ai_token_to2, '1'
    .elseif bh == 02
        mov ai_token_to1, 'b'
        mov ai_token_to2, '1'
    .elseif bh == 03
        mov ai_token_to1, 'c'
        mov ai_token_to2, '1'
    .elseif bh == 04
        mov ai_token_to1, 'a'
        mov ai_token_to2, '2'
    .elseif bh == 05
        mov ai_token_to1, 'b'
        mov ai_token_to2, '2'
    .elseif bh == 06
        mov ai_token_to1, 'c'
        mov ai_token_to2, '2'
    .elseif bh == 07
        mov ai_token_to1, 'a'
        mov ai_token_to2, '3'
    .elseif bh == 08
        mov ai_token_to1, 'b'
        mov ai_token_to2, '3'
    .elseif bh == 09
        mov ai_token_to1, 'c'
        mov ai_token_to2, '3'
    .else   
        mov invalid_bool, 01
    .endif
    ret
    ai_move_condto endp

    max_aitoken1 proc near

    mov bl, ai_token01
    mov bh, empty_spot1
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        mov token1_maxmove, 01
    .endif

    mov bl, ai_token01
    mov bh, empty_spot2
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        add token1_maxmove, 01
    .endif

    mov bl, ai_token01
    mov bh, empty_spot3
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        add token1_maxmove, 01
    .endif
    ret
    max_aitoken1 endp
    
    max_aitoken2 proc near

    mov bl, ai_token02
    mov bh, empty_spot1
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        mov token2_maxmove, 01
    .endif

    mov bl, ai_token02
    mov bh, empty_spot2
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        add token2_maxmove, 01
    .endif

    mov bl, ai_token02
    mov bh, empty_spot3
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        add token2_maxmove, 01
    .endif
    ret
    max_aitoken2 endp
    
    max_aitoken3 proc near
    mov bl, ai_token03
    mov bh, empty_spot1
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        mov token3_maxmove, 01
    .endif

    mov bl, ai_token03
    mov bh, empty_spot2
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        add token3_maxmove, 01
    .endif

    mov bl, ai_token03
    mov bh, empty_spot3
    call ai_move_condfrom
    call ai_move_condto

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move
    .if valid_move_bool_ai == 01
        add token3_maxmove, 01
    .endif
    ret
    max_aitoken3 endp

    ai_move proc near
    mov token1_maxmove, 0
    mov token2_maxmove, 0
    mov token3_maxmove, 0
    xor bl, bl
    xor bh, bh
    mov invalid_bool_ai, 00
    call ai_movement
    call empty_spots
    call max_aitoken1
    call max_aitoken2
    call max_aitoken3   
    mov bl, token2_maxmove
    mov bh, token3_maxmove

    .if token1_maxmove >= bl && token1_maxmove >= bh
        mov preferred_move, 01
    .elseif bl >= token1_maxmove && bl >= bh
        mov preferred_move, 02
    .elseif bh >= token1_maxmove && bh >= bl
        mov preferred_move, 03
    .endif

    .if preferred_move == 01
        mov bl, ai_token01
        call ai_move_condfrom
        call empty_spots
        call genRandomNum
        .if randomNum == 0
            mov bh, empty_spot1
            call ai_move_condto
        .elseif randomNum == 1
            mov bh, empty_spot2
            call ai_move_condto
        .elseif randomNum == 2
            mov bh, empty_spot3
            call ai_move_condto
        .endif
        
    .elseif preferred_move == 02
        mov bl, ai_token02
        call ai_move_condfrom
        call empty_spots
        call genRandomNum
        .if randomNum == 0
            mov bh, empty_spot1
            call ai_move_condto
        .elseif randomNum == 1
            mov bh, empty_spot2
            call ai_move_condto
        .elseif randomNum == 2
            mov bh, empty_spot3
            call ai_move_condto
        .endif

    .elseif preferred_move == 03
        mov bl, ai_token03
        call ai_move_condfrom
        call empty_spots
        call genRandomNum
        .if randomNum == 0
            mov bh, empty_spot1
            call ai_move_condto
        .elseif randomNum == 1
            mov bh, empty_spot2
            call ai_move_condto
        .elseif randomNum == 2
            mov bh, empty_spot3
            call ai_move_condto
        .endif

    .endif

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    
    call ai_move_cond

    mov bl, ai_token_from1
    mov bh, ai_token_from2
    mov playerInputF1, bl
    mov playerInputF2, bh 

    mov bl, ai_token_to1
    mov bh, ai_token_to2
    mov playerInputT1, bl
    mov playerInputT2, bh 

    call ai_valid_move

    .if valid_move_bool_ai == 01
        mov dl, empty
        xchg [si], dl
        mov bl, ai_token_to1
        mov bh, ai_token_to2

        call ai_move_cond
        xchg dl, [si]
    .elseif valid_move_bool_ai == 00
        mov invalid_bool_ai, 01
    .endif

    call invalid_movement_ai
    ret

    ai_move endp

    ai_printer proc near
    lea dx, promptAiMove01
    mov ah, 09h
    int 21h

    mov dl, ai_token_from1
    mov ah, 02h
    int 21h

    mov dl, ai_token_from2
    mov ah, 02h
    int 21h

    lea dx, promptAiMove02
    mov ah, 09h
    int 21h

    mov dl, ai_token_to1
    mov ah, 02h
    int 21h

    mov dl, ai_token_to2
    mov ah, 02h
    int 21h

    mov dl, '.'
    mov ah, 02h
    int 21h
    ret
    ai_printer endp

    winner_ai proc near
    lea si, arrayBoard1
    add si, 1
    mov bl, [si]
    mov place01, bl
    add si, 6
    mov bl, [si]
    mov place02, bl
    add si, 6
    mov bl, [si]
    mov place03, bl

    lea si, arrayBoard2
    add si, 1
    mov bl, [si]
    mov place04, bl
    add si, 6
    mov bl, [si]
    mov place05, bl
    add si, 6
    mov bl, [si]
    mov place06, bl

    lea si, arrayBoard3
    add si, 1
    mov bl, [si]
    mov place07, bl
    add si, 6
    mov bl, [si]
    mov place08, bl
    add si, 6
    mov bl, [si]
    mov place09, bl

    .if place04 == 'X' && place05 == 'X' && place06 == 'X'
        mov win_ai, 1
    .elseif place07 == 'X' && place08 == 'X' && place09 == 'X'
        mov win_ai, 1
    .elseif place01 == 'X' && place04 == 'X' && place07 == 'X'
        mov win_ai, 1
    .elseif place02 == 'X' && place05 == 'X' && place08 == 'X'
        mov win_ai, 1
    .elseif place03 == 'X' && place06 == 'X' && place09 == 'X'
        mov win_ai, 1
    .elseif place01 == 'X' && place05 == 'X' && place09 == 'X'
        mov win_ai, 1
    .elseif place07 == 'X' && place05 == 'X' && place03 == 'X'
        mov win_ai, 1
    .else
        mov win_ai, 0
    .endif
    ret
    winner_ai endp
    
    main proc near

    ; Initializing data
    mov ax, @data
    mov ds, ax
    mov bh, 00

    lea dx, promptStart
    mov ah, 09h
    int 21h

    call new_line
    call new_line
    mov movesCounter, 1
    mov aimovesCounter, 1
    mov seqNumber, 1
    
    .while win_ai < 01 && win <01
        call sequence_printer

        call board_printer

        call winner_ai

        .if win_ai == 1
            lea dx, promptAiWins
            mov ah, 09h
            int 21h

            call new_line

            lea dx, promptMoveCount
            mov ah, 09h
            int 21h

            mov ax, movesCounter
            call number_printer
            jmp @byebye

        .elseif win == 1
            lea dx, promptPlayerWins
            mov ah, 09h
            int 21h

            call new_line

            lea dx, promptMoveCount
            mov ah, 09h
            int 21h

            mov ax, aimovesCounter
            call number_printer
            jmp @byebye
        .endif
        
        call player_move

        call press_enter

        call new_line

        inc movesCounter

        inc seqNumber

        call sequence_printer

        call board_printer
        

        call winner

        .if win_ai == 1
            lea dx, promptAiWins
            mov ah, 09h
            int 21h

            call new_line

            lea dx, promptMoveCount
            mov ah, 09h
            int 21h

            mov ax, movesCounter
            call number_printer
            jmp @byebye

        .elseif win == 1
            lea dx, promptPlayerWins
            mov ah, 09h
            int 21h

            call new_line

            lea dx, promptMoveCount
            mov ah, 09h
            int 21h

            mov ax, aimovesCounter
            call number_printer
            jmp @byebye
        .endif

        call ai_move
        ; call new_line
        ; mov ah, 02h
        ; mov dl, token1_maxmove
        ; add dl, '0'
        ; int 21h
        ; call new_line
        ; mov ah, 02h
        ; mov dl, token2_maxmove
        ; add dl, '0'
        ; int 21h
        ; call new_line
        ; mov ah, 02h
        ; mov dl, token3_maxmove
        ; add dl, '0'
        ; int 21h
        ; call new_line

        call ai_printer 

        call new_line

        call press_enter

        inc aimovesCounter

        call new_line

        inc seqNumber

        call new_line
    .endw

    
    @byebye:
    mov ax, 4c00h
    int 21h

    main endp
end main