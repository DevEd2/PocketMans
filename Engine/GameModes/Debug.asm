if DebugMode

section fragment "WRAM defines",wram0
Debug_MenuPos:  db
Debug_MenuMax:  db
Debug_MenuYPos: db
Debug_PicTest:  db

section "Debug menu routines",rom0

GM_Debug:
    ldh     a,[rLCDC]
    bit     7,a
    jr      z,:+
    rst     WaitVBlank
    xor     a
    ldh     [rLCDC],a
:   ld      hl,Font
    ld      de,_VRAM8800
    call    DecodeWLE
    
    ld      hl,Debug_MainMenuText
    ld      de,_SCRN0
    call    LoadTilemapText
    
    ld      a,48
    ld      [Debug_MenuYPos],a
    
    ld      a,NUM_DEBUG_ITEMS
    ld      [Debug_MenuMax],a
    xor     a
    ld      [Debug_MenuPos],a
    
    ld      a,LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh     [rLCDC],a
    ld      a,IEF_VBLANK
    ldh     [rIE],a
    ei    
    
DebugLoop:
    xor     a
    ldh     [rSCX],a
    ldh     [rSCY],a

    ld      a,[sys_btnPress]
    bit     btnUp,a
    jr      z,.checkdown
    ; PlaySFX menucursor
    ld      hl,Debug_MenuPos
    dec     [hl]
    ld      a,[hl]
    cp      $ff
    jr      nz,.drawcursor
    ld      a,[Debug_MenuMax]
    ld      [hl],a
    jr      .drawcursor

.checkdown
    bit     btnDown,a
    jr      z,.checkA
    ; PlaySFX menucursor
    ld      hl,Debug_MenuPos
    inc     [hl]
    ld      b,[hl]
    ld      a,[Debug_MenuMax]
    inc     a
    cp      b
    jr      nz,.drawcursor
    xor     a
    ld      [hl],a
    jr      .drawcursor

.checkA
    bit     btnA,a
    jr      z,.checkselect
    ld      hl,.menuitems
    ld      a,[Debug_MenuPos]
    add     a
    add     l
    ld      l,a
    jr      nc,:+
    inc     h
:   ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    bit     7,h ; is pointer in WRAM? (invalid)
    jr      nz,Debug_InvalidMenu
    jp      hl
        
.menuitems
    dw      Debug_InvalidMenu
    dw      Debug_InvalidMenu
    dw      Debug_InvalidMenu
    dw      GM_SpriteView
    dw      Debug_InvalidMenu
    dw      GM_SoundTest
NUM_DEBUG_ITEMS = ((@ - .menuitems) / 2) - 1

; REMOVE ME DEBUG KEY FOR TESTING WINDOWS
.checkselect
    bit     btnSelect,a
    jr      z,.drawcursor
    lb      bc,8,8
    ld      de,0
    call    CreateWindow
    ; fall through

.drawcursor
    call    Debug_DrawCursor

    halt
    jr      DebugLoop
    
Debug_DrawCursor:
    ; draw cursor
    ld      hl,OAMBuffer
    ; y pos
    ld      a,[Debug_MenuPos]
    and     $f
    add     a   ; x2
    add     a   ; x4
    add     a   ; x8
    ld      b,a
    ld      a,[Debug_MenuYPos]
    add     b
    and     $f8
    ld      [hl+],a
    ; x pos
    ld      a,8
    ld      [hl+],a
    ; tile
    ld      a,">" - $a0
    ld      [hl+],a
    ; attributes
    xor     a
    ld      [hl],a
    ret

; ================

Debug_InvalidMenu:
    ; PlaySFX menudenied
    jr      DebugLoop.drawcursor

; ================

section "Debug menu text",rom0
Debug_MainMenuText:
    db  "                    "
    db  "  - POCKET MANS! -  "
    db  "     DEBUG MENU     "
    db  "                    "
    db  "  Start game        "
    db  "  Battle test       "
    db  "  Battle anim test  "
    db  "  Sprite viewer     "
    db  "  MansDex           "
    db  "  Sound test        "
    db  "                    "
    db  "                    "
    db  "                    "
    db  "                    "
    db  " BUILD DATE:        "
    db  " "
    dbp __DATE__,19," "
    db  " "
    dbp __TIME__,19," "
    db  "                    "
    db  "                    "

endc