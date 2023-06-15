section "Mans pic RAM",wram0
PicBuffer:  ds  (8*8)*16

section "Mans pic routines",rom0

; INPUT: a = pic number
;        b = coordinates
;        c = flags (bit 0 = horizontal flip, bit 1 = front/back)
;        de = VRAM address
DrawMansPic:
    ; TODO: Flip sprite if needed
    push    bc
    push    de
    ldfar   hl,MansPicPointers
    ld      e,a
    ld      d,0
    add     hl,de
    add     hl,de
    add     hl,de
    ld      a,[hl+]
    ld      b,a
    bit     1,c
    jr      z,:+
    inc     hl
    inc     hl
:   ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    rst     Bankswitch
    ld      de,PicBuffer
    call    DecodeWLE
    pop     de
    pop     bc
    
    push    bc
    push    de
    ld      hl,PicBuffer
    ld      bc,(8*8)*16
:   ld      a,[hl+]
    push    af
    WaitForVRAM
    pop     af
    ld      [de],a
    inc     de
    dec     bc
    ld      a,b
    or      c
    jr      nz,:-
    pop     de
    pop     bc
    
    ; get starting tile
    ld      a,e
    and     $f0
    swap    a
    ld      e,a
    ld      a,d
    and     $0f
    swap    a
    add     a
    or      e
    jr      nc,:+
    inc     d
:   push    af
    ; get tilemap coordinates
    ; TODO: This doesn't work properly
    ld      a,b
    and     $f0
    swap    a
    ld      l,a
    ld      h,0
    add     hl,hl   ; x2
    add     hl,hl   ; x4
    ld      d,h
    ld      e,l
    add     hl,hl   ; x8
    add     hl,hl   ; x16
    add     hl,de   ; x20
    ld      de,_SCRN0
    add     hl,de
    ld      a,b
    and     $0f
    push    bc
    ld      c,a
    ld      b,0
    add     hl,bc
    pop     bc
    ; update tilemap
    ; TODO: Flip if needed
    pop     af
    lb      bc,8,8
.loop
    push    af
    WaitForVRAM
    pop     af
    ld      [hl+],a
    inc     a
    djnz    .loop
    ld      b,8
    push    af
    ld      a,l
    add     $20 - 8
    
    ld      l,a
    jr      nc,:+
    inc     h
:   pop     af
    dec     c
    jr      nz,.loop
    
    ret