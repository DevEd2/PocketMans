section "Tile animation RAM",wram0
Anim_WaterTile:         ds  16
Anim_ParallaxTile:      ds  16
Anim_RevParallaxTile:   ds  16
Anim_WaterTileID:       db
Anim_ParallaxTileID:    db
Anim_RevParallaxTileID: db

section "Tile animation routines",rom0

; INPUT:  a = tile ID
;        hl = tile buffer
Anim_CopyTile:
    push    hl
    ld      l,a
    ld      h,0
    add     hl,hl ; x2
    add     hl,hl ; x4
    add     hl,hl ; x8
    add     hl,hl ; x16
    ld      d,h
    ld      e,l
    pop     hl
    ld      [sys_TempSP],sp
    ld      sp,hl
    ld      h,d
    ld      l,e
    ld      de,_VRAM
    add     hl,de
    rept 8
    WaitForVRAM
    pop     de
    ld      [hl],d
    inc     hl
    ld      [hl],e
    inc     hl
    endr
    
    ld      hl,sys_TempSP
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    ld      sp,hl
    ret

AnimateWater:
    ld      a,[sys_CurrentFrame]
    and     7
    ret     nz
    ld      hl,Anim_WaterTile
    push    hl
    
    rept    4
    ld      a,[hl]
    rrca
    ld      [hl+],a
    ld      a,[hl]
    rrca
    ld      [hl+],a
    ld      a,[hl]
    rlca
    ld      [hl+],a
    ld      a,[hl]
    rlca
    ld      [hl+],a
    endr
    pop     hl
    ld      a,[Anim_WaterTileID]
    jp      Anim_CopyTile
       