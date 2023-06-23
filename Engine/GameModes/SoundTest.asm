if DebugMode

section fragment "WRAM defines",wram0
Debug_MusicID:  db
Debug_SFXID:    db

section "Sound test menu routines",rom0

GM_SoundTest:
    ldh     a,[rLCDC]
    bit     7,a
    jr      z,:+
    rst     WaitVBlank
    xor     a
    ldh     [rLCDC],a

    ; clear VRAM
    ld      hl,_VRAM
    ld      bc,_SRAM-_VRAM
    call    _FillRAM

:   ld      hl,Font
    ld      de,_VRAM8800
    call    DecodeWLE

    call    Sound_Init
    
    ldfar   hl,str_SoundTest_Music
    ld      de,$9820
    call    PrintString
    ; ld      hl,str_SoundTest_SFX
    ld      de,$9840
    call    PrintString
    
    ld      a,LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh     [rLCDC],a
    ld      a,IEF_VBLANK
    ldh     [rIE],a
    
    ld      hl,Debug_MusicID
    xor     a
    ld      [hl+],a
    ld      [hl+],a
    ld      [Debug_MenuPos],a
    inc     a
    ld      [Debug_MenuMax],a
    ld      a,$18
    ld      [Debug_MenuYPos],a
    ei
    
SoundTestLoop:
    ld      a,[sys_btnPress]
    ld      e,a
    bit     btnSelect,e
    jr      z,.checkleft
    ld      a,[Debug_MenuPos]
    xor     1
    ld      [Debug_MenuPos],a
.checkleft
    bit     btnLeft,e
    jr      z,.checkright
    ld      a,[Debug_MenuPos]
    and     a
    jr      nz,.l1sfx
.l1music
    ld      hl,Debug_MusicID
    dec     [hl]
    jr      .checkright
.l1sfx
    ld      hl,Debug_SFXID
    dec     [hl]
    ; fall through
.checkright
    bit     btnRight,e
    jr      z,.checkup
    ld      a,[Debug_MenuPos]
    and     a
    jr      nz,.r1sfx
.r1music
    ld      hl,Debug_MusicID
    inc     [hl]
    jr      .checkup
.r1sfx
    ld      hl,Debug_SFXID
    inc     [hl]
    ; fall through
.checkup
    bit     btnUp,e
    jr      z,.checkdown
    ld      a,[Debug_MenuPos]
    and     a
    jr      nz,.u16sfx
.u16music
    ld      a,[Debug_MusicID]
    add     16
    ld      [Debug_MusicID],a
    jr      .checkdown
.u16sfx
    ld      a,[Debug_SFXID]
    add     16
    ld      [Debug_SFXID],a
    ; fall through
.checkdown
    bit     btnDown,e
    jr      z,.checka
    ld      a,[Debug_MenuPos]
    and     a
    jr      nz,.d16sfx
.d16music
    ld      a,[Debug_MusicID]
    sub     16
    ld      [Debug_MusicID],a
    jr      .checka
.d16sfx
    ld      a,[Debug_SFXID]
    sub     16
    ld      [Debug_SFXID],a
    ; fall through
.checka
    bit     btnA,e
    jr      z,.checkb
    ld      a,[Debug_MenuPos]
    and     a
    jr      nz,.playsfx
.playmusic
    call    Sound_Init
    ld      a,[Debug_MusicID]
    ld      e,a
    ld      d,0
    call    Sound_PlaySong

    jr      .checkb
.playsfx
    ; TODO
.checkb
    bit     btnB,e
    jr      z,.continue
    call    Sound_Init
    jp      GM_Debug
.continue    
    ld      a,[Debug_MusicID]
    ld      hl,$9828
    call    PrintHex
    ld      a,[Debug_SFXID]
    ld      hl,$9848
    call    PrintHex
    
    call    Debug_DrawCursor
    rst     WaitVBlank
    jp      SoundTestLoop

section "Sound test text",romx

str_SoundTest_Music:    dstr    "  MUSIC ??"
str_SoundTest_SFX:      dstr    "  SFX   ??"

endc