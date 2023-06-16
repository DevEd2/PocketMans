MansDexEntries:
    dw      MansDex_001
    dw      MansDex_002
    dw      MansDex_003
    dw      MansDex_004
    dw      MansDex_005
    dw      MansDex_006
    dw      MansDex_007
    dw      MansDex_008
    dw      MansDex_009
    dw      MansDex_010
    dw      MansDex_011
    dw      MansDex_012

MansDex_001: ; FIGHTMANS
;            ####################
    dstr    "BOXING"
    db      "This MANS is trained",$80
    db      "in martial arts.",$81
    db      "It can punch with",$80
    db      "the force of a punch",$80
    db      "to the face."$ff

MansDex_002: ; BIZMANS
;            ####################
    dstr    "OFFICE"
    db      "This MANS is good at",$80
    db      "office work."$81
    db      "Some companies have",$80
    db      "started employing",$80
    db      "BIZMANS.",$ff

MansDex_003: ; MACHOMANS
;            ####################
    dstr    "MANLY"
    db      "This MANS is the",$80
    db      "MANSliest of all the",$80
    db      "MANS.",$81
    db      "Or so it claims.",$ff

MansDex_004: ; ROCKMANS
;            ####################
    dstr    "ROCK SOLID"
    db      "This MANS wears its",$80
    db      "solid rock armor at",$80
    db      "all times.",$81
    db      "Unfortunately, it",$80
    db      "can't move around",$80
    db      "easily as a result.",$ff

MansDex_005: ; PAPERMANS
;            ####################
    dstr    "DELIVERY"
    db      "Many monsters rely",$80
    db      "on this MANS' skill",$80
    db      "at delivering mail."
    db      "It doesn't get along",$80
    db      "with lycanthropes.",$ff

MansDex_006: ; SCISSORMANS
;            ####################
    dstr    "CUTTING"
    db      "This MANS can cut",$80
    db      "just about anything.",$81
    db      "However, it never",$80
    db      "asks for permission",$80
    db      "before doing so.",$ff

MansDex_007: ; ICECREAMMANS
;            ####################
    dstr    "FROZEN TREAT"
    db      "This MANS, by means",$80
    db      "currently unknown,",$80
    db      "can produce a cold,",$81
    db      "sweet substance from",$80
    db      "seemingly thin air.",$81
    db      "This substance has",$80
    db      "proven to be mostly",$80
    db      "safe to eat.",$ff

MansDex_008: ; ARSONMANS
;            ####################
    dstr    "FIREY"
    db      "This MANS wants to",$80
    db      "watch the world",$80
    db      "burn.",$81
    db      "Attempts to convince",$80
    db      "it that the world",$80
    db      "is not flammable",$81
    db      "have proven to be",$80
    db      "unsuccessful.",$ff

MansDex_009: ; DOUSEMANS
;            ####################
    dstr    "WATER"
    db      "This MANS has deadly",$80
    db      "aim with its super",$80
    db      "soaker.",$81
    db      "It is the bane of",$80
    db      "all ARSONMANS.".$ff

MansDex_010: ; GARDENMANS
;            ####################
    dstr    "GREEN THUMB"
    db      "This MANS is often",$80
    db      "seen tending to the",$80
    db      "gardens of monsters.",$81
    db      "Someday, it hopes to",$80
    db      "have a hedge trimmed",$80
    db      "in its honor.",$ff

MansDex_011: ; COWBOYMANS
;            ####################
    dstr    "ROOTIN TOOTIN"
    db      "This MANS hails from",$80
    db      "a strange, faraway",$80
    db      "land known as Texas.",$81
    db      "It has a gun, and it",$80
    db      "isn't afraid to use",$80
    db      "it.",$ff

MansDex_012: ; DUNCEMANS
    dstr    "THE WORST"
    db      "This MANS sucks ass.",$ff

MansDex_Unknown:
;            ####################
    dstr    "I DUNNO"
    db      "We have no idea who",$80
    db      "this MANS is or how",$80
    db      "it got in here.",$ff
