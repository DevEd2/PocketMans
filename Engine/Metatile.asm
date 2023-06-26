section "Metatile RAM defines",wram0

Engine_TilesetPointer:  dw
Engine_TilesetBank:     db

; Collision constants

COLLISION_NONE          equ 0
COLLISION_SOLID         equ 1

section "Metatile routines",rom0

; Input:    H = Y pos
;           L = X pos
; Output:   A = Tile coordinates
; Destroys: B
GetTileCoordinates:
    ld      a,l
    and     $f0
    swap    a
    ld      b,a
    ld      a,h
    and     $f0
    add     b
    ret

; Input:    A = Tile coordinates
;           B = Tile ID
; Output:   Metatile to screen RAM
; Destroys: BC, DE, HL
DrawMetatile:
    push    af
    ld      e,a
    and     $0f
    rla
    ld      l,a
    ld      a,e
    and     $f0
    ld      e,a
    rla
    rla
    and     %11000000
    or      l
    ld      l,a
    ld      a,e
    rra
    rra
    swap    a
    and     $3
    ld      h,a
    
    ld      de,_SCRN0
    add     hl,de
    ld      d,h
    ld      e,l
    ; get tile data pointer
    push    bc
    ld      a,[Engine_TilesetBank]
    ld      b,a
    rst     Bankswitch
    pop     bc
    ld      hl,Engine_TilesetPointer
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    ; skip collision pointer + gfx bank & pointer
    push    de
    ld      de,5
    add     hl,de
    pop     de
    ld      c,b
    ld      b,0
    add     hl,bc
    add     hl,bc
    add     hl,bc
    add     hl,bc
    ; write to screen memory
    WaitForVRAM
    ld      a,[hl+]
    ld      [de],a
    inc     de
    WaitForVRAM
    ld      a,[hl+]
    ld      [de],a
    ld      a,e
    add     $1f
    jr      nc,:+
    inc     d
:   ld      e,a
    WaitForVRAM
    ld      a,[hl+]
    ld      [de],a
    inc     de
    WaitForVRAM
    ld      a,[hl+]
    ld      [de],a
    resbank
    pop     af
    ret
