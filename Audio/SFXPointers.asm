; ================================================================
; POCKET MANS
; SFX pointer table
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

section "SFX pointer table",rom0

Sound_SFXPointers:
    dwfar SFX_Blank
    dwfar SFX_Test

section "Test SFX",romx
SFX_Blank:
    db  4,0
    dw  SFX_Blank_CH5
    dw  SFX_Blank_CH6
    dw  SFX_Blank_CH7
    dw  SFX_Blank_CH8

SFX_Blank_CH5:
SFX_Blank_CH6:
SFX_Blank_CH7:
SFX_Blank_CH8:
    sound_end

SFX_Test:
    db  4,0
    dw  SFX_Test_CH5
    dw  SFX_Blank_CH6
    dw  SFX_Blank_CH7
    dw  SFX_Blank_CH8

SFX_Test_CH5:
    envelope $f1
    pulse 2
    octave 4
    note C_,2
    note D_,2
    note E_,2
    note F_,2
    note G_,2
    note A_,2
    note B_,2
    octave_up
    note C_,2
    sound_end
    