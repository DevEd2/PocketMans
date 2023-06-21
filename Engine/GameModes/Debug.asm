if DebugMode

section fragment "WRAM defines",wram0
Debug_MenuPos:  db
Debug_MenuMax:  db
Debug_MenuYPos: db
Debug_PicTest:  db

Debug_TestScript_Num:       db
Debug_TestScript_BigNum:    dw
Debug_TestScript_HugeNum:   ds  4
Debug_TestScript_Byte:      db
Debug_TestScript_Word:      dw
Debug_TestScript_String:    ds  8

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
    
    ldfar   hl,Debug_MainMenuText
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
    dw      .runtestscript
NUM_DEBUG_ITEMS = ((@ - .menuitems) / 2) - 1

.runtestscript
    ldfar   hl,Script_Test
    call    RunScript
    ; fall through

; REMOVE ME DEBUG KEY FOR TESTING SCRIPTS
.checkselect
    bit     btnSelect,a
    jr      z,.drawcursor
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

section "Debug menu text",romx
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
    db  "  Dialog test       "
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

section "Test script",romx
Script_Test:
    script_text Script_Test_Text1
    script_text Script_Test_Text2
    
    script_text Script_Test_Text3
    script_create_window 0,0,10,10
    script_resume_text
    script_disp_pic 1,1,1,0,$9000
    script_resume_text
    script_play_song Mus_Intro
    script_resume_text
    ; script_play_sfx SFX_JINGLE1
    
    script_end

Script_Test_Text1:
    ;    ################
    db  "Hello there!",TEXT_NEXT
    db  "This is a test",TEXT_CONT
    db  "of the dialog",TEXT_CONT
    db  "system.",TEXT_CONT
    db  TEXT_CLEAR
    db  "Here are some",TEXT_NEXT
    db  "numbers:",TEXT_CONT
    dbw TEXT_NUM,Debug_TestScript_Num
    db  TEXT_CONT
    dbw TEXT_BIGNUM,Debug_TestScript_BigNum
    db  TEXT_CONT
    dbw TEXT_HUGENUM,Debug_TestScript_HugeNum
    db  TEXT_CONT
    dbw TEXT_BYTE,Debug_TestScript_Byte,
    db  TEXT_CONT
    dbw TEXT_WORD,Debug_TestScript_Word
    db  TEXT_CONT
    db  TEXT_CLOSE_WINDOW

Script_Test_Text2:
    ;    ################
    db  "Rambling for a",TEXT_NEXT
    db  "bit.",TEXT_CONT
    db  "According to all",TEXT_NEXT
    db  "known laws of",TEXT_NEXT
    db  "aviation, there",TEXT_NEXT
    db  "is no way a bee",TEXT_NEXT
    db  "should be able",TEXT_NEXT
    db  "to fly. Its",TEXT_NEXT
    db  "wings are too",TEXT_NEXT
    db  "small to get its",TEXT_NEXT
    db  "fat little body",TEXT_NEXT
    db  "off the ground.",TEXT_NEXT
    db  "The bee, of",TEXT_NEXT
    db  "course, flies",TEXT_NEXT
    db  "anyway, because",TEXT_NEXT
    db  "bees don't care",TEXT_NEXT
    db  "what humans",TEXT_NEXT
    db  "think is imposs-",TEXT_NEXT
    db  "ible.",TEXT_CLEAR
    db  "End of ramble.",TEXT_CONT
    db  TEXT_CLOSE_WINDOW
    ;    ################

Script_Test_Text3:
    ;    ################
    db  "Here's a window",TEXT_PAUSE,TEXT_CONT
    db  "and now let's",TEXT_CONT
    db  "put a pic in it.",TEXT_PAUSE,TEXT_CONT
    db  "And now, music",TEXT_PAUSE,TEXT_CONT
    db  "and a jingle.",TEXT_PAUSE,TEXT_CONT
    db  TEXT_CLOSE_WINDOW

endc