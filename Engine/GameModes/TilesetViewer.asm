section "Tileset Viewer RAM",wram0

MetatileViewer_PaletteBank:       db
MetatileViewer_PalettePointer:    dw

section "Tileset Viewer routines",rom0

macro dwb2
    db  bank(\1)
    dw  \1
    db  bank(\2)
    dw  \2
    endm

GM_TilesetViewer:

MetatileViewer_GFXMenu:
    xor     a
    ldh     [rLCDC],a
    call    ClearScreen

    ldfar   hl,Font
    ld      de,_VRAM8800
    call    DecodeWLE
    
    ld      a,NUM_TILESET_ENTRIES
    ld      [Debug_MenuMax],a
    xor     a
    ld      [Debug_MenuPos],a
    
    ld      a,$18
    ld      [Debug_MenuYPos],a

    ld      a,LCDCF_ON | LCDCF_BG8000 | LCDCF_OBJON | LCDCF_BGON
    ldh     [rLCDC],a
    ld      a,IEF_VBLANK
    ldh     [rIE],a
    ei
    
    call    MetatileViewer_DrawGFXMenu

MetatileViewer_GFXMenuLoop:
    ld      a,[sys_btnPress]
    bit     btnUp,a
    jr      z,.checkdown
    ; PlaySFX menucursor
    ld      hl,Debug_MenuPos
    dec     [hl]
    ld      a,[hl]
    cp      $ff
    jr      nz,:+
    ld      a,[Debug_MenuMax]
    ld      [hl],a
:   call    MetatileViewer_DrawGFXMenu
    jp      .drawcursor
    
.checkdown
    bit     btnDown,a
    jr      z,.checkLeft
    ; PlaySFX menucursor
    ld      hl,Debug_MenuPos
    inc     [hl]
    ld      b,[hl]
    ld      a,[Debug_MenuMax]
    inc     a
    cp      b
    jr      nz,:+
    ld      [hl],0
:   call    MetatileViewer_DrawGFXMenu
    jp      .drawcursor

.checkLeft
    bit     btnLeft,a
    jr      z,.checkRight
    ; PlaySFX menucursor
    ld      a,[Debug_MenuPos]
    sub     16
    jr      nc,:+
    xor     a
:   ld      [Debug_MenuPos],a
    call    MetatileViewer_DrawGFXMenu
    jp      .drawcursor

.checkRight
    bit     btnRight,a
    jr      z,.checkB
    ; PlaySFX menucursor
    ld      a,[Debug_MenuPos]
    add     16
    cp      7
    jr      c,:+
    ld      a,7
:   ld      [Debug_MenuPos],a
    call    MetatileViewer_DrawGFXMenu
    jr      .drawcursor

.checkB
    bit     btnB,a
    jr      z,.checkA
    ; PlaySFX menuback
    halt
    xor     a
    ldh     [rLCDC],a
    jp      GM_Debug

.checkA
    bit     btnA,a
    jr      z,.drawcursor
    ; PlaySFX menuselect
    ld      a,[Debug_MenuPos]
    ld      b,a
    ld      a,[Debug_MenuMax]
    cp      b
    jr      nz,:+
    halt
    xor     a
    ldh     [rLCDC],a
    jp      GM_Debug
:
    halt
    xor     a
    ldh     [rLCDC],a
    
    ld      hl,MetatileViewer_GFXPointers
    ld      a,[Debug_MenuPos]
    ld      e,a
    ld      d,0
    add     hl,de
    add     hl,de
    add     hl,de
    add     hl,de
    add     hl,de
    add     hl,de
    ld      a,[hl+]
    ld      b,a
    rst     Bankswitch
    ld      a,[hl+]
    push    hl
    push    hl
    ld      h,[hl]
    ld      l,a
    ld      de,$8000
    call    DecodeWLE
    pop     hl
    inc     hl
    ld      a,[hl+]
    ld      [Engine_TilesetBank],a
    ld      a,[hl+]
    ld      [Engine_TilesetPointer],a
    ld      a,[hl]
    ld      [Engine_TilesetPointer+1],a

    jp      MetatileViewer_Viewer

.drawcursor
    call    Debug_DrawCursor
    halt
    jp      MetatileViewer_GFXMenuLoop

MetatileViewer_DrawGFXMenu:
    ld      hl,$9800
    ld      bc,$400
:   xor     a
    push    af
    WaitForVRAM
    pop     af
    ld      [hl+],a
    dec     bc
    ld      a,b
    or      c
    jr      nz,:-

    ld      b,bank(MetatileViewer_GFXMenuText)
    rst     Bankswitch
    ld      a,[Debug_MenuPos]
    and     $f0 
    ld      b,NUM_TILESET_ENTRIES+1
    ld      de,$9822
:   push    af
    ld      hl,MetatileViewer_GFXMenuText
    add     a
    add     l
    ld      l,a
    jr      nc,:+
    inc     h
:   ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    push    de
    call    PrintString
    pop     de
    ld      a,e
    add     32
    ld      e,a
    jr      nc,:+
    inc     d
:   pop     af
    inc     a
    cp      8
    ret     z
    dec     b
    jr      nz,:---
    ret

; ================================================================

MetatileViewer_Viewer:
    call    ClearScreen2
    
    xor     a
:   ld      b,a
    call    DrawMetatile
    inc     a
    jr      nz,:-

    ; REMOVEME WATER TILE ANIM TEST
    ld      a,$16
    ld      [Anim_WaterTileID],a
    ld      hl,$8160
    ld      de,Anim_WaterTile
    ld      b,16
:   ld      a,[hl+]
    ld      [de],a
    inc     de
    djnz    :-
    
    ; REMOVEME PARALLAX TILE TEST
    ld      a,$30
    ld      [Anim_ParallaxTileID],a
    ld      hl,$8300
    ld      de,Anim_ParallaxTile
    ld      b,16
:   ld      a,[hl+]
    ld      [de],a
    inc     de
    djnz    :-

    ld      a,LCDCF_ON | LCDCF_BG8000 | LCDCF_OBJON | LCDCF_BGON
    ldh     [rLCDC],a
    ld      a,IEF_VBLANK
    ldh     [rIE],a
    ei
    
    xor     a
    ldh     [rSCX],a
    ldh     [rSCY],a
    
MetatileViewer_ViewerLoop:
    ld      a,[sys_btnHold]
    ld      hl,rSCY
    bit     btnUp,a
    call    nz,.up
    bit     btnDown,a
    call    nz,.down
    ld      hl,rSCX
    bit     btnLeft,a
    call    nz,.left
    bit     btnRight,a
    call    nz,.right

    ld      a,[sys_btnPress]
    bit     btnB,a
    jr      z,:+
    halt
    xor     a
    ldh     [rLCDC],a
    call    ClearScreen2
    jp      MetatileViewer_GFXMenu

:   ; REMOVEME WATER TILE ANIM TEST
    call    AnimateWater

    rst     WaitVBlank
    jr      MetatileViewer_ViewerLoop

.up
    push    af
    ld      a,[hl]
    and     a
    jr      z,:+
    dec     [hl]
    ld      a,[sys_CurrentFrame]
    and     1
    call    z,AnimateParallaxU
:   pop     af
    ret
.left
    push    af
    ld      a,[hl]
    and     a
    jr      z,:+
    dec     [hl]
    ld      a,[sys_CurrentFrame]
    and     1
    call    z,AnimateParallaxL
:   pop     af
    ret
.down
    push    af
    ld      a,[hl]
    cp      256-SCRN_Y
    jr      z,:+
    inc     [hl]
    ld      a,[sys_CurrentFrame]
    and     1
    call    z,AnimateParallaxD
:   pop     af
    ret
.right
    push    af
    ld      a,[hl]
    cp      256-SCRN_X
    jr      z,:+
    inc     [hl]
    ld      a,[sys_CurrentFrame]
    and     1
    call    z,AnimateParallaxR
:   pop     af
    ret

; ================================================================

MetatileViewer_GFXPointers:
    dwb2    OverworldTiles,Tileset_Overworld

; ================================================================

section "Tile Viewer - Graphics set selector text",romx
MetatileViewer_GFXMenuText:
    dw  .overworld
    dw  .exit
NUM_TILESET_ENTRIES = ((@-MetatileViewer_GFXMenuText)/2)-1

.overworld      db  "OVERWORLD",0
.indoors1       db  "INDOORS",0
.shop1          db  "SHOP",0
.cave           db  "CAVE",0
.exit           db  "EXIT",0