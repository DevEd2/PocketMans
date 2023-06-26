section "Overworld RAM",wram0

OW_RAMStart:
OW_MapBank:     db ; map pointer bank
OW_MapPointer:  dw ; pointer to map header
OW_MapWidth:    db
OW_MapHeight:   db
OW_PlayerX:     db
OW_PlayerY:     db
OW_MapConnectionN:
.offset         db
.bank           db
.ptr            dw
OW_MapConnectionE:
.offset         db
.bank           db
.ptr            dw
OW_MapConnectionS:
.offset         db
.bank           db
.ptr            dw
OW_MapConnectionW:
.offset         db
.bank           db
.ptr            dw
OW_RAMEnd:

; ================================================================

section "Overworld routines",rom0

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
    ret

GM_Overworld:
    ; TODO: Everything!
    ret