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

; KNOWN ISSUES:
; - Vibrato speed 1 doesn't work
; - Vibrato speed 2 is buggy

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

; flag constants
MUSIC_CH1   = 0
MUSIC_CH2   = 1
MUSIC_CH3   = 2
MUSIC_CH4   = 3
SFX_CH1     = 4
SFX_CH2     = 5
SFX_CH3     = 6
SFX_CH4     = 7

; sound command definitions
macro note
    assert (\1 >= 0) & (\1 <= $10)
    assert (\2 >= 0) & (\2 <= $10)
    db  (\1 << 4) | (\2 - 1)
endm

macro noise
    db  \1
    db  \2
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
Sound_CH\1Pointer:          dw
Sound_CH\1RetPointer:       dw
Sound_CH\1LoopCount:        db
Sound_CH\1Tick:             db
Sound_CH\1Note:             db
if (\1-1)%4 != 3
Sound_CH\1Octave:           db
Sound_CH\1Envelope:         db
endc
if (((\1-1)%4 == 0) | ((\1-1)%4 == 1))
Sound_CH\1Pulse:            db
endc
if (\1-1)%4 == 2
Sound_CH\1Wave:             db
endc
if (\1-1)%4 != 3
Sound_CH\1PitchOffset:      db
Sound_CH\1VibDepth:         db
Sound_CH\1VibSpeed:         db
Sound_CH\1VibDelay:         db
Sound_CH\1VibDelay2:        db
Sound_CH\1VibTick:          db ; high byte = phase
Sound_CH\1VibOffset:        dw
Sound_CH\1DetuneFlag:       db
else
Sound_CH\1NoiseSeqBank:     db
Sound_CH\1NoiseSeqPtr:      dw
Sound_CH\1NoiseSeqTimer:    db
endc
Sound_NR\10:                db
Sound_NR\11:                db
Sound_NR\12:                db
Sound_NR\13:                db
Sound_NR\14:                db
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
    bit     \1-1,a
    if (\1-1)%4 != 3
    jr      z,.dopitch
    else
    ret     z
    endc
    ld      a,[Sound_CH\1Tick]
    dec     a
    ld      [Sound_CH\1Tick],a
 if (\1-1)%4 != 3
    ret     nz
 else
    ret     nz
 endc
    ld      hl,Sound_CH\1Pointer
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    jr      .getbyte
 if (\1-1)%4 != 3
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
    ld      a,[Sound_CH\1DetuneFlag]
    and     a
    jr      z,:+
    ld      de,-1
    add     hl,de
:   ld      a,l
    ld      [Sound_NR\13],a
    ld      a,h
    ld      [Sound_NR\14],a
    ret
 else
.donoiseseq
    ld      a,[Sound_Flags]
    bit     \1-1,a
    ret     z
    ld      a,[Sound_CH\1NoiseSeqTimer]
    dec     a
    ld      [Sound_CH\1NoiseSeqTimer],a
    ret     nz
    ld      a,[Sound_CH\1NoiseSeqBank]
    ld      b,a
    rst     Bankswitch
    ld      hl,Sound_CH\1NoiseSeqPtr
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a
    ; first byte: flags
    ld      a,[hl+]
    cp      $ff
    ret     z
    ld      e,a
    bit     0,e
    call    nz,.noiseseq_envelope
    bit     1,e
    call    nz,.noiseseq_noise
    bit     2,e
    call    nz,.noiseseq_reset
    ld      a,[hl+]
    ld      [Sound_CH\1NoiseSeqTimer],a
    ld      a,l
    ld      [Sound_CH\1NoiseSeqPtr],a
    ld      a,h
    ld      [Sound_CH\1NoiseSeqPtr+1],a
    ret
.noiseseq_envelope
    ld      a,[hl+]
    ld      [Sound_NR\12],a
    ret
.noiseseq_noise
    ld      a,[hl+]
    ld      [Sound_NR\13],a
    ret
.noiseseq_reset
    ld      a,$80
    ld      [Sound_NR\14],a
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
 else
    and     a
    jr      z,.rest
    ld      [Sound_CH\1Note],a
    ld      a,[hl+]
    ld      [Sound_CH\1Tick],a
 endc
if (\1-1)%4 != 3
    ld      a,[Sound_CH\1Envelope]
    ld      [Sound_NR\12],a
 if ((\1-1)%4 == 0) | ((\1-1)%4 == 1)
    ld      a,[Sound_CH\1Pulse]
    swap    a
    rla
    rla
    and     %11000000
    ld      [Sound_NR\11],a
 endc
    ld      a,[Sound_CH\1VibDelay2]
    ld      [Sound_CH\1VibDelay],a
    xor     a
    ld      [Sound_CH\1VibTick],a
    ld      [Sound_CH\1VibOffset],a
 if (\1-1)%4 != 2
    or      %10000000
    ld      [Sound_NR\14],a
 endc
    ld      [Sound_CH\1VibOffset+1],a
 if (\1-1)%4 != 3
    call    .dopitch
 endc
    jr      :+
else
    push    hl
    ld      a,[Sound_CH\1Note]
    ld      e,a
    ld      d,0
    ld      hl,Sound_NoiseSequencePointers
    add     hl,de
    add     hl,de
    add     hl,de
    ld      a,[hl+]
    ld      [Sound_CH\1NoiseSeqBank],a
    ld      a,[hl+]
    ld      [Sound_CH\1NoiseSeqPtr],a
    ld      a,[hl+]
    ld      [Sound_CH\1NoiseSeqPtr+1],a
    ld      a,1
    ld      [Sound_CH\1NoiseSeqTimer],a
    call    .donoiseseq
    jr      :+
endc

.rest
    xor     a
    ld      [Sound_NR\12],a
 if (\1-1)%4 != 3
    ld      a,e
    and     $0f
 else
    ld      a,[hl+]
 endc
    inc     a
    ld      [Sound_CH\1Tick],a
:   
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
    dw      .toggledetune
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
    if (\1-1)%4 != 3
    ld      a,[hl+]
    ld      [Sound_CH\1Envelope],a
    endc
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

.toggledetune
    if (\1-1)%4 != 3
    ld      a,[Sound_CH\1DetuneFlag]
    xor     1
    ld      [Sound_CH\1DetuneFlag],a
    endc
    pop     hl
    jp      .getbyte

.end
    pop     hl
    ld      hl,Sound_Flags
    res     \1-1,[hl]
    ret

endm

    sound_update_channel 1
    sound_update_channel 2
    sound_update_channel 3
    sound_update_channel 4
    sound_update_channel 5
    sound_update_channel 6
    sound_update_channel 7
    sound_update_channel 8

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
    sound_update_vibrato 5
    sound_update_vibrato 6
    sound_update_vibrato 7

Sound_Update:
    ld      a,[Sound_MusicBank]
    ld      b,a
    rst     Bankswitch
    
    call    Sound_VibratoCH1
    call    Sound_VibratoCH2
    call    Sound_VibratoCH3
    call    Sound_VibratoCH5
    call    Sound_VibratoCH6
    call    Sound_VibratoCH7
    call    Sound_UpdateCH4.donoiseseq
    call    Sound_UpdateCH8.donoiseseq
    
Sound_UpdateMusic:
    ld      a,[Sound_MusicPlaying]
    and     a
    jr      z,Sound_UpdateSFX
    
    ; TODO: Subticks
 
    ld      a,[Sound_MusicTick]
    dec     a
    ld      [Sound_MusicTick],a
    jr      nz,Sound_UpdateSFX
    ld      a,[Sound_MusicTempo]
    ld      [Sound_MusicTick],a
    call    Sound_UpdateCH1
    call    Sound_UpdateCH2
    call    Sound_UpdateCH3
    call    Sound_UpdateCH4
    ; fall through

; TODO: something about SFX is messing up music tempo
Sound_UpdateSFX:
    ld      a,[Sound_SFXPlaying]
    and     a
    jp      z,Sound_FinishedUpdating
    ld      a,[Sound_SFXBank]
    ld      b,a
    rst     Bankswitch
    
    ; TODO: Subticks
 
    ld      a,[Sound_SFXTick]
    dec     a
    ld      [Sound_SFXTick],a
    jr      nz,Sound_FinishedUpdating
    ld      a,[Sound_SFXTempo]
    ld      [Sound_SFXTick],a
    call    Sound_UpdateCH5
    call    Sound_UpdateCH6
    call    Sound_UpdateCH7
    call    Sound_UpdateCH8

Sound_FinishedUpdating:

Sound_UpdateRegisters:
.check1
    ld      a,[Sound_Flags]
    bit     SFX_CH1,a
    jr      nz,.sfx1
.music1
    ld      a,[Sound_NR11]
    ldh     [rNR11],a
    ld      a,[Sound_NR13]
    ldh     [rNR13],a
    ld      a,[Sound_NR14]
    bit     7,a
    jr      z,:+
    push    af
    ld      a,[Sound_NR12]
    ldh     [rNR12],a
    pop     af
:   ldh     [rNR14],a
    res     7,a
    ld      [Sound_NR14],a
    jr      .check2
.sfx1
    ld      a,[Sound_NR51]
    ldh     [rNR11],a
    ld      a,[Sound_NR53]
    ldh     [rNR13],a
    ld      a,[Sound_NR54]
    bit     7,a
    jr      z,:+
    push    af
    ld      a,[Sound_NR52]
    ldh     [rNR12],a
    pop     af
:   ldh     [rNR14],a
    res     7,a
    ld      [Sound_NR54],a
.check2
    ld      a,[Sound_Flags]
    bit     SFX_CH2,a
    jr      nz,.sfx2
.music2
    ld      a,[Sound_NR21]
    ldh     [rNR21],a
    ld      a,[Sound_NR23]
    ldh     [rNR23],a
    ld      a,[Sound_NR24]
    bit     7,a
    jr      z,:+
    push    af
    ld      a,[Sound_NR22]
    ldh     [rNR22],a
    pop     af
:   ldh     [rNR24],a
    res     7,a
    ld      [Sound_NR24],a
    jr      .check3
.sfx2
    ld      a,[Sound_NR61]
    ldh     [rNR21],a
    ld      a,[Sound_NR63]
    ldh     [rNR23],a
    ld      a,[Sound_NR64]
    bit     7,a
    jr      z,:+
    push    af
    ld      a,[Sound_NR62]
    ldh     [rNR22],a
    pop     af
:   ldh     [rNR24],a
    res     7,a
    ld      [Sound_NR64],a
.check3
    ld      a,[Sound_Flags]
    bit     SFX_CH3,a
    jr      nz,.sfx3
.music3
    ld      a,[Sound_NR32]
    ldh     [rNR32],a
    ld      a,[Sound_NR33]
    ldh     [rNR33],a
    ld      a,[Sound_NR34]
    ldh     [rNR34],a
    jr      .check4
.sfx3
    ld      a,[Sound_NR72]
    ldh     [rNR32],a
    ld      a,[Sound_NR73]
    ldh     [rNR33],a
    ld      a,[Sound_NR74]
    ldh     [rNR34],a
.check4
    ld      a,[Sound_Flags]
    bit     SFX_CH4,a
    jr      nz,.sfx4
.music4
    ld      a,[Sound_NR43]
    ldh     [rNR43],a
    ld      a,[Sound_NR44]
    bit     7,a
    jr      z,:+
    push    af
    ld      a,[Sound_NR42]
    ldh     [rNR42],a
    pop     af
:   ldh     [rNR44],a
    res     7,a
    ld      [Sound_NR44],a
    resbank
    ret
.sfx4
    ld      a,[Sound_NR83]
    ldh     [rNR43],a
    ld      a,[Sound_NR84]
    bit     7,a
    jr      z,:+
    push    af
    ld      a,[Sound_NR82]
    ldh     [rNR42],a
    pop     af
:   ldh     [rNR44],a
    res     7,a
    ld      [Sound_NR84],a
    resbank
    ret


; Input: song ID in DE
Sound_PlaySong:
    ld      hl,Sound_MusicPointers
    add     hl,de
    add     hl,de
    add     hl,de
Sound_PlaySongDirect:
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
    
    ld      a,[Sound_Flags]
    or      %00001111
    ld      [Sound_Flags],a
    and     1
    ld      [Sound_MusicPlaying],a
    ld      [Sound_MusicTick],a
    ld      [Sound_CH1Tick],a
    ld      [Sound_CH2Tick],a
    ld      [Sound_CH3Tick],a
    ld      [Sound_CH4Tick],a
    resbank
    ret

; Input: pointer to SFX header in HL, bank of SFX header in B
Sound_PlaySFX:
    ld      hl,Sound_SFXPointers
    add     hl,de
    add     hl,de
    add     hl,de
Sound_PlaySFXDirect:
    ld      a,[hl+]
    ld      [Sound_SFXBank],a
    ld      b,a
    rst     Bankswitch
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a

    ld      a,[hl+]
    ld      [Sound_SFXTempo],a
    ld      a,[hl+]
    ld      [Sound_SFXTempo+1],a
    ld      a,[hl+]
    ld      [Sound_CH5Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH5Pointer+1],a
    ld      a,[hl+]
    ld      [Sound_CH6Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH6Pointer+1],a
    ld      a,[hl+]
    ld      [Sound_CH7Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH7Pointer+1],a
    ld      a,[hl+]
    ld      [Sound_CH8Pointer],a
    ld      a,[hl+]
    ld      [Sound_CH8Pointer+1],a
    
    ld      a,[Sound_Flags]
    or      %11110000
    ld      [Sound_Flags],a
    ld      a,1
    ld      [Sound_SFXPlaying],a
    ld      [Sound_SFXTick],a
    ld      [Sound_CH5Tick],a
    ld      [Sound_CH6Tick],a
    ld      [Sound_CH7Tick],a
    ld      [Sound_CH8Tick],a
    resbank
    ret

; INPUT: A = note, B = octave
; OUTPUT: note frequency in HL
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
    db  $00,$38,$B8,$00,$00,$23,$58,$ab,$bb,$b2,$2b,$bb,$de,$ff,$ea,$30 ; distorted "square"

Sound_DummySeq:
    sound_end

include "Audio/Percussion.asm"
include "Audio/MusicPointers.asm"
include "Audio/SFXPointers.asm"
