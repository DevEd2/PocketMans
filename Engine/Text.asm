

; Text command definitions
TEXT_NEXT           = $80 ; print next line without without waiting for a button press
TEXT_CONT           = $81 ; wait for a button press before printing the next line
TEXT_CLEAR          = $82 ; clear textbox
TEXT_NUM            = $83 ; print a number (up to 255) from RAM
TEXT_BIGNUM         = $84 ; print a number (up to 65535) from RAM
TEXT_HUGENUM        = $85 ; print a number (up to 429467295) from RAM
TEXT_BYTE           = $86 ; print a hexadecimal number (up to FF) from RAM
TEXT_WORD           = $87 ; print a hexadecimal number (up to FFFF) from RAM
TEXT_STRING         = $88 ; print a string from ROM or RAM
TEXT_CLOSE_WINDOW   = $89 ; close the text box and finish
TEXT_PAUSE          = $8a ; temporarily stop text processing to allow script commands to run
TEXT_END            = $ff ; stop processing text without closing the text box

section "Text engine RAM",wram0

Script_Bank:        db
Script_Pointer:     dw
Text_Bank:          db
Text_Pointer:       dw
Text_Pos:           dw
Text_WindowX:       db
Text_WindowY:       db
Text_TempWindowX:   db
Text_TempWindowY:   db
Text_Width:         db
Text_Height:        db
Text_TempWidth:     db
Text_TempHeight:    db
; used in case an error occurs during script/text processing
Text_Byte:          db
Text_Word:          dw
Text_NextFlag:      db

Text_ScreenBuffer:  ds  32*32

section "Text engine",rom0

; INPUT: d = X pos
;        e = Y pos
;        b = width
;        c = height
CreateWindow:
    push    hl
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
    call    .getcolumn
    WaitForVRAM
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
    pop     hl
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
    push    af
    push    bc
    push    de
    push    hl
    xor     a
    ld      [Text_NextFlag],a
.initcoords
    ld      a,[Text_WindowX]
    inc     a
    ld      d,a
    ld      a,[Text_WindowY]
    inc     a
    ld      e,a
    call    GetScreenCoordinates
.parseloop
    ld      a,[hl]
    bit     7,a
    jr      nz,.command
    WaitForVRAM
    ld      a,[hl+]
    add     $80 - " "
    ld      [de],a
    inc     de
    rst     WaitVBlank
    jr      .parseloop
.command
    ld      a,[hl+]
    cp      $ff
    jr      z,.end
    push    hl
    ld      hl,.cmdtable
    add     a
    push    de
    ld      e,a
    ld      d,0
    add     hl,de
    pop     de
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    bit     7,h
    jr      nz,.error
    jp      hl
.error
    jr      .error
.end
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret

.cmdtable
    dw      .next
    dw      .cont
    dw      .clear
    dw      .num
    dw      .bignum
    dw      .hugenum
    dw      .byte
    dw      .word
    dw      .string
    dw      .closewindow
    dw      .pause
.next
    pop     hl
    ld      a,[Text_NextFlag]
    and     a
    jr      z,.nextline
    call    Textbox_Scroll
    jp      .parseloop
.nextline
    ld      a,1
    ld      [Text_NextFlag],a
    ld      a,e
    and     %11100000
    add     $41
    ld      e,a
    jr      nc,:+
    inc     h
:   jp      .parseloop

.cont
    pop     hl
    call    .waitforbutton
    call    Textbox_Scroll
    jp      .parseloop

.clear
    pop     hl
    push    hl
    xor     a
    ld      [Text_NextFlag],a
    ; this is the lazy way out but hey, it works
    lb      de,0,12
    lb      bc,20,6
    call    CreateWindow
    pop     hl     
    jp      .initcoords

.waitforbutton
    push    de
    push    hl
    ; draw arrow
.contloop
:   ld      a,[Text_WindowX]
    ld      b,a
    ld      a,[Text_Width]
    dec     a
    add     b
    ld      d,a
    ld      a,[Text_WindowY]
    ld      b,a
    ld      a,[Text_Height]
    dec     a
    add     b
    ld      e,a
    dec     d
    dec     e
    call    GetScreenCoordinates
    ld      h,d
    ld      l,e
    ld      a,[sys_CurrentFrame]
    bit     5,a
    jr      z,.blank
.arrow
    WaitForVRAM
    ld      a,$f3
    ld      [hl],a
    jr      :+
.blank
    WaitForVRAM
    ld      a,$80
    ld      [hl],a
:   rst     WaitVBlank
    ld      a,[sys_btnPress]
    and     _A | _B
    jr      z,.contloop
    WaitForVRAM
    ld      [hl],$80
    
    play_sfx SFXID_SELECT
	    
    pop     hl
    pop     de
    ret

    ; TODO
.num
.bignum
.hugenum
.byte
.word
.string
    pop     hl
    inc     hl
    inc     hl
    jp      .parseloop

.closewindow
    call    .waitforbutton
    pop     hl
    ; TODO
    jp      .end
    
.pause
    pop     hl
    ld      a,[sys_CurrentBank]
    ld      [Text_Bank],a
    ld      a,l
    ld      [Text_Pointer],a
    ld      a,h
    ld      [Text_Pointer+1],a
    ld      a,e
    ld      [Text_Pos],a
    ld      a,d
    ld      [Text_Pos+1],a
    ld      a,[Text_WindowX]
    ld      [Text_TempWindowX],a
    ld      a,[Text_WindowY]
    ld      [Text_TempWindowY],a
    ld      a,[Text_Width]
    ld      [Text_TempWidth],a
    ld      a,[Text_Height]
    ld      [Text_TempHeight],a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ld      hl,Script_Pointer
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    jp      RunScript.parseloop

; ========

Textbox_Scroll:
    ; temporary implementation
    ; TODO: animation
    push    hl
    push    de
    
    ; de = bottom line
    ld      a,[Text_WindowX]
    inc     a
    ld      d,a
    ld      a,[Text_WindowY]
    add     3
    ld      e,a
    call    GetScreenCoordinates
    ; hl = top line
    push    de
    ld      a,[Text_WindowX]
    inc     a
    ld      d,a
    ld      a,[Text_WindowY]
    inc     a
    ld      e,a
    call    GetScreenCoordinates
    pop     hl
    ld      b,16
:   WaitForVRAM
    ld      a,[hl]
    ld      [hl],$80
    ld      [de],a
    inc     hl
    inc     de
    dec     b
    jr      nz,:-
    
    pop     de
    pop     hl
    ld      a,e
    and     %11100000
    inc     a
    ld      e,a
    ret
    
; ========

; INPUT: b = script bank, hl = script pointer
RunScript:
    push    hl
    push    bc
    ; save screen buffer
    ld      hl,_SCRN0
    ld      de,Text_ScreenBuffer
    ld      bc,_SCRN1-_SCRN0
:   WaitForVRAM
    ld      a,[hl+]
    ld      [de],a
    inc     de
    dec     bc
    ld      a,b
    or      c
    jr      nz,:-
    pop     bc
    pop     hl
    ld      a,b
    ld      [Script_Bank],a
.parseloop
    ld      a,[Script_Bank]
    ld      b,a
    rst     Bankswitch
    ld      a,[hl+]
    cp      $ff
    jr      z,.done
    push    hl
    ld      hl,ScriptCommands
    ld      e,a
    ld      d,0
    add     hl,de
    add     hl,de
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    bit     7,h
    jr      nz,.error
    jp      hl
.done
    ; restore screen buffer
    ld      hl,Text_ScreenBuffer
    ld      de,_SCRN0
    ld      bc,_SCRN1-_SCRN0
:   WaitForVRAM
    ld      a,[hl+]
    ld      [de],a
    inc     de
    dec     bc
    ld      a,b
    or      c
    jr      nz,:-
    ret

.error
    ; TODO: Print error message
    jr      .error

ScriptCommands:
    dw      .textbox
    dw      .pic
    dw      .window
    dw      .prompt
    dw      .jz
    dw      .jeq
    dw      .jgt
    dw      .song
    dw      .sfx
    dw      .actormove
    dw      .actorwalk
    dw      .waitframes
    dw      .resume
    dw      .stopmusic
    dw      .call

.textbox
    pop     hl
    lb      de,0,12
    lb      bc,20,6
    call    CreateWindow
    ld      a,[hl+]
    ld      b,a
    rst     Bankswitch
    ld      a,[hl+]
    ld      e,a
    ld      a,[hl+]
    ld      d,a
    ld      a,l
    ld      [Script_Pointer],a
    ld      a,h
    ld      [Script_Pointer+1],a
    ld      h,d
    ld      l,e
    call    RunTextBox
    ld      hl,Script_Pointer
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    jr      RunScript.parseloop

.pic
    pop     hl
    ld      a,[hl+]
    push    af
    ld      a,[hl+]
    ld      b,a
    ld      a,[hl+]
    ld      c,a
    ld      a,[hl+]
    ld      e,a
    ld      a,[hl+]
    ld      d,a
    pop     af
    push    hl
    call    DrawMansPic
    pop     hl
    jp      RunScript.parseloop

.window
    pop     hl
    ld      a,[hl+]
    ld      d,[hl]
    inc     hl
    ld      e,a
    ld      a,[hl+]
    ld      b,[hl]
    inc     hl
    ld      c,a
    call    CreateWindow
    jp      RunScript.parseloop

.song
    pop     hl
    ld      e,[hl]
    ld      d,0
    inc     hl
    push    hl
    call    Sound_PlaySong
    pop     hl
    jp      RunScript.parseloop

.stopmusic
    call    Sound_Init
    pop     hl
    jp      RunScript.parseloop

.jz
.jeq
.jgt
    pop     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    jp      RunScript.parseloop
.prompt
.actormove
.actorwalk
.call
    pop     hl
    inc     hl
    inc     hl
    inc     hl
    jp      RunScript.parseloop
.waitframes
.sfx
    pop     hl
    ld      e,[hl]
    ld      d,0
    inc     hl
    push    hl
    call    Sound_PlaySFX
    
:   rst     WaitVBlank
    ld      a,[Sound_Flags]
    and     $f0
    jr      nz,:-
    
    pop     hl
    jp      RunScript.parseloop

.resume
    pop     hl
    push    af
    push    bc
    push    de
    push    hl
    ld      a,l
    ld      [Script_Pointer],a
    ld      a,h
    ld      [Script_Pointer+1],a
    ld      a,[Text_TempWindowX]
    ld      [Text_WindowX],a
    ld      a,[Text_TempWindowY]
    ld      [Text_WindowY],a
    ld      a,[Text_TempWidth]
    ld      [Text_Width],a
    ld      a,[Text_TempHeight]
    ld      [Text_Height],a
    ld      a,[Text_Bank]
    ld      b,a
    rst     Bankswitch
    ld      hl,Text_Pos
    ld      a,[hl+]
    ld      d,[hl]
    ld      e,a
    ld      hl,Text_Pointer
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    jp      RunTextBox.parseloop
    
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
