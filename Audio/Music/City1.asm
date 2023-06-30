; ================================================================
; POCKET MANS
; City music 1 sequence
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

section "Music sequence - City 1",romx

Mus_City1:
    db  7,$00   ; tempo
    dw  Mus_City1_CH1
    dw  Mus_City1_CH2
    dw  Mus_City1_CH3
    dw  Mus_City1_CH4

Mus_City1_CH1:
    pulse 2
    octave 5
    vibrato 12,6,3
.loop
    envelope $a4
    sound_call .block1
    note A#,4
    note A_,12
    note G_,4
    note F_,14
    rest 4
    sound_call .block1
    note E_,4
    note F_,12
    note G_,4
    note F_,14
    envelope $a0
    octave 5
    note G_,1
    note A_,1
    note A#,1
    octave_up
    note C_,1
    sound_call .block2
    note G_,6
    note F_,2
    note G_,2
    note A_,4
    note A#,6
    note A_,4
    note G_,2
    note A#,4
    note A_,12
    note F_,2
    note A_,2
    octave_up
    note C_,12
    octave_down
    note A_,2
    octave_up
    note C_,4
    sound_call .block2
    note A#,4
    note A_,4
    note G_,2
    note F_,4
    note E_,4
    note F_,4
    note G_,4
    note A_,4
    note F_,16
    envelope $a7
    note F_,16
    rest 2
    sound_jump .loop
.block1
    note A_,10
    note A_,2
    note A#,2
    octave_up
    note C_,4
    note C_,2
    octave_down
    note A#,4
    note A_,2
    octave_up
    note C_,4
    octave_down
    note A#,10
    note A#,2
    note A_,4
    note G_,16
    rest 2
    note G_,10
    note G_,2
    note A_,2
    note A#,4
    note A#,2
    note A_,4
    note G_,2
    sound_ret
.block2
    note D_,6
    note C_,2
    octave_down
    note A#,2
    note A_,4
    note G_,4
    note A_,4
    note A#,4
    octave_up
    note D_,3
    note C#,1
    note C_,12
    octave_down
    note A_,4
    note F_,12
    note G_,2
    note A_,4
    sound_ret

Mus_City1_CH2:
    pulse 2
    vibrato 14,5,4
.loop
    envelope $a4
    sound_call .block1
    note F_,12
    sound_call .block2
    note G_,2
    note F_,2
    note C_,2
    sound_call .block1
    note A_,12
    sound_call .block2
    rest 6
    envelope $a7
    sound_call .block3
    note E_,4
    note E_,2
    note D_,2
    note E_,2
    note F_,4
    note G_,6
    note G_,2
    note A_,2
    note A#,2
    note G_,4
    note A_,4
    note A_,2
    note G_,2
    note F_,2
    note A_,2
    note F_,4
    note D_,4
    note D_,2
    note C_,4
    note D_,4
    note F_,2
    note A_,2
    sound_call .block3
    octave 5
    note G_,4
    note F_,4
    note E_,2
    note D_,4
    note C_,4
    octave_down
    note A#,4
    note A#,2
    octave_up
    note C_,2
    octave_down
    note A#,4
    note A_,10
    note A_,2
    note G_,4
    note F_,16
    rest 2
    sound_jump .loop
.block1
    octave 5
    note C_,10
    note C_,2
    note C_,2
    note D#,4
    note D_,4
    note C_,2
    note C_,2
    octave_down
    note A_,4
    note G_,8
    note F_,2
    note G_,2
    note F_,4
    note E_,4
    note D_,4
    note E_,2
    note G_,2
    note F_,2
    note E_,4
    note E_,4
    note D_,2
    note E_,4
    note E_,2
    note F_,2
    note G_,4
    note G_,2
    note F_,4
    note E_,2
    note G_,4
    sound_ret
.block2
    note F_,2
    note G_,2
    note A_,4
    note A#,4
    note A_,4
    sound_ret
.block3
    octave 4
    note A#,4
    octave_up
    note C_,2
    note D_,4
    note C_,4
    octave_down
    note A#,4
    octave_up
    note C_,4
    note D_,4
    note D_,2
    note E_,2
    note D_,2
    note C_,4
    note C_,2
    octave_down
    note A#,2
    note A_,2
    octave_up
    note C_,4
    note D_,4
    note C_,4
    octave_down
    note A#,4
    note A_,2
    note F_,4
    sound_ret

Mus_City1_CH3:
    wave 5
    envelope $20
.loop
    octave 3
:   sound_call .block1
    note F#,2
    octave_up
    note F#,1
    rest 1
    note C_,2
    octave_down
    note F#,4
    octave_up
    note F#,1
    rest 1
    note C_,4
    octave_down
    sound_call .block2
    sound_call .block2
    sound_call .block1
    sound_call .block1
    sound_loop :-,2
    sound_call .block3
    sound_call .block4
    sound_call .block5
    sound_call .block4
    sound_call .block6
    sound_call .block5
    sound_call .block3
    sound_call .block4
    sound_call .block5
    sound_call .block4
    sound_call .block6
:   octave 3
    note F_,2
    octave_up
    note C_,1
    rest 1
    note F_,2
    octave_down
    note F_,2
    octave_up
    note F_,1
    rest 1
    note C_,2
    octave_down
    note F_,1
    rest 1
    octave_up
    note F_,2
    sound_loop :-,2
    sound_jump .loop
.block1
    note F_,2
    octave_up
    note F_,1
    rest 1
    note C_,2
    octave_down
    note F_,4
    octave_up
    note F_,1
    rest 1
    note C_,4
    octave_down
    sound_ret
.block2
    note G_,2
    octave_up
    note G_,1
    rest 1
    note D_,2
    octave_down
    note G_,4
    octave_up
    note G_,1
    rest 1
    note D_,4
    octave_down
    note C_,2
    octave_up
    note C_,1
    rest 1
    octave_down
    note G_,2
    note C_,4
    octave_up
    note C_,1
    rest 1
    octave_down
    note G_,4
    sound_ret
.block3
    octave 3
    note G_,2
    octave_up
    note D_,1
    rest 1
    note G_,2
    octave_down
    note G_,2
    octave_up
    note G_,1
    rest 1
    note D_,2
    octave_down
    note G_,1
    rest 1
    octave_up
    note G_,2
    sound_ret
.block4
    octave 3
    note C_,2
    note G_,1
    rest 1
    octave_up
    note C_,2
    octave_down
    note C_,2
    octave_up
    note C_,1
    rest 1
    octave_down
    note G_,2
    note C_,1
    rest 1
    octave_up
    note C_,2
    sound_ret
.block5
    octave 3
    note F_,2
    octave_up
    note C_,1
    rest 1
    note F_,2
    octave_down
    note F_,2
    octave_up
    note F_,1
    rest 1
    note C_,2
    octave_down
    note F_,1
    rest 1
    octave_up
    note F_,2
    octave_down
    note D_,2
    note A_,1
    rest 1
    octave_up
    note D_,2
    octave_down
    note D_,2
    octave_up
    note D_,1
    rest 1
    octave_down
    note A_,2
    note D_,1
    rest 1
    octave_up
    note D_,2
    sound_ret
.block6
    octave 3
    note E_,2
    octave_up
    note C_,1
    rest 1
    note E_,2
    octave_down
    note E_,2
    octave_up
    note E_,1
    rest 1
    note C_,2
    octave_down
    note E_,1
    rest 1
    octave_up
    note E_,2
    sound_ret

Mus_City1_CH4:
:   noise nKick,2
    noise nCHH,2
    noise nCHH,2
    noise nKick,2
    noise nCHH,2
    noise nKick,2
    noise nSnare,2
    noise nCHH,2
    sound_loop :-,16
:   noise nKick,2
    noise nCHH,2
    noise nSnare,2
    noise nKick,2
    noise nOHH,2
    noise nKick,2
    noise nSnare,2
    noise nCHH,2
    sound_loop :-,16
    sound_jump Mus_City1_CH4
