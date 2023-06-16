if DebugMode

section fragment "WRAM defines",wram0
Debug_CurrentMans:  db

section "SpriteView menu routines",rom0

GM_SpriteView:
    ldh     a,[rLCDC]
    bit     7,a
    jr      z,:+
    rst     WaitVBlank
    xor     a
    ldh     [rLCDC],a

    ; clear VRAM
    ld      hl,_VRAM
    ld      bc,_SRAM-_VRAM
    call    _FillRAM

:   ld      hl,Font
    ld      de,_VRAM8800
    call    DecodeWLE
    
    ld      a,-1
    ld      hl,$9800
    ld      bc,$800
    call    _FillRAM
    
    ld      a,LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh     [rLCDC],a
    ld      a,IEF_VBLANK
    ldh     [rIE],a
    
    ld      hl,Debug_CurrentMans
    ld      [hl],0
    call    SpriteView_DrawSprites
    ei
    
SpriteViewLoop:
    ld      hl,Debug_CurrentMans
    ld      a,[sys_btnPress]
.checkleft
    bit     btnLeft,a
    jr      z,.checkright
    dec     [hl]
    call    SpriteView_DrawSprites
.checkright
    bit     btnRight,a
    jr      z,.checkB
    inc     [hl]
    call    SpriteView_DrawSprites
.checkB
    bit     btnB,a
    jp      nz,GM_Debug
.done
    rst     WaitVBlank
    jr      SpriteViewLoop

; INPUT:    (none)
; OUTPUT:
; DESTROYS:
SpriteView_DrawSprites:
    push    af
    push    hl
    ld      a,[hl]
    call    SpriteView_PrintMansNumber
    WaitForVRAM
    ld      a," "+$60
    ld      [de],a
    inc     de
    ld      a,[Debug_CurrentMans]
    ld      l,a
    ld      h,0
    add     hl,hl   ; x2
    add     hl,hl   ; x4
    ld      b,h
    ld      c,l
    add     hl,hl   ; x8
    add     hl,bc   ; x12
    ldfar   bc,MansNames
    add     hl,bc
    call    PrintMansName
    
    ld      a,[Debug_CurrentMans]
    inc     a
    lb      bc,$21,0
    ld      de,$9000
    push    af
    call    DrawMansPic
    pop     af
    lb      bc,$2a,1
    ld      de,$9400
    call    DrawMansPic
    
    pop     hl
    pop     af
    ret

; INPUT:    a = mans number
; DESTROYS: a, de, hl
SpriteView_PrintMansNumber:
    call    Hex2Dec8
    ld      hl,sys_StringBuffer
    ld      de,_SCRN0
    jp      PrintString

section "Sprite viewer text",romx

str_SpriteView_Controls1:   dstr    "< - PREV SPRITE"
str_SpriteView_Controls2:   dstr    "> - NEXT SPRITE"

endc