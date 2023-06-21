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
    db      "This MANS is trained",TEXT_NEXT
    db      "in martial arts.",TEXT_NEXT
    db      "It can punch with",TEXT_NEXT
    db      "the force of a punch",TEXT_NEXT
    db      "to the face."TEXT_END

MansDex_002: ; BIZMANS
;            ####################
    dstr    "OFFICE"
    db      "This MANS is good at",TEXT_NEXT
    db      "office work."TEXT_NEXT
    db      "Some companies have",TEXT_NEXT
    db      "started employing",TEXT_NEXT
    db      "BIZMANS.",TEXT_END

MansDex_003: ; MACHOMANS
;            ####################
    dstr    "MANLY"
    db      "This MANS is the",TEXT_NEXT
    db      "MANSliest of all the",TEXT_NEXT
    db      "MANS.",TEXT_NEXT
    db      "Or so it claims.",TEXT_END

MansDex_004: ; ROCKMANS
;            ####################
    dstr    "ROCK SOLID"
    db      "This MANS is known",TEXT_NEXT
    db      "to sneak up behind",TEXT_NEXT
    db      "monsters and throw",TEXT_NEXT
    db      "rocks at them.",TEXT_CONT,TEXT_CLEAR
    db      "Considered a Class",TEXT_NEXT
    db      "C Nuisance by the",TEXT_NEXT
    db      "MPA.",TEXT_END

MansDex_005: ; PAPERMANS
;            ####################
    dstr    "DELIVERY"
    db      "Many monsters rely",TEXT_NEXT
    db      "on this MANS' skill",TEXT_NEXT
    db      "at delivering mail.",TEXT_NEXT
    db      "It doesn't get along",TEXT_NEXT
    db      "with lycanthropes.",TEXT_END

MansDex_006: ; SCISSORMANS
;            ####################
    dstr    "CUTTING"
    db      "This MANS can cut",TEXT_NEXT
    db      "through just about",TEXT_NEXT
    db      "anything. However,",TEXT_NEXT
    db      "it never asks for",TEXT_NEXT
    db      "permission first.",TEXT_END

MansDex_007: ; ICECREAMMANS
;            ####################
    dstr    "FROZEN TREAT"
    db      "This MANS, by means",TEXT_NEXT
    db      "currently unknown,",TEXT_NEXT
    db      "can produce a cold,",TEXT_NEXT
    db      "sweet substance from",TEXT_NEXT
    db      "seemingly thin air.",TEXT_CONT,TEXT_CLEAR
    db      "This substance has",TEXT_NEXT
    db      "proven to be mostly",TEXT_NEXT
    db      "safe to eat.",TEXT_END

MansDex_008: ; ARSONMANS
;            ####################
    dstr    "FIREY"
    db      "This MANS wants to",TEXT_NEXT
    db      "watch the world",TEXT_NEXT
    db      "burn.",TEXT_CONT,TEXT_CLEAR
    db      "Attempts to convince",TEXT_NEXT
    db      "it that the world",TEXT_NEXT
    db      "is not flammable",TEXT_NEXT
    db      "have proven to be",TEXT_NEXT
    db      "unsuccessful.",TEXT_END

MansDex_009: ; DOUSEMANS
;            ####################
    dstr    "WATER"
    db      "This MANS has deadly",TEXT_NEXT
    db      "aim with its super",TEXT_NEXT
    db      "soaker.",TEXT_CONT,TEXT_CLEAR
    db      "It is the bane of",TEXT_NEXT
    db      "all ARSONMANS.".TEXT_END

MansDex_010: ; GARDENMANS
;            ####################
    dstr    "GREEN THUMB"
    db      "This MANS is often",TEXT_NEXT
    db      "seen tending to the",TEXT_NEXT
    db      "gardens of monsters.",TEXT_CONT,TEXT_CLEAR
    db      "Someday, it hopes to",TEXT_NEXT
    db      "have a hedge trimmed",TEXT_NEXT
    db      "in its honor.",TEXT_END

MansDex_011: ; COWBOYMANS
;            ####################
    dstr    "ROOTIN TOOTIN"
    db      "This MANS hails from",TEXT_NEXT
    db      "a strange, faraway",TEXT_NEXT
    db      "land known as TEXAS.",TEXT_CONT,TEXT_CLEAR
    db      "It has a gun, and it",TEXT_NEXT
    db      "isn't afraid to use",TEXT_NEXT
    db      "it.",TEXT_END

MansDex_012: ; DUNCEMANS
    dstr    "THE WORST"
    db      "This MANS sucks ass.",TEXT_END

MansDex_Unknown:
;            ####################
    dstr    "I DUNNO"
    db      "We have no idea who",TEXT_NEXT
    db      "this MANS is or how",TEXT_NEXT
    db      "it got in here.",TEXT_END
