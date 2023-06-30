; ================================================================
; POCKET MANS
; Mans battle music sequence
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

section "Music sequence - Mans battle",romx

Mus_Battle1:
    db  5,$00   ; tempo
    dw  Mus_Battle1_CH1
    dw  Mus_Battle1_CH2
    dw  Mus_Battle1_CH3
    dw  Sound_DummySeq

Mus_Battle1_CH1:
    envelope $a3
    pulse 1
    vibrato 13,5,3
:   octave 5
    note F_,1
    note F#,1
    note G_,1
    octave_up
    note G_,1
    sound_loop :-,8
    envelope $a5
    octave 5
:   note C_,4
    octave_down
    note G_,2
    octave_up
    note D#,4
    octave_down
    note A#,4
    octave_up
    note C_,6
    octave_down
    note G_,4
    note A#,8
    octave_up
    note C#,4
    octave_down
    note G#,2
    octave_up
    note F_,4
    note C_,4
    note C#,10
    note D#,4
    note C#,4
    sound_loop :-,2
    toggle_detune
.loop
    octave 4
:   note G_,4
    note E_,2
    note C_,4
    note E_,2
    note G_,2
    octave_up
    note C_,2
    octave_down
    note A#,4
    note A_,4
    note G_,2
    note A_,6
    note A#,8
    note A_,8
    note G_,8
    note F_,8
    sound_loop :-,2
    sound_call .block1
    note C_,4
    note D#,4
    note G_,4
    note F_,6
    note D#,6
    note D_,4
    note C_,8
    octave_down
    note A#,8
    sound_call .block1
    note D#,4
    note G#,4
    note A_,4
    note A#,6
    note F_,6
    note A#,4
    octave_up
    note D_,8
    octave_down
    note A#,8
    note G_,2
    octave_up
    note C_,2
    octave_down
    note G_,2
    note E_,4
    note G_,4
    octave_up
    note C_,4
    octave_down
    note E_,4
    note G_,2
    octave_up
    note C_,2
    octave_down
    note G_,2
    note E_,2
    note G_,2
    note F_,2
    note A#,2
    note F_,2
    note D_,4
    note F_,4
    note A#,4
    note D_,4
    note F_,2
    note A#,2
    note F_,2
    note D_,2
    note F_,2
    note D#,2
    note G#,2
    note D#,2
    note C_,4
    note D#,4
    note G#,4
    note C_,4
    note D#,2
    note G#,2
    note A#,2
    octave_up
    note C_,2
    octave_down
    note G#,2
    octave_up
    note D_,6
    note C_,6
    octave_down
    note A#,4
    note F_,8
    note A#,8
    sound_jump .loop
.block1
    octave 4
    note D#,4
    note D_,2
    octave_down
    note A#,4
    octave_up
    note C_,4
    octave_down
    note G#,6
    octave_up
    sound_ret

Mus_Battle1_CH2:
    envelope $a5
    pulse 1
    vibrato 12,5,3
    octave 5
:   note C_,1
    octave_down
    note G_,1
    octave_up
    note C_,1
    note G_,1
    sound_loop :-,8
:   note G_,6
    note G_,6
    note G_,12
    note D#,4
    note G_,4
    note G#,6
    note G#,6
    note G#,12
    note F_,8
    sound_loop :-,2
.loop
:   envelope $a5
    note C_,10
    octave_down
    note G_,2
    octave_up
    note C_,2
    note E_,2
    note F_,4
    note E_,4
    note D_,2
    note E_,4
    envelope $a0
    note D_,10
    note D_,8
    envelope $a5
    note D_,16
    sound_loop :-,2
    octave_down
    sound_call .block1
    octave_down
    envelope $a0
    note A#,16
    envelope $a5
    note A#,16
    sound_call .block1
    envelope $a0
    note D_,16
    note F_,16
    note G_,6
    note F_,6
    note E_,4
    note C_,8
    envelope $a3
    note C_,8
    envelope $a0
    note F_,6
    note D#,6
    note D_,4
    octave_down
    note A#,8
    envelope $a3
    note A#,8
    octave_up
    envelope $a0
    note D#,12
    note D_,4
    note C_,8
    note G_,8
    note F_,16
    note D_,16
    sound_jump .loop
.block1
    note G#,6
    note D#,6
    note G#,4
    note A#,8
    octave_up
    note C_,8
    sound_ret

Mus_Battle1_CH3:
    envelope $20
    wave 3
    vibrato 16,5,4
    octave 5
    note C_,1
    rest 1
    note C_,1
    octave_down
    note G_,1
    octave_up    
    note C#,1
    rest 1
    note C#,1
    octave_down
    note G#,1
    octave_up    
    note D_,1
    rest 1
    note D_,1
    octave_down
    note A_,1
    octave_up    
    note D#,1
    rest 1
    note D#,1
    octave_down
    note A#,1
    octave_up
    note E_,1
    rest 1
    note E_,1
    octave_down
    note B_,1
    octave_up
    note F_,1
    rest 1
    note F_,1
    note C_,1
    note F#,1
    rest 1
    note F#,1
    note C#,1
    note G_,2
    octave_down
    note G_,2
    octave_up
    sound_call .block1
    sound_call .block1
.loop
    sound_call .block2
    sound_call .block2
    sound_call .block3
    note A#,2
    note A_,2
    sound_call .block3
    note A#,2
    note B_,2
    octave_up
    sound_call .block2
    sound_call .block3
    note A#,2
    note B_,2
    octave_up
    sound_jump .loop
.block1
:   note C_,2
    note G_,2
    sound_loop :-,6
    note C_,2
    note F_,6
:   note C#,2
    note G#,2
    sound_loop :-,6
    note C#,2
    note F_,6
    sound_ret
.block2
:   note C_,2
    note G_,2
    sound_loop :-,8
:   octave_down
    note A#,2
    octave_up
    note F_,2
    sound_loop :-,8
    sound_ret
.block3
:   octave 4
    note G#,2
    octave_up
    note D#,2
    sound_loop :-,7
    octave_down
    note G#,2
    note A_,2
:   note A#,2
    octave_up
    note F_,2
    octave_down
    sound_loop :-,7
    sound_ret
