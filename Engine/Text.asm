; Script command definitions
macro script_text
    db  $0
    db  bank(\1)
    dw  \1
endm

; script_disp_pic ptr,x,y
macro script_disp_pic
    db  $1
    db  bank(\3)
    dw  \3
    db  \1
    db  \2
endm

; script_create_window x,y,w,h
macro script_create_window
    db  $2
    db  \1
    db  \2
    db  \3
    db  \4
endm

; script_prompt varaiable,type
macro script_prompt
    db  $3
    dw  \1
    db  \2
endm

; script_jump_if_zero var,script
macro script_jump_if_zero
    db  $4
    dw  \1
    dw  \2
endm

; script_jump_if_equal num,var,script
macro script_jump_if_equal
    db  $5
    db  \1
    dw  \2
    dw  \3
endm

; script_jump_if_greater num,var,script
macro script_jump_if_greater
    db  $6
    db  \1
    dw  \2
    dw  \3
endm

; script_play_song ptr
macro script_play_song
    db  $7
    db  bank(\1)
    dw  \1
    endm

; script_play_sfx id
macro script_play_sfx
    db  $8
    db  bank(\1)
    dw  \1
    endm

; script_actor_move num,x,y
macro script_actor_move
    db  $9
    db  \1
    db  \2
    db  \3
endm

; script_actor_walk num,dir,dist
macro script_actor_walk
    db  $a
    db  \1
    db  ((\2 & 3) << 6) | (\3 & 64)
endm

; script_wait_frames num
macro script_wait_frames
    db  $b
    db  \1
endm
    
; script_asm_call addr
macro script_asm_call
    db  $f
    db  bank(\1)
    dw  \1
endm

script_end = $ff

; Text command definitions
TEXT_NEXT           = $80 ; print next line
TEXT_CONT           = $81 ; continue
TEXT_CLEAR          = $82 ; clear textbox before printing next line
TEXT_NUM            = $83 ; print a number (up to 255) from RAM
TEXT_BIGNUM         = $84 ; print a number (up to 65535) from RAM
TEXT_HUGENUM        = $85 ; print a number (up to 429467295) from RAM
TEXT_BYTE           = $86 ; print a hexadecimal number (up to FF) from RAM
TEXT_WORD           = $87 ; print a hexadecimal number (up to FFFF) from RAM
TEXT_STRING         = $88 ; print a string from ROM or RAM
TEXT_PROMPT_TOGGLE  = $89 ; toggle whether or not to wait for a button press before printing next line
TEXT_END            = $ff ; finished; close text box

section "Text engine RAM",wram0
Text_Bank:      db
Text_Pointer:   dw
Text_Mode:      db
Text_WindowX:   db
Text_WindowY:   db
Text_Width:     db
Text_Height:    db
; used in case an error occurs during script/text processing
Text_Byte:      db
Text_Word:      dw

section "Text engine",rom0

; INPUT: d = X pos
;        e = Y pos
;        b = width
;        c = height
CreateWindow:
    ld      a,d
    ld      [Text_WindowX],a
    ld      a,e
    ld      [Text_WindowY],a
    call    GetScreenCoordinates
    ld      a,b
    ld      [Text_Width],a
    ld      a,c
    ld      [Text_Height],a
    ld      bc,0
.loop
    ; get tile
    ld      a,c
    and     a
    jr      z,.toprow
    ld      h,a
    ld      a,[Text_Height]
    dec     a
    cp      h
    jr      z,.bottomrow
    ; default case: middle row
.middlerow
    ld      hl,TextBoxTileDefinitions.middle
    WaitForVRAM
    call    .getcolumn
    ld      a,[hl]
    ld      [de],a
    inc     de
    jr      .next
.toprow
    ld      hl,TextBoxTileDefinitions.top
    call    .getcolumn
    WaitForVRAM
    ld      a,[hl]
    ld      [de],a
    inc     de
    jr      .next
.bottomrow
    ld      hl,TextBoxTileDefinitions.bottom
    call    .getcolumn
    WaitForVRAM
    ld      a,[hl]
    ld      [de],a
    inc     de
    jr      .next
.next
    inc     b
    ld      a,[Text_Width]
    cp      b
    jr      nz,.loop
    ld      b,0
    ld      a,[Text_Width]
    ld      h,a
    ld      a,e
    sub     h
    ld      e,a
    jr      nc,:+
    dec     d
:   ld      hl,$20
    add     hl,de
    ld      d,h
    ld      e,l
    inc     c
    ld      a,[Text_Height]
    cp      c
    jr      nz,.loop
    ret

.getcolumn
    ld      a,b
    and     a
    ret     z
    ld      a,[Text_Width]
    dec     a
    cp      b
    jr      nz,.rightcolumn
    inc     hl
.rightcolumn
    inc     hl
    ret

TextBoxTileDefinitions:
.top    db  $eb,$ec,$ed
.middle db  $ee,$80,$ef
.bottom db  $f0,$f1,$f2

RunTextBox:
    ret

RunScript:
    ret

section "Text engine error messages",romx
Text_Err_UnkTextCommand:
;        ##################
    db  "Unknown text cmd",TEXT_NEXT
    dbw TEXT_BYTE,Text_Byte
    db  TEXT_END

Text_Err_UnkScriptCommand:
;        ##################
    db  "Unknown script cmd",TEXT_NEXT
    dbw TEXT_BYTE,Text_Byte
    db  TEXT_END

Text_Err_BadActor:
;        ##################
    db  "Invalid actor ID",TEXT_NEXT
    dbw TEXT_BYTE,Text_Byte
    db  TEXT_END

Text_Err_BadCall:
;        ##################
    db  "Invalid ASM call",TEXT_NEXT
    dbw TEXT_WORD,Text_Word
    db  TEXT_END