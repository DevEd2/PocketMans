; ================================================================
; POCKET MANS
; Percussion sequences
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

nKick   = 1
nSnare  = 2
nCHH    = 3
nOHH    = 4

section "Noise sequence pointers",rom0
Sound_NoiseSequencePointers:
    dbw     0,0
    dwfar   NoiseSeq_Kick
    dwfar   NoiseSeq_Snare
    dwfar   NoiseSeq_CHH
    dwfar   NoiseSeq_OHH

section "Noise sequence - Kick",romx
NoiseSeq_Kick:
    db      %00000111,$f1,$5e,2
    db      %00000111,$91,$01,1
    db      $ff
    
NoiseSeq_Snare:
    db      %00000111,$c1,$2f,1
    db      %00000010,$4d,1
    db      %00000010,$5c,1
    db      %00000010,$15,1
    db      $ff

NoiseSeq_CHH:
    db      %00000111,$51,$02,1
    db      $ff

NoiseSeq_OHH:
    db      %00000111,$54,$03,1
    db      $ff

section "Noise sequence - Snare",romx