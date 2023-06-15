if DebugMode

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
    
    ld      a,LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh     [rLCDC],a
    ld      a,IEF_VBLANK
    ldh     [rIE],a
    ei

DebugLoop:
    rst     WaitVBlank
    jr      DebugLoop

section "Debug menu text",rom0
Debug_MainMenuText:
    db  "                    "
    db  "  - POCKET MANS! -  "
    db  "     DEBUG MENU     "
    db  "                    "
    db  "  Start game        "
    db  "  Battle test       "
    db  "  Sprite viewer     "
    db  "  Sound test        "
    db  "                    "
    db  "                    "
    db  "                    "
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

endc