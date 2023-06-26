
section "Mans RAM",wram0

PlayerParty:
.size   db
    MansStruct
    MansStruct
    MansStruct
    MansStruct
    MansStruct
    MansStruct
PlayerParty_End:

EnemyParty:
.size   db
    MansStruct
    MansStruct
    MansStruct
    MansStruct
    MansStruct
    MansStruct
EnemyParty_End:

TempMans:
    MansStruct

section "Mans routines",rom0

GiveMans:
    ; TODO
    ret

; INPUT: hl = pointer to first mans
;        de = pointer to second mans
SwapMans:
    ; copy first mans to temp buffer
    push    hl
    push    de
    ld      de,TempMans
    ld      b,SIZEOF_MANS_STRUCT
:   ld      a,[hl+]
    ld      [de],a
    inc     de
    djnz    :-
    pop     de
    pop     hl
    ; copy second mans to first mans
    push    de
    ld      b,SIZEOF_MANS_STRUCT
:   ld      a,[de]
    ld      [hl+],a
    inc     de
    djnz    :-
    pop     de
    ; copy temp buffer to second man
    ld      hl,TempMans
:   ld      a,[hl+]
    ld      [de],a
    inc     de
    djnz    :-
    ret