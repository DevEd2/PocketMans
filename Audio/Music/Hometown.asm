; ================================================================
; POCKET MANS
; Hometown music sequence
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

section "Music sequence - Hometown",romx

Mus_Hometown:
    db  8,$00   ; tempo
    dw  Mus_Hometown_CH1
    dw  Mus_Hometown_CH2
    dw  Mus_Hometown_CH3
    dw  Mus_Dummy


Mus_Hometown_CH1:
    octave 5
    pulse 2
    vibrato 13,4,3
.loop
    envelope $a3
    note D_,2
    octave_down
    note B_,2
    octave_up
    note C_,2
    note D_,4
    note G_,2
    note F#,2
    note G_,2
    note F#,2
    note D_,2
    octave_down
    note B_,2
    octave_up
    note C_,4
    note D_,4
    octave_down
    note B_,2
    octave_up
    note C_,2
    octave_down
    note B_,2
    note A_,2
    note B_,4
    note G_,4
    octave_up
    note D_,4
    note D_,2
    octave_down
    note A_,2
    octave_up
    note D_,2
    note D_,2
    note E_,2
    note F#,2
    note G_,4
    
    note D_,2
    note F#,2
    note E_,2
    note F#,2
    note D_,4
    note E_,4
    note D_,2
:   note C_,2
    octave_down
    note B_,2
    octave_up
    sound_loop :-,2
    octave_down
    note A_,2
    note B_,4
    note B_,2
    note A_,2
    note B_,2
    octave_up
    note C_,2
    octave_down
    note A_,4
    note B_,4
    note B_,2
    note A_,2
    note B_,2
    note G_,4
    note B_,4
    octave_up
    sound_call .block1
    sound_call .block1
    note E_,2
    note C_,2
    octave_down
    note A_,2
    octave_up
    note E_,2
    note D_,2
    octave_down
    note B_,2
    note G_,2
    octave_up
    note D_,2
    note D_,2
    octave_down
    note A_,2
    note F#,2
    octave_up
    note D_,4
    octave_down
    note B_,2
    octave_up
    note D_,2
    octave_down
    note B_,2
    envelope $a4
    octave_up
    note C_,4
    octave_down
    note B_,2
    note A_,2
    octave_up
    note C_,2
    octave_down
    note A_,4
    note B_,4
    note B_,2
    note A_,2
    note B_,2
    note G_,4
    octave_up
    note D_,4
    sound_jump .loop
.block1
    note C_,2
    octave_down
    note G_,2
    note E_,2
    note G_,2
    octave_up
    note D_,2
    octave_down
    note A_,2
    note F#,2
    note A_,2
    octave_up
:   note G_,2
    note D_,2
    octave_down
    note B_,2
    octave_up
    note D_,2
    sound_loop :-,2
    sound_ret

Mus_Hometown_CH2:
    octave 5
    pulse 2
    envelope $b4
    vibrato 16,5,2
.loop
    ; part 1
    note G_,6
    note G_,2
    note A_,2
    note B_,4
    note A_,4
    note A_,4
    octave_up
    note C_,4
    octave_down
    note B_,2
    note A_,2
    note G_,6
    note F#,2
    note G_,2
    note A_,2
    note D_,4
    note G_,4
    note G_,2
    note E_,2
    note G_,2
    note F#,2
    note G_,2
    note A_,2
    note B_,6
    note A_,2
    note G_,2
    note A_,2
    note B_,4
    octave_up
    note C_,4
    octave_down
    note B_,2
    octave_up
    note C_,2
    note D_,2
    note C_,2
    octave_down
    note B_,2
    note A_,2
    note G_,6
    note F#,2
    note G_,2
    note A_,2
    note D_,4
    note G_,12
    note G_,2
    note A_,2
    note B_,2
    ; part 2  
    octave_up
    note C_,2
    octave_down
    note B_,2
    note A_,2
    note G_,4
    note F#,2
    note A_,2
    octave_up
    note C_,2
    octave_down
    note B_,10
    note G_,2
    note A_,2
    note B_,2
    octave_up
    note C_,2
    octave_down
    note B_,2
    note A_,2
    note B_,2
    octave_up
    note C_,2
    note D_,4
    octave_down
    note B_,10
    note A_,4
    note B_,4
    octave_up
    note C_,4
    octave_down
    note B_,2
    note A_,2
    note B_,4
    note A_,2
    note G_,4
    note A_,4
    note F#,4
    note D_,2
    note F#,2
    note A_,2
    note G_,2
    note F#,2
    note G_,2
    note A_,4
    note B_,4
    note G_,9
    rest 9
    sound_jump .loop

Mus_Hometown_CH3:
    wave 3
    envelope $20
    octave 5
    vibrato 12,6,2
.loop
    sound_call .block1
    octave_down
    note A_,6
    octave_up
    note C_,4
    note D_,6
    note E_,6
    note F#,4
    sound_call .block1
    note D_,6
    octave_down
    note A_,4
    octave_up
    note G_,8
    note D_,4
    octave_down
    note B_,4
    octave_up
    note C_,8
    note D_,8
    note G_,8
    note D_,4
    octave_down
    note B_,4
    octave_up
    note C_,8
    note D_,8
    note G_,12
    note F#,4
    note E_,6
    note D_,6
    note E_,4
    note D_,6
    octave_down
    note A_,6
    octave_up
    note D_,4
    note C_,6
    note D_,6
    note F#,4
    note G_,6
    note D_,6
    note F#,4
    sound_jump .loop
.block1
    note G_,6
    note D_,6
    note G_,4
    note F#,6
    note D_,6
    note F#,4
    note C_,6
    sound_ret
