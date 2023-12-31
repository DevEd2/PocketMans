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
    ld      [hl],e
    inc     hl
    ld      [hl],d
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
    rlc     [hl]
    inc     hl
    rlc     [hl]
    inc     hl
    rrc     [hl]
    inc     hl
    rrc     [hl]
    inc     hl
    endr
    pop     hl
    ld      a,[Anim_WaterTileID]
    jp      Anim_CopyTile

AnimateParallaxU:
    ld      hl,Anim_ParallaxTile
    call    DoParallaxU
    ld      a,[Anim_ParallaxTileID]
    jp      Anim_CopyTile

AnimateParallaxD:
    ld      hl,Anim_ParallaxTile
    call    DoParallaxD
    ld      a,[Anim_ParallaxTileID]
    jp      Anim_CopyTile

AnimateParallaxL:
    ld      hl,Anim_ParallaxTile
    call    DoParallaxL
    ld      a,[Anim_ParallaxTileID]
    jp      Anim_CopyTile

AnimateParallaxR:
    ld      hl,Anim_ParallaxTile
    call    DoParallaxR
    ld      a,[Anim_ParallaxTileID]
    jp      Anim_CopyTile

AnimateReverseParallaxU:
    ld      hl,Anim_ParallaxTile
    call    DoParallaxD
    ld      a,[Anim_ParallaxTileID]
    jp      Anim_CopyTile

AnimateReverseParallaxD:
    ld      hl,Anim_ParallaxTile
    call    DoParallaxU
    ld      a,[Anim_ParallaxTileID]
    jp      Anim_CopyTile

AnimateReverseParallaxL:
    ld      hl,Anim_RevParallaxTile
    call    DoParallaxR
    ld      a,[Anim_RevParallaxTileID]
    jp      Anim_CopyTile

AnimateReverseParallaxR:
    ld      hl,Anim_RevParallaxTile
    call    DoParallaxL
    ld      a,[Anim_RevParallaxTileID]
    jp      Anim_CopyTile

DoParallaxU:
    push    hl
    ld      a,[hl+]
    ld      d,[hl]
    ld      e,a
    inc     hl
    push    de
    ld      b,h
    ld      c,l
    dec     bc
    dec     bc
    rept    14
    ld      a,[hl+]
    ld      [bc],a
    inc     bc
    endr
    pop     de
    ld      a,e
    ld      [bc],a
    inc     bc
    ld      a,d
    ld      [bc],a
    pop     hl
    ret

DoParallaxD:
    push    hl
    ld      bc,15
    add     hl,bc
    ld      a,[hl-]
    ld      d,[hl]
    ld      e,a
    dec     hl
    push    de
    ld      b,h
    ld      c,l
    inc     bc
    inc     bc
    rept    14
    ld      a,[hl-]
    ld      [bc],a
    dec     bc
    endr
    pop     de
    ld      a,e
    ld      [bc],a
    dec     bc
    ld      a,d
    ld      [bc],a
    pop     hl
    ret

DoParallaxL:
    push    hl
    rept    16
    ld      a,[hl]
    rlca
    ld      [hl+],a
    endr
    pop     hl
    ret
    
DoParallaxR:
    push    hl
    rept    16
    ld      a,[hl]
    rrca
    ld      [hl+],a
    endr
    pop     hl
    ret