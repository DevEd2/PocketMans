; ================================================================
; PROJECT: POCKET MANS
; Main source code file
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

include "hardware.inc/hardware.inc"

; ================================================================
; Defines
; ================================================================

section "OAM buffer",wram0,align[8]
OAMBuffer:  ds  40 * 4
OAMBuffer_End:

section "OAM DMA routine",hram
sys_OAMDMA: ds  $10

section "System RAM",hram
sys_GBType:         db
sys_CurrentFrame:   db
sys_btnPress:       db
sys_btnHold:        db
sys_btnRelease:     db
sys_RNG:            ds  4

; ================================================================
; Reset vectors
; ================================================================

section "Reset $00",rom0[$00]
Reset00:    jp  EntryPoint

section "Reset $08",rom0[$08]
Reset08:    ret

section "Reset $10",rom0[$10]
Reset10:    ret

section "Reset $18",rom0[$18]
Reset18:    ret

section "Reset $20",rom0[$20]
Reset20:    ret

section "Reset $28",rom0[$28]
Reset28:    ret

section "Reset $30",rom0[$30]
Reset30:    ret

section "Reset $38",rom0[$38]
ErrTrap:    jr  ErrTrap

; ================================================================
; Interrupt vectors
; ================================================================

section "VBlank IRQ",rom0[$40]
_VBlank:    jp  DoVBlank

section "STAT IRQ",rom0[$48]
_STAT:      jp  DoSTAT

section "Timer IRQ",rom0[$50]
_Timer:     jp  DoTimer

section "Serial IRQ",rom0[$58]
_Serial:    jp  DoSerial

section "Joypad IRQ",rom0[$60]
_Joypad:    jp  DoJoypad

; ================================================================
; ROM header
; ================================================================

section "ROM header",rom0[$100]
EntryPoint:
    jr  Start
    nop
    nop
NintendoLogo:   ds  48,0  ; handled by post-linking tool
ROMTitle:       db  "POCKET MANS",0,0,0,0
GBCSupport:     db  CART_COMPATIBLE_GBC
NewLicenseCode: db  "56"
SGBFlag:        db  CART_INDICATOR_GB
CartType:       db  CART_ROM_MBC5_RAM_BAT
ROMSize:        db  ; handled by post-linking tool
RAMSize:        db  CART_SRAM_128KB
DestCode:       db  CART_DEST_NON_JAPANESE
OldLicenseCode: db  $33
ROMVersion:     db  -1
HeaderChecksum: db  0 ; handled by post-linking tool
ROMChecksum:    dw  0 ; handled by post-linking tool

; ================================================================
; Start of program code
; ================================================================

Start:
    ld      b,b
    di
    ld      sp,$dffe
    push    af
    ; wait for vblank and disable lcd
    ld      hl,rLY
    ld      a,SCRN_Y
:   cp      [hl]
    jr      nz,:-
    xor     a
    ldh     [rLCDC],a
    pop     af
    ld      c,a
    ld      a,b
    and     1
    add     c
    ld      [sys_GBType],a ; $02 on DMG0 (unlikely), $01 on DMG/SGB, $FF on MGB/MGL/SGB2, $11 on CGB, $12 on AGB/GBP
    ; clear HRAM
    ld      bc,low(_HRAM) | (low(rIE) - low(_HRAM)) << 8
    xor     a
:   ld      [c],a
    inc     c
    dec     b
    jr      nz,:-
    
    ; clear OAM
    ld      hl,OAMBuffer
    ld      b,OAMBuffer_End - OAMBuffer
:   ld      [hl+],a
    dec     b
    jr      nz,:-
    
    ; copy OAM DMA routine
    ld      hl,OAMDMA
    ld      bc,low(sys_OAMDMA) | ((OAMDMA_End - OAMDMA) << 8)
:   ld      a,[hl+]
    ld      [c],a
    inc     c
    dec     b
    jr      nz,:-
    
    
Forever:
    jr      Forever
    
OAMDMA: ; copied to HRAM during boot
    ld      a,high(OAMBuffer)
    ldh     [rDMA],a
    ; wait 160 cycles for transfer to complete
    ld      a,40
:   dec     a   
    jr      nz,:-
    ret
OAMDMA_End:
    
; ================================================================
; Interrupt handlers
; ================================================================

DoVBlank:
    reti

DoSTAT:
    reti

DoTimer:
    reti

DoSerial:
    reti

DoJoypad:
    reti
