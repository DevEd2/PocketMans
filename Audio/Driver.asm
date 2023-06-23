; ================================================================
; POCKET MANS
; Music/SFX playback system
; (C) 2023 DevEd
; 
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:
; 
; The above copyright notice and this permission notice shall be included
; in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ================================================================

; note definitions
__ = 0
C_ = 1
C# = 2
D_ = 3
D# = 4
E_ = 5
F_ = 6
F# = 7
G_ = 8
G# = 9
A_ = 10
A# = 11
B_ = 12

; sound command definitions
macro note
    assert (\1 >= 0) & (\1 < $10)
    assert (\2 >= 0) & (\2 < $10)
    db  (\1 << 4) | (\2 - 1)
endm

macro rest
    note __,\1
endm

macro envelope
    db  $e0
    db  \1
endm

macro pulse
    db  $e1
    db  \1
endm

macro wave
    db  $e1
    db  \1
    endm

; vibrato delay,speed,depth
macro vibrato
    db  $e2
    db  \1
    assert (\2 >= 0) & (\2 < $10)
    assert (\3 >= 0) & (\3 < $10)
    db  (\2 << 4) | \3
endm

macro sound_jump
    db  $e3
    dw  \1
endm
    
macro sound_call
    db  $e4
    dw  \1
endm

macro sound_ret
    db  $e5
endm

macro sound_loop
    db  $e6
    db  \2
    dw  \1
endm

macro sound_end
    db  $ff
endm
    
macro octave
    assert (\1 >= 2) & (\1 < 8)
    db  $f0 | (\1 - 2)
endm

macro octave_up
    db  $f8
endm

macro octave_down
    db  $f9
endm

section "Sound driver RAM",wram0

Sound_MemStart:

Sound_MusicPlaying: db
Sound_SFXPlaying:   db
Sound_Flags:        db
Sound_MusicBank:    db
Sound_SFXBank:      db
Sound_MusicTempo:   dw
Sound_SFXTempo:     dw
Sound_MusicTick:    db
Sound_MusicSubtick: db
Sound_SFXTick:      db
Sound_SFXSubtick:   db

macro sound_channel_struct
Sound_CH\1Pointer:      dw
Sound_CH\1RetPointer:   dw
Sound_CH\1LoopCount:    db
Sound_CH\1Tick:         db
Sound_CH\1Note:         db
Sound_CH\1Octave:       db
Sound_CH\1Envelope:     dw
if (((\1-1)%4 == 0) | ((\1-1)%4 == 1))
Sound_CH\1Pulse:        db
endc
if (\1-1)%4 == 2
Sound_CH\1Wave:         db
endc
if (\1-1)%4 != 3
Sound_CH\1PitchOffset:  db
Sound_CH\1VibDepth:     db
Sound_CH\1VibSpeed:     db
Sound_CH\1VibDelay:     db
Sound_CH\1VibDelay2:    db
Sound_CH\1VibTick:      db ; high byte = phase
Sound_CH\1VibOffset:    dw
endc
endm

    sound_channel_struct 1
    sound_channel_struct 2
    sound_channel_struct 3
    sound_channel_struct 4
    sound_channel_struct 5
    sound_channel_struct 6
    sound_channel_struct 7
    sound_channel_struct 8

Sound_MemEnd:

section "Sound driver routines",rom0

Sound_Init:
    xor     a
    ldh     [rNR52],a
    ld      a,%10000000
    ldh     [rNR52],a
    or      %01111111
    ldh     [rNR51],a
    and     %01110111
    ldh     [rNR50],a
    
    ld      hl,Sound_MemStart
    ld      b,Sound_MemEnd-Sound_MemStart
    xor     a
:   ld      [hl+],a
    djnz    :-
    
    ret

macro sound_update_channel
Sound_UpdateCH\1:
    ld      a,[Sound_Flags]
    bit     \1,a
    if (\1-1)%4 != 3
    jr      z,.dopitch
    else
    ret     z
    endc
    ld      a,[Sound_CH\1Tick]
    dec     a
    ld      [Sound_CH\1Tick],a
    ret     nz
    ld      hl,Sound_CH\1Pointer
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
 if (\1-1)%4 != 3
    jr      .getbyte
.dopitch
    ld      a,[Sound_CH\1Octave]
    ld      b,a
    ld      a,[Sound_CH\1Note]
    call    Sound_CalculateFrequency
    push    hl
    ld      hl,Sound_CH\1VibOffset
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    pop     de
    add     hl,de
    ld      a,l
    ldh     [rNR\13],a
    ld      a,h
    ldh     [rNR\14],a
    ret
 endc 
    
.getbyte
    ld      a,[hl+]
    cp      $e0
    jr      nc,.command
.note
if (\1-1)%4 != 3
    push    hl
    ld      e,a
    and     $f0
    and     a
    jr      z,.rest
    swap    a
    ld      [Sound_CH\1Note],a
    ld      d,a
    ld      a,e
    and     $0f
    inc     a
    ld      [Sound_CH\1Tick],a
    ld      a,[Sound_CH\1Envelope]
    ldh     [rNR\12],a
 if ((\1-1)%4 == 0) | ((\1-1)%4 == 1)
    ld      a,[Sound_CH\1Pulse]
    swap    a
    rla
    rla
    and     %11000000
    ldh     [rNR\11],a
 endc
    ld      a,[Sound_CH\1VibDelay2]
    ld      [Sound_CH\1VibDelay],a
    xor     a
    ld      [Sound_CH\1VibTick],a
    ld      [Sound_CH\1VibOffset],a
    ld      [Sound_CH\1VibOffset+1],a
 if (\1-1)%4 != 3
    call    .dopitch
 if (\1-1)%4 != 2
    or      %10000000
    ldh     [rNR\14],a
 endc
    
 endc
    jr      :+
.rest
    xor     a
    ldh     [rNR\12],a
    ld      a,e
    and     $0f
    inc     a
    ld      [Sound_CH\1Tick],a
:   
else
    ; TODO: CH4 processing
endc
    pop     hl
    ld      a,l
    ld      [Sound_CH\1Pointer],a
    ld      a,h
    ld      [Sound_CH\1Pointer+1],a
    ret
    
.command
    push    hl
    and     $1f
    ld      e,a
    add     a
    ld      hl,.cmdtable
    add     l
    ld      l,a
    jr      nc,:+
    inc     h
:   ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    bit     7,h
    jr      nz,@ ; TODO: Proper error handler
    jp      hl
.cmdtable
    dw      .envelope
    dw      .pulse
    dw      .vibrato
    dw      .jump
    dw      .call
    dw      .return
    dw      .loop
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .octave
    dw      .octave
    dw      .octave
    dw      .octave
    dw      .octave
    dw      .octave
    dw      .octave
    dw      .octave
    dw      .octaveup
    dw      .octavedown
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .dummy
    dw      .end

.dummy
    pop     hl
    jp      .getbyte

.envelope
    pop     hl
    ld      a,[hl+]
    ld      [Sound_CH\1Envelope],a
    jp      .getbyte

.pulse
    pop     hl
    if ((\1-1)%4 == 0) | ((\1-1)%4 == 1)
    ld      a,[hl+]
    ld      [Sound_CH\1Pulse],a
    endc
    if (\1-1)%4 == 2
    ld      a,[hl+]
    push    hl
    ld      l,a
    ld      h,0
    add     hl,hl   ; x2
    add     hl,hl   ; x4
    add     hl,hl   ; x8
    add     hl,hl   ; x16
    ld      de,Sound_Waves
    add     hl,de
    ld      a,%10111011
    ldh     [rNR51],a
    xor     a
    ldh     [rNR30],a
    lb      bc,16,low($ff30)
:   ld      a,[hl+]
    ld      [c],a
    inc     c
    djnz    :-
    ld      a,%11111111
    ldh     [rNR51],a
    ldh     [rNR30],a
    ldh     [rNR34],a
    pop     hl
    endc
    jp      .getbyte

.octave
    if (\1-1)%4 != 3
    ld      a,e
    and     $7
    ld      [Sound_CH\1Octave],a
    endc
    pop     hl
    jp      .getbyte

.octaveup
    if (\1-1)%4 != 3
    ld      hl,Sound_CH\1Octave
    inc     [hl]
    endc
    pop     hl
    jp      .getbyte

.octavedown
    if (\1-1)%4 != 3
    ld      hl,Sound_CH\1Octave
    dec     [hl]
    pop     hl
    endc
    jp      .getbyte

.vibrato
    pop     hl
    if (\1-1)%4 != 3
    ld      a,[hl+]
    ld      [Sound_CH\1VibDelay],a
    ld      [Sound_CH\1VibDelay2],a
    ld      a,[hl]
    and     $f
    ld      [Sound_CH\1VibDepth],a
    ld      a,[hl+]
    and     $f0
    swap    a
    ld      [Sound_CH\1VibSpeed],a
    endc
    jp      .getbyte

.jump
    pop     hl
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    jp      .getbyte

.call
    pop     hl
    ld      a,[hl+]
    ld      d,[hl]
    ld      e,a
    inc     hl
    ld      a,l
    ld      [Sound_CH\1RetPointer],a
    ld      a,h
    ld      [Sound_CH\1RetPointer+1],a
    ld      h,d
    ld      l,e
    jp      .getbyte

.return
    pop     hl
    ld      hl,Sound_CH\1RetPointer
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    jp      .getbyte

.loop
    ld      hl,Sound_CH\1LoopCount
    inc     [hl]
    ld      a,[hl]
    pop     hl
    cp      [hl]
    inc     hl
    jr      z,.noloop
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    jp      .getbyte
.noloop
    xor     a
    ld      [Sound_CH\1LoopCount],a
    inc     hl
    inc     hl
    jp      .getbyte

.end
    pop     hl
    ld      hl,Sound_Flags
    res     \1,a
    ret

endm

    sound_update_channel 1
    sound_update_channel 2
    sound_update_channel 3
    sound_update_channel 4
;    sound_update_channel 5
;    sound_update_channel 6
;    sound_update_channel 7
;    sound_update_channel 8

macro sound_update_vibrato
Sound_VibratoCH\1:
    ld      a,[Sound_CH\1VibDelay]
    and     a
    jr      z,:+
    dec     a
    ld      [Sound_CH\1VibDelay],a
    ret
:   ld      a,[Sound_CH\1VibTick]
    and     $7f
    inc     a
    ld      b,a
    ld      a,[Sound_CH\1VibSpeed]
    cp      b
    jr      z,:+
    ld      a,[Sound_CH\1VibTick]
    cpl
    and     $80
    or      b
    ld      [Sound_CH\1VibTick],a
    jr      z,.off
.on
    ld      a,[Sound_CH\1VibDepth]
    jr      :++
.off
    xor     a
    jr      :++
:   ld      a,[Sound_CH\1VibSpeed]
    ld      [Sound_CH\1VibDelay],a
    xor     a
    ld      [Sound_CH\1VibTick],a
:   ld      [Sound_CH\1VibOffset],a
    xor     a
    ld      [Sound_CH\1VibOffset+1],a
    jp      Sound_UpdateCH\1.dopitch
    
endm

    sound_update_vibrato 1
    sound_update_vibrato 2
    sound_update_vibrato 3
;    sound_update_vibrato 5
;    sound_update_vibrato 6
;    sound_update_vibrato 7

Sound_Update:
    ld      a,[Sound_MusicBank]
    ld      b,a
    rst     Bankswitch
    
    ; TODO: vibrato
    call    Sound_VibratoCH1
    call    Sound_VibratoCH2
    call    Sound_VibratoCH3
    
Sound_UpdateMusic:
    ld      a,[Sound_MusicPlaying]
    and     a
    jp      z,Sound_UpdateSFX
    
    ld      a,[Sound_MusicSubtick]
    and     a
    jr      z,:+
    ld      b,a
    ld      a,[Sound_MusicTempo+1]
    add     b
    ld      [Sound_MusicSubtick],a
    ret     nc
:   ld      a,[Sound_MusicTick]
    dec     a
    ld      [Sound_MusicTick],a
    ret     nz
    ld      a,[Sound_MusicTempo]
    dec     a
    ld      [Sound_MusicTick],a
    call    Sound_UpdateCH1
    call    Sound_UpdateCH2
    call    Sound_UpdateCH3
    call    Sound_UpdateCH4
    ; fall through

Sound_UpdateSFX:
    ld      a,[Sound_SFXPlaying]
    and     a
    jp      z,Sound_FinishedUpdating
    ; fall through

Sound_FinishedUpdating:
    ret

; Input: song ID in DE
Sound_PlaySong:
    ld      hl,Sound_MusicPointers
    add     hl,de
    add     hl,de
    add     hl,de
    ld      a,[hl+]
    ld      [Sound_MusicBank],a
    ld      b,a
    rst     Bankswitch
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a

    ld      a,[hl+]
    ld      [Sound_MusicTempo],a
    ld      a,[hl+]
    ld      [Sound_MusicTempo+1],a
    ld      a,[hl+]
    ld      [Sound_CH1Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH1Pointer+1],a
    ld      a,[hl+]
    ld      [Sound_CH2Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH2Pointer+1],a
    ld      a,[hl+]
    ld      [Sound_CH3Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH3Pointer+1],a
    ld      a,[hl+]
    ld      [Sound_CH4Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH4Pointer+1],a
    
    ld      a,%00001111
    ld      [Sound_Flags],a
    and     1
    ld      [Sound_MusicPlaying],a
    ld      [Sound_MusicTick],a
    ld      [Sound_CH1Tick],a
    ld      [Sound_CH2Tick],a
    ld      [Sound_CH3Tick],a
    ld      [Sound_CH4Tick],a
    ret

; Input: pointer to SFX header in HL, bank of SFX header in B
Sound_PlaySFX:
    ld      b,b
    ret

; INPUT: A = note, B = octave
Sound_CalculateFrequency:
    dec     a
    push    af
    ld      hl,Sound_OctaveDeltaTable
    ld      e,a
    ld      d,0
    add     hl,de
    add     hl,de
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    ld      d,h
    ld      e,l
    ld      hl,0
    ld      a,b
    and     a
    jr      z,.skipshift
:   add     hl,de
    srl     d
    rr      e
    djnz    :-
.skipshift
    pop     af
    push    hl
    ld      hl,Sound_FrequencyTable
    ld      e,a
    ld      d,0
    add     hl,de
    add     hl,de
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    pop     de
    add     hl,de
    ret

Sound_FrequencyTable:   ; note frequencies for notes C-2 to B-2 inclusive
;        C-   C#   D-   D#   E-   F-   F#   G-   G#   A-   A#   B-
    dw  $02c,$09d,$107,$16b,$1ca,$223,$277,$2c7,$312,$358,$39b,$3da

Sound_OctaveDeltaTable: ; frequency differences between note n2 and n3
;        C-   C#   D-   D#   E-   F-   F#   G-   G#   A-   A#   B-
    dw  $3ea,$3b1,$37c,$34a,$31b,$2ee,$2c4,$29c,$277,$254,$232,$213

Sound_Waves:
    db  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00 ; square
    db  $00,$11,$22,$33,$44,$55,$66,$77,$88,$99,$aa,$bb,$cc,$dd,$ee,$ff ; sawtooth
    db  $01,$23,$45,$67,$89,$ab,$cd,$ef,$fe,$dc,$ba,$98,$76,$54,$32,$10 ; triangle
    db  $32,$22,$35,$67,$76,$42,$22,$22,$58,$bd,$ee,$ee,$ee,$ed,$ba,$76 ; bass 1
    db  $01,$23,$45,$67,$89,$ab,$cd,$ef,$55,$dc,$ba,$98,$76,$54,$32,$10 ; distorted triangle

Mus_Dummy:
    sound_end

include "Audio/MusicPointers.asm"