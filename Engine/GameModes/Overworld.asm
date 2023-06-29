; Map header format:
; 1 byte - GFX bank
; 2 bytes - GFX pointer (WLE compressed)
; 1 byte - Map width
; 1 byte - Map height
; 4 bytes - North connection
;     - 1 byte - Connected map bank
;     - 2 bytes - Connected map pointer
;     - 1 byte - Offset (low nybble = Y, high nybble = X)
; 4 bytes - East connection
; 4 bytes - South connection
; 4 bytes - West connection
; 8 bytes - Border tiles
; 1 byte - Map music ID
; 2 bytes - Map script pointer (assumed to be in same bank as header, 0 denotes no script)
; 2 bytes - Map data pointer (assumed to be in same bank as header)

section "Overworld RAM",wram0

OW_RAMStart:
OW_PlayerX:     db
OW_PlayerY:     db
OW_QueuedSong:  db
OW_FadeTimer:   db
OW_MapBank:     db ; map pointer bank
OW_MapPointer:  dw ; pointer to map header
OW_MapWidth:    db
OW_MapHeight:   db
OW_MapConnectionN:
.bank           db
.offset         db
.ptr            dw
OW_MapConnectionE:
.bank           db
.offset         db
.ptr            dw
OW_MapConnectionS:
.bank           db
.offset         db
.ptr            dw
OW_MapConnectionW:
.bank           db
.offset         db
.ptr            dw
OW_BorderTiles:
OW_BorderTilesN:
.nw             db
.nn             db
.ne             db
OW_BorderTilesC:
.cw             db
.ce             db
OW_BorderTilesS:
.sw             db
.ss             db
.se             db
OW_Blockmap:    ds  16*16
OW_MapDataPtr:  dw
OW_RAMEnd:

; ================================================================

section "Overworld routines",rom0

; Call OW_Init and OW_LoadMap before going here!
GM_Overworld:
    ld      b,b
    rst     WaitVBlank
    xor     a
    ldh     [rLCDC],a
    
    
    
    ret

OW_Init:
    xor     a
    ld      hl,OW_MapBank
    ld      bc,OW_RAMEnd-OW_RAMStart
    call    _FillRAM
    ld      a,$ff
    ld      [OW_MapConnectionN],a
    ld      [OW_MapConnectionN+1],a
    ld      [OW_MapConnectionE],a
    ld      [OW_MapConnectionE+1],a
    ld      [OW_MapConnectionS],a
    ld      [OW_MapConnectionS+1],a
    ld      [OW_MapConnectionW],a
    ld      [OW_MapConnectionW+1],a
    inc     a
    ld      b,OW_Blockmap-OW_BorderTiles
:   ld      [hl+],a
    djnz    :-
    ld      [OW_QueuedSong],a
    ld      [OW_FadeTimer],a
    ret

; Full map load, used when entering a map through e.g. a door
; INPUT: hl = map header pointer
;         b = map header bank
;        de = player X/Y coordinates
OW_LoadMap:
    ld      b,b
    ld      a,b
    ld      [OW_MapBank],a
    ld      a,l
    ld      [OW_MapPointer],a
    ld      a,h
    ld      [OW_MapPointer+1],a
    push    de
    rst     Bankswitch
    ; load GFX
    ld      a,[hl+]
    ld      b,a
    ld      a,[hl+]
    push    hl
    ld      h,[hl]
    ld      l,a
    rst     Bankswitch
    ld      de,$9000
    call    DecodeWLE
    resbank
    pop     hl
    inc     hl
    ; load map parameters
    ld      b,OW_Blockmap-OW_MapWidth
    ld      de,OW_MapWidth
:   ld      a,[hl+]
    ld      [de],a
    inc     de
    djnz    :-
    pop     de
    ld      a,d
    ld      [OW_PlayerX],a
    ld      a,e
    ld      [OW_PlayerY],a
    ; queue music
    ld      a,[hl+]
    ld      [OW_QueuedSong],a
    ld      a,[OW_FadeTimer]
    and     a
    jr      z,:+
    ld      a,90
    ld      [OW_FadeTimer],a
    ; execute map script
:   ld      a,[hl+]
    push    hl
    ld      h,[hl]
    ld      l,a
    or      h
    jr      z,:+    ; skip if map has no script
    ld      a,[OW_MapBank]
    ld      b,a
    call    RunScript
:   pop     hl
    inc     hl
    ; TODO: Refresh screen
    ret

; Partial map load, used when walking between maps 
; INPUT: hl = map header pointer
;         b = map header bank
OW_LoadMap_Partial:
    ; TODO
    ld      b,b
    ld      a,b
    ld      [OW_MapBank],a
    ld      a,l
    ld      [OW_MapPointer],a
    ld      a,h
    ld      [OW_MapPointer+1],a
    push    de
    rst     Bankswitch
    ; skip loading GFX
    inc     hl
    inc     hl
    inc     hl
    ; load map parameters
    ld      b,OW_Blockmap-OW_MapWidth
    ld      de,OW_MapWidth
:   ld      a,[hl+]
    ld      [de],a
    inc     de
    djnz    :-
    pop     de
    ld      a,d
    ld      [OW_PlayerX],a
    ld      a,e
    ld      [OW_PlayerY],a
    ; queue music
    ld      a,[hl+]
    ld      [OW_QueuedSong],a
    ld      a,[OW_FadeTimer]
    and     a
    jr      z,:+
    ld      a,90
    ld      [OW_FadeTimer],a
    ; execute map script
:   ld      a,[hl+]
    push    hl
    ld      h,[hl]
    ld      l,a
    or      h
    jr      z,:+    ; skip if map has no script
    ld      a,[OW_MapBank]
    ld      b,a
    call    RunScript
:   pop     hl
    inc     hl
    ret

; fill screen with map around player position
; WARNING: Assumes correct bank for map data is loaded!
OW_FillScreen:
    ld      b,b
    ld      a,[OW_PlayerY]
    sub     5
    ; TODO: On underflow, clamp to height of north map and set "north start" flag
    ld      c,a
    ld      a,[OW_PlayerX]
    sub     5
    ; TODO: On underflow, clamp to width of west map and set "west start" flag
    ld      b,a
    
    push    bc
    ld      hl,OW_MapDataPtr
    
    ; get starting coordinates
    ; TODO: Account for underflow
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    ld      a,[OW_MapWidth]
    ld      e,a
    ld      d,0
:   add     hl,de
    dec     c
    jr      nz,:-
    ld      e,b
    add     hl,de
    pop     bc
    
    ; TODO: Actually fill the screen

    add     hl,bc
    ld      de,OW_Blockmap
